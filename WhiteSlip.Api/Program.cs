using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Text;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;
using WhiteSlip.Api.Services;
using Prometheus;
using Microsoft.AspNetCore.Authorization;

var builder = WebApplication.CreateBuilder(args);

// 配置 Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

// 讀取連線字串，優先取環境變數，其次 appsettings.json
var connStr = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
    ?? Environment.GetEnvironmentVariable("DB_CONN")
    ?? builder.Configuration.GetConnectionString("Default");

Console.WriteLine($"[啟動] 資料庫連線字串：{connStr}"); // 僅供開發測試用，正式環境請移除

// 配置 Entity Framework Core
builder.Services.AddDbContext<WhiteSlipDbContext>(options =>
    options.UseNpgsql(connStr));

// 配置 JWT 設定
var jwtSettings = new JwtSettings
{
    Secret = Environment.GetEnvironmentVariable("JWT_SECRET") ?? "CHANGE_ME_32_BYTE_SECRET_KEY_HERE",
    Issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? "white-slip-api",
    Audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? "white-slip-app",
    ExpirationHours = 20
};

builder.Services.AddSingleton(jwtSettings);

// 配置 JWT 認證
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(jwtSettings.Secret)),
            ValidateIssuer = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtSettings.Audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

// 配置服務
builder.Services.AddScoped<IJwtService, JwtService>();

// 配置授權
builder.Services.AddScoped<IAuthorizationHandler, DeviceAuthorizationHandler>();
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("DeviceActive", policy =>
        policy.Requirements.Add(new DeviceAuthorizationRequirement()));
});

// 配置 Prometheus metrics
builder.Services.AddHealthChecks()
    .AddNpgSql(connStr!);

// 配置控制器
builder.Services.AddControllers();

// 配置 CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()
              .WithExposedHeaders("X-Trace-Id");
    });
});

var app = builder.Build();

// 配置 Serilog 請求日誌
app.UseSerilogRequestLogging();

// 配置 CORS
app.UseCors("AllowAll");

// Prometheus metrics
app.UseHttpMetrics();
app.MapMetrics("/metrics");

// 配置認證和授權
app.UseAuthentication();
app.UseAuthorization();

// 配置路由
app.MapControllers();

// 健康檢查端點
app.MapHealthChecks("/healthz");

app.MapGet("/", () => "WhiteSlip API v1.0");

// 初始化資料庫
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<WhiteSlipDbContext>();
    await DbInitializer.Initialize(context);
}

// 讓 Kestrel 對外監聽 0.0.0.0:5001
builder.WebHost.UseUrls("http://0.0.0.0:5001");

app.Run();
