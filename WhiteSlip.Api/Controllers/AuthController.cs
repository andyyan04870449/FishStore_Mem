using Microsoft.AspNetCore.Authorization;
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

            // 查找裝置
            var device = await _context.Devices
                .FirstOrDefaultAsync(d => d.DeviceCode == request.DeviceCode);

            if (device == null)
            {
                return Unauthorized(new AuthResponse
                {
                    Success = false,
                    Message = "裝置未註冊，請聯繫管理員"
                });
            }

            // 檢查裝置狀態
            if (device.Status == DeviceStatus.Disabled)
            {
                _logger.LogWarning("停用裝置嘗試認證: {DeviceCode}", request.DeviceCode);
                return Unauthorized(new AuthResponse
                {
                    Success = false,
                    Message = "裝置已被停用，請聯繫管理員"
                });
            }

            if (device.Status == DeviceStatus.Deleted)
            {
                _logger.LogWarning("已刪除裝置嘗試認證: {DeviceCode}", request.DeviceCode);
                return Unauthorized(new AuthResponse
                {
                    Success = false,
                    Message = "裝置已被刪除"
                });
            }

            // 更新最後活動時間
            device.LastSeen = DateTime.UtcNow;
            
            // 如果是新裝置，設置為啟用狀態
            if (device.Status == DeviceStatus.Inactive)
            {
                device.Status = DeviceStatus.Active;
                device.ActivatedAt = DateTime.UtcNow;
                _logger.LogInformation("新裝置自動啟用: {DeviceCode}", request.DeviceCode);
            }
            
            await _context.SaveChangesAsync();
            
            _logger.LogInformation("裝置認證成功: {DeviceCode}, Status={Status}", request.DeviceCode, device.Status);

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

    // 新增：生成授權碼
    [HttpPost("generate-auth-code")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<AuthCodeResponse>> GenerateAuthCode([FromBody] GenerateAuthCodeRequest request)
    {
        try
        {
            _logger.LogInformation("生成授權碼請求: {DeviceName}", request.DeviceName);

            // 生成唯一的授權碼
            var authCode = GenerateUniqueAuthCode();
            
            // 創建設備記錄
            var device = new Device
            {
                DeviceCode = authCode,
                DeviceName = request.DeviceName,
                Status = DeviceStatus.Inactive,
                LastSeen = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };
            
            _context.Devices.Add(device);
            await _context.SaveChangesAsync();

            _logger.LogInformation("成功生成授權碼: {AuthCode} for {DeviceName}", authCode, request.DeviceName);

            return Ok(new AuthCodeResponse
            {
                Success = true,
                AuthCode = authCode,
                DeviceId = device.DeviceId,
                Message = "授權碼生成成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "生成授權碼時發生錯誤");
            return StatusCode(500, new AuthCodeResponse
            {
                Success = false,
                Message = "生成授權碼失敗"
            });
        }
    }

    // 新增：獲取裝置列表
    [HttpGet("devices")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<DeviceListResponse>> GetDevices([FromQuery] bool includeDeleted = false)
    {
        try
        {
            var query = _context.Devices.AsQueryable();
            
            if (!includeDeleted)
            {
                query = query.Where(d => d.Status != DeviceStatus.Deleted);
            }
            
            var devices = await query
                .OrderByDescending(d => d.LastSeen)
                .Select(d => new DeviceInfo
                {
                    DeviceId = d.DeviceId,
                    DeviceCode = d.DeviceCode,
                    DeviceName = d.DeviceName,
                    LastSeen = d.LastSeen,
                    Status = d.Status,
                    CreatedAt = d.CreatedAt,
                    ActivatedAt = d.ActivatedAt,
                    DisabledAt = d.DisabledAt,
                    DeletedAt = d.DeletedAt,
                    IsActive = d.LastSeen > DateTime.UtcNow.AddHours(-24) // 24小時內有活動視為活躍
                })
                .ToListAsync();

            return Ok(new DeviceListResponse
            {
                Success = true,
                Devices = devices,
                TotalCount = devices.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "獲取裝置列表時發生錯誤");
            return StatusCode(500, new DeviceListResponse
            {
                Success = false,
                Message = "獲取裝置列表失敗"
            });
        }
    }

    // 新增：停用裝置
    [HttpPut("devices/{deviceId}/disable")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BaseResponse>> DisableDevice(Guid deviceId)
    {
        try
        {
            var device = await _context.Devices.FindAsync(deviceId);
            if (device == null)
            {
                return NotFound(new BaseResponse
                {
                    Success = false,
                    Message = "裝置不存在"
                });
            }

            device.Status = DeviceStatus.Disabled;
            device.DisabledAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation("成功停用裝置: {DeviceCode}", device.DeviceCode);

            return Ok(new BaseResponse
            {
                Success = true,
                Message = "裝置停用成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "停用裝置時發生錯誤: {DeviceId}", deviceId);
            return StatusCode(500, new BaseResponse
            {
                Success = false,
                Message = "停用裝置失敗"
            });
        }
    }

    // 新增：啟用裝置
    [HttpPut("devices/{deviceId}/enable")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BaseResponse>> EnableDevice(Guid deviceId)
    {
        try
        {
            var device = await _context.Devices.FindAsync(deviceId);
            if (device == null)
            {
                return NotFound(new BaseResponse
                {
                    Success = false,
                    Message = "裝置不存在"
                });
            }

            device.Status = DeviceStatus.Active;
            device.ActivatedAt = DateTime.UtcNow;
            device.DisabledAt = null;
            await _context.SaveChangesAsync();

            _logger.LogInformation("成功啟用裝置: {DeviceCode}", device.DeviceCode);

            return Ok(new BaseResponse
            {
                Success = true,
                Message = "裝置啟用成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "啟用裝置時發生錯誤: {DeviceId}", deviceId);
            return StatusCode(500, new BaseResponse
            {
                Success = false,
                Message = "啟用裝置失敗"
            });
        }
    }

    // 新增：刪除裝置
    [HttpDelete("devices/{deviceId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<BaseResponse>> DeleteDevice(Guid deviceId)
    {
        try
        {
            var device = await _context.Devices.FindAsync(deviceId);
            if (device == null)
            {
                return NotFound(new BaseResponse
                {
                    Success = false,
                    Message = "裝置不存在"
                });
            }

            device.Status = DeviceStatus.Deleted;
            device.DeletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation("成功刪除裝置: {DeviceCode}", device.DeviceCode);

            return Ok(new BaseResponse
            {
                Success = true,
                Message = "裝置刪除成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "刪除裝置時發生錯誤: {DeviceId}", deviceId);
            return StatusCode(500, new BaseResponse
            {
                Success = false,
                Message = "刪除裝置失敗"
            });
        }
    }

    // 私有方法：生成唯一授權碼
    private string GenerateUniqueAuthCode()
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var random = new Random();
        string authCode;
        
        do
        {
            authCode = new string(Enumerable.Repeat(chars, 6)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        } while (_context.Devices.Any(d => d.DeviceCode == authCode));

        return authCode;
    }
} 