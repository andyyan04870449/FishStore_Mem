# API 裝置狀態安全修復說明

## 問題描述

原本的 API 系統存在嚴重的安全漏洞：**停用的裝置仍然可以正常訪問所有 API 功能**。

### 問題原因

1. **認證階段未檢查裝置狀態**：`AuthController.Authenticate` 方法只檢查裝置是否存在，沒有檢查裝置狀態
2. **API 端點未檢查裝置狀態**：所有需要認證的 API 端點都沒有檢查裝置是否被停用
3. **JWT 權杖不包含狀態資訊**：權杖只包含裝置 ID，不包含裝置狀態

## 修復內容

### 1. 認證階段狀態檢查

修改 `AuthController.Authenticate` 方法：

```csharp
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
```

### 2. 裝置授權處理器

創建 `DeviceAuthorizationHandler` 來檢查所有 API 請求的裝置狀態：

```csharp
public class DeviceAuthorizationHandler : AuthorizationHandler<DeviceAuthorizationRequirement>
{
    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context, 
        DeviceAuthorizationRequirement requirement)
    {
        // 檢查是否為裝置認證（Device 角色）
        var deviceRole = context.User.FindFirst(ClaimTypes.Role)?.Value;
        if (deviceRole != "Device")
        {
            context.Succeed(requirement);
            return;
        }

        // 獲取裝置 ID 並檢查狀態
        var deviceIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var device = await _context.Devices
            .AsNoTracking()
            .FirstOrDefaultAsync(d => d.DeviceId == deviceId);

        // 檢查裝置狀態
        if (device.Status == DeviceStatus.Disabled || device.Status == DeviceStatus.Deleted)
        {
            context.Fail();
            return;
        }

        context.Succeed(requirement);
    }
}
```

### 3. API 端點授權策略

為所有裝置相關的 API 端點添加 `DeviceActive` 授權策略：

```csharp
[HttpGet]
[Authorize(Policy = "DeviceActive")]
public async Task<ActionResult<object>> GetMenu([FromQuery] int? version)
```

### 4. 新增重新列印端點

添加了缺失的重新列印訂單端點：

```csharp
[HttpPost("{orderId}/reprint")]
[Authorize(Policy = "DeviceActive")]
public async Task<ActionResult<object>> ReprintOrder(string orderId)
```

## 修復的 API 端點

以下 API 端點現在會檢查裝置狀態：

### 菜單相關
- `GET /api/v1/menu` - 查詢菜單
- `GET /api/v1/menu/latest-version` - 查詢最新版本

### 訂單相關
- `POST /api/v1/orders/bulk` - 批次上傳訂單
- `GET /api/v1/orders` - 查詢訂單
- `POST /api/v1/orders/{orderId}/reprint` - 重新列印訂單

## 裝置狀態說明

### DeviceStatus 枚舉
```csharp
public enum DeviceStatus
{
    Inactive = 0,    // 未激活
    Active = 1,      // 激活
    Disabled = 2,    // 停用
    Deleted = 3      // 已刪除
}
```

### 狀態檢查邏輯
- **Inactive**：新裝置，首次認證時自動設為 Active
- **Active**：正常狀態，可以訪問所有 API
- **Disabled**：停用狀態，無法認證和訪問 API
- **Deleted**：已刪除狀態，無法認證和訪問 API

## 安全效果

### 修復前
- 停用裝置仍可獲得 JWT 權杖
- 停用裝置可正常訪問所有 API
- 停用裝置可正常寫入資料

### 修復後
- 停用裝置無法獲得 JWT 權杖
- 停用裝置無法訪問任何 API
- 停用裝置無法寫入資料
- 所有 API 請求都會檢查裝置狀態

## 測試建議

### 1. 正常裝置測試
1. 使用啟用的裝置進行認證
2. 驗證可以正常訪問所有 API
3. 驗證可以正常寫入資料

### 2. 停用裝置測試
1. 在管理平台停用裝置
2. 嘗試使用停用裝置進行認證
3. 驗證認證失敗並返回適當錯誤訊息
4. 如果有舊的 JWT 權杖，嘗試訪問 API
5. 驗證 API 訪問被拒絕

### 3. 重新啟用測試
1. 在管理平台重新啟用裝置
2. 驗證裝置可以重新正常認證和訪問 API

## 日誌記錄

系統會記錄以下安全事件：

- 停用裝置嘗試認證
- 已刪除裝置嘗試認證
- 停用裝置嘗試訪問 API
- 已刪除裝置嘗試訪問 API

這些日誌有助於監控和追蹤安全事件。 