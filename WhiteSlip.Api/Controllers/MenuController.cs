using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class MenuController : ControllerBase
{
    private readonly WhiteSlipDbContext _context;
    private readonly ILogger<MenuController> _logger;

    public MenuController(WhiteSlipDbContext context, ILogger<MenuController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet("latest-version")]
    [Authorize(Policy = "DeviceActive")]
    public async Task<ActionResult<object>> GetLatestVersion()
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("取得最新版本號請求: DeviceId={DeviceId}", deviceId);

            var latestMenu = await _context.Menus
                .OrderByDescending(m => m.Version)
                .FirstOrDefaultAsync();

            if (latestMenu == null)
            {
                return Ok(new { version = 0, lastUpdated = (DateTime?)null });
            }

            return Ok(new
            {
                version = latestMenu.Version,
                lastUpdated = latestMenu.LastUpdated
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "取得最新版本號時發生錯誤");
            return StatusCode(500, new { message = "服務暫時不可用" });
        }
    }

    [HttpGet]
    [Authorize(Policy = "DeviceActive")]
    public async Task<ActionResult<object>> GetMenu([FromQuery] int? version)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("菜單查詢請求: DeviceId={DeviceId}, Version={Version}", deviceId, version);

            // 獲取最新版本的菜單
            var latestMenu = await _context.Menus
                .OrderByDescending(m => m.Version)
                .FirstOrDefaultAsync();

            if (latestMenu == null)
            {
                return NotFound(new { message = "菜單不存在" });
            }

            // 如果客戶端版本與服務器版本相同，返回 304 Not Modified
            if (version.HasValue && version.Value == latestMenu.Version)
            {
                return StatusCode(304);
            }

            // 解析菜單 JSON
            var menuData = System.Text.Json.JsonSerializer.Deserialize<object>(latestMenu.MenuData);

            return Ok(new
            {
                version = latestMenu.Version,
                lastUpdated = latestMenu.LastUpdated,
                menu = menuData
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "菜單查詢過程中發生錯誤");
            return StatusCode(500, new { message = "菜單服務暫時不可用" });
        }
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<object>> UpdateMenu([FromBody] CreateMenuRequest request)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("菜單建立請求: DeviceId={DeviceId}, Version={Version}", deviceId, request.Version);

            // 驗證輸入
            if (request.Categories == null || !request.Categories.Any())
            {
                return BadRequest(new { message = "至少需要一個分類" });
            }



            // 驗證必填欄位
            foreach (var category in request.Categories)
            {
                if (string.IsNullOrWhiteSpace(category.Name))
                {
                    return BadRequest(new { message = "分類名稱不能為空" });
                }

                foreach (var item in category.Items)
                {
                    if (string.IsNullOrWhiteSpace(item.Name))
                    {
                        return BadRequest(new { message = "項目名稱不能為空" });
                    }
                    if (item.Price <= 0)
                    {
                        return BadRequest(new { message = "價格必須大於 0" });
                    }
                }
            }

            // 建立新菜單版本
            var newVersion = await GetNextVersion();
            var newMenu = new Menu
            {
                Version = newVersion,
                MenuData = System.Text.Json.JsonSerializer.Serialize(new { categories = request.Categories }),
                LastUpdated = DateTime.UtcNow
            };

            _context.Menus.Add(newMenu);
            await _context.SaveChangesAsync();

            _logger.LogInformation("菜單已建立至版本 {Version}", newVersion);

            return Ok(new
            {
                version = newVersion,
                lastUpdated = newMenu.LastUpdated,
                message = "菜單建立成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "菜單建立過程中發生錯誤");
            return StatusCode(500, new { message = "菜單建立失敗" });
        }
    }

    private async Task<int> GetNextVersion()
    {
        var currentVersion = await _context.Menus
            .OrderByDescending(m => m.Version)
            .Select(m => m.Version)
            .FirstOrDefaultAsync();
        
        return currentVersion + 1;
    }
} 