using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WhiteSlip.Api.Services;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class TestController : ControllerBase
{
    private readonly ILogger<TestController> _logger;

    public TestController(ILogger<TestController> logger)
    {
        _logger = logger;
    }

    [HttpGet("device-status")]
    [Authorize(Policy = "DeviceActive")]
    public ActionResult<object> TestDeviceStatus()
    {
        var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        
        _logger.LogInformation("測試裝置狀態端點被呼叫: DeviceId={DeviceId}, Role={Role}", deviceId, role);
        
        return Ok(new
        {
            message = "裝置狀態檢查通過",
            deviceId = deviceId,
            role = role,
            timestamp = DateTime.UtcNow
        });
    }

    [HttpGet("basic-auth")]
    public ActionResult<object> TestBasicAuth()
    {
        var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        
        _logger.LogInformation("基本認證端點被呼叫: DeviceId={DeviceId}, Role={Role}", deviceId, role);
        
        return Ok(new
        {
            message = "基本認證通過",
            deviceId = deviceId,
            role = role,
            timestamp = DateTime.UtcNow
        });
    }
} 