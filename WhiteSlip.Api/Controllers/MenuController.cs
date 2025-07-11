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

    [HttpGet]
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
    public async Task<ActionResult<object>> UpdateMenu([FromBody] object menuData)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("菜單更新請求: DeviceId={DeviceId}", deviceId);

            // 獲取當前最新版本
            var currentVersion = await _context.Menus
                .OrderByDescending(m => m.Version)
                .Select(m => m.Version)
                .FirstOrDefaultAsync();

            var newVersion = currentVersion + 1;

            // 創建新菜單版本
            var newMenu = new Menu
            {
                Version = newVersion,
                MenuData = System.Text.Json.JsonSerializer.Serialize(menuData),
                LastUpdated = DateTime.UtcNow
            };

            _context.Menus.Add(newMenu);
            await _context.SaveChangesAsync();

            _logger.LogInformation("菜單已更新至版本 {Version}", newVersion);

            return Ok(new
            {
                version = newVersion,
                lastUpdated = newMenu.LastUpdated,
                message = "菜單更新成功"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "菜單更新過程中發生錯誤");
            return StatusCode(500, new { message = "菜單更新失敗" });
        }
    }
} 