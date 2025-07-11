using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;
using WhiteSlip.Api.Services;
using System.Security.Cryptography;
using System.Text;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class AuthController : ControllerBase
{
    private readonly WhiteSlipDbContext _context;
    private readonly IJwtService _jwtService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        WhiteSlipDbContext context, 
        IJwtService jwtService, 
        ILogger<AuthController> logger)
    {
        _context = context;
        _jwtService = jwtService;
        _logger = logger;
    }

    [HttpPost]
    public async Task<ActionResult<AuthResponse>> Authenticate([FromBody] AuthRequest request)
    {
        try
        {
            _logger.LogInformation("裝置認證請求: {DeviceCode}", request.DeviceCode);

            // 驗證裝置代碼格式（簡單驗證）
            if (string.IsNullOrWhiteSpace(request.DeviceCode) || request.DeviceCode.Length < 3)
            {
                return BadRequest(new AuthResponse
                {
                    Success = false,
                    Message = "無效的裝置代碼"
                });
            }

            // 查找或創建設備
            var device = await _context.Devices
                .FirstOrDefaultAsync(d => d.DeviceCode == request.DeviceCode);

            if (device == null)
            {
                // 創建新設備
                device = new Device
                {
                    DeviceCode = request.DeviceCode,
                    LastSeen = DateTime.UtcNow
                };
                _context.Devices.Add(device);
                await _context.SaveChangesAsync();
                
                _logger.LogInformation("創建新裝置: {DeviceCode}", request.DeviceCode);
            }
            else
            {
                // 更新最後活動時間
                device.LastSeen = DateTime.UtcNow;
                await _context.SaveChangesAsync();
                
                _logger.LogInformation("裝置重新認證: {DeviceCode}", request.DeviceCode);
            }

            // 生成 JWT Token
            var token = _jwtService.GenerateToken(device.DeviceId.ToString());
            var expiresAt = DateTime.UtcNow.AddHours(20);

            return Ok(new AuthResponse
            {
                Success = true,
                Token = token,
                ExpiresAt = expiresAt,
                Message = "認證成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "認證過程中發生錯誤: {DeviceCode}", request.DeviceCode);
            return StatusCode(500, new AuthResponse
            {
                Success = false,
                Message = "認證服務暫時不可用"
            });
        }
    }

    [HttpPost("user-login")]
    public async Task<ActionResult<UserLoginResponse>> UserLogin([FromBody] UserLoginRequest request)
    {
        try
        {
            _logger.LogInformation("使用者登入請求: {Account}", request.Account);
            if (string.IsNullOrWhiteSpace(request.Account) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new UserLoginResponse
                {
                    Success = false,
                    Message = "帳號或密碼不得為空"
                });
            }
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Account == request.Account);
            if (user == null)
            {
                return Unauthorized(new UserLoginResponse
                {
                    Success = false,
                    Message = "帳號或密碼錯誤"
                });
            }
            // 密碼驗證（假設已雜湊，這裡用 SHA256 範例）
            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(request.Password));
            var hashString = BitConverter.ToString(hash).Replace("-", "").ToLower();
            if (user.HashedPw != hashString)
            {
                return Unauthorized(new UserLoginResponse
                {
                    Success = false,
                    Message = "帳號或密碼錯誤"
                });
            }
            // 產生 JWT
            var token = _jwtService.GenerateUserToken(user.UserId.ToString(), user.Role);
            var expiresAt = DateTime.UtcNow.AddHours(20);
            return Ok(new UserLoginResponse
            {
                Success = true,
                Token = token,
                Role = user.Role,
                ExpiresAt = expiresAt,
                Message = "登入成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "使用者登入過程中發生錯誤: {Account}", request.Account);
            return StatusCode(500, new UserLoginResponse
            {
                Success = false,
                Message = "登入服務暫時不可用"
            });
        }
    }
} 