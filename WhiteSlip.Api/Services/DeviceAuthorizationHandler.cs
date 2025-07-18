using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Services;

public class DeviceAuthorizationRequirement : IAuthorizationRequirement
{
    public DeviceAuthorizationRequirement()
    {
    }
}

public class DeviceAuthorizationHandler : AuthorizationHandler<DeviceAuthorizationRequirement>
{
    private readonly WhiteSlipDbContext _context;
    private readonly ILogger<DeviceAuthorizationHandler> _logger;

    public DeviceAuthorizationHandler(WhiteSlipDbContext context, ILogger<DeviceAuthorizationHandler> logger)
    {
        _context = context;
        _logger = logger;
    }

    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context, 
        DeviceAuthorizationRequirement requirement)
    {
        _logger.LogInformation("=== 裝置授權處理器被呼叫 ===");
        
        // 檢查是否為裝置認證（Device 角色）
        var deviceRole = context.User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
        var deviceIdClaim = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        
        _logger.LogInformation("授權檢查: Role={Role}, DeviceId={DeviceId}", deviceRole, deviceIdClaim);
        
        if (deviceRole != "Device")
        {
            _logger.LogInformation("非裝置認證，跳過裝置狀態檢查");
            context.Succeed(requirement);
            return;
        }

        if (string.IsNullOrEmpty(deviceIdClaim) || !Guid.TryParse(deviceIdClaim, out var deviceId))
        {
            _logger.LogWarning("無效的裝置 ID: {DeviceId}", deviceIdClaim);
            context.Fail();
            return;
        }

        try
        {
            // 查詢裝置狀態
            var device = await _context.Devices
                .AsNoTracking()
                .FirstOrDefaultAsync(d => d.DeviceId == deviceId);

            if (device == null)
            {
                _logger.LogWarning("裝置不存在: {DeviceId}", deviceId);
                context.Fail();
                return;
            }

            _logger.LogInformation("裝置狀態檢查: DeviceId={DeviceId}, DeviceCode={DeviceCode}, Status={Status}", 
                deviceId, device.DeviceCode, device.Status);

            // 檢查裝置狀態
            if (device.Status == DeviceStatus.Disabled)
            {
                _logger.LogWarning("❌ 停用裝置嘗試訪問 API: {DeviceId}, {DeviceCode}", deviceId, device.DeviceCode);
                context.Fail();
                return;
            }

            if (device.Status == DeviceStatus.Deleted)
            {
                _logger.LogWarning("❌ 已刪除裝置嘗試訪問 API: {DeviceId}, {DeviceCode}", deviceId, device.DeviceCode);
                context.Fail();
                return;
            }

            // 裝置狀態正常，授權通過
            _logger.LogInformation("✅ 裝置授權通過: {DeviceId}, {DeviceCode}, Status={Status}", 
                deviceId, device.DeviceCode, device.Status);
            context.Succeed(requirement);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "檢查裝置狀態時發生錯誤: {DeviceId}", deviceId);
            context.Fail();
        }
    }
} 