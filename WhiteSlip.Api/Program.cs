using Microsoft.EntityFrameworkCore;
using Serilog;
using WhiteSlip.Api.Data;

var builder = WebApplication.CreateBuilder(args);

// 配置 Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .CreateLogger();

builder.Host.UseSerilog();

// 讀取連線字串，優先取環境變數 DB_CONN，其次 appsettings.json
var connStr = Environment.GetEnvironmentVariable("DB_CONN")
    ?? builder.Configuration.GetConnectionString("Default");

Console.WriteLine($"[啟動] 資料庫連線字串：{connStr}"); // 僅供開發測試用，正式環境請移除

// 配置 Entity Framework Core
builder.Services.AddDbContext<WhiteSlipDbContext>(options =>
    options.UseNpgsql(connStr));

// 配置健康檢查
builder.Services.AddHealthChecks()
    .AddNpgSql(connStr!);

var app = builder.Build();

// 配置 Serilog 請求日誌
app.UseSerilogRequestLogging();

// 健康檢查端點
app.MapHealthChecks("/healthz");

app.MapGet("/", () => "WhiteSlip API v1.0");

app.Run();
