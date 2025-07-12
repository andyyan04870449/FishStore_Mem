namespace WhiteSlip.Api.Models;

public class AuthRequest
{
    public string DeviceCode { get; set; } = string.Empty;
}

public class AuthResponse
{
    public bool Success { get; set; }
    public string? Token { get; set; }
    public string? Message { get; set; }
    public DateTime? ExpiresAt { get; set; }
}

public class UserLoginRequest
{
    public string Account { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class UserLoginResponse
{
    public bool Success { get; set; }
    public string? Token { get; set; }
    public string? Role { get; set; }
    public string? Message { get; set; }
    public DateTime? ExpiresAt { get; set; }
}

public class JwtSettings
{
    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int ExpirationHours { get; set; } = 20;
}

// 新增：生成授權碼請求
public class GenerateAuthCodeRequest
{
    public string DeviceName { get; set; } = string.Empty;
}

// 新增：授權碼回應
public class AuthCodeResponse
{
    public bool Success { get; set; }
    public string? AuthCode { get; set; }
    public Guid? DeviceId { get; set; }
    public string? Message { get; set; }
}

// 新增：裝置資訊
public class DeviceInfo
{
    public Guid DeviceId { get; set; }
    public string DeviceCode { get; set; } = string.Empty;
    public DateTime LastSeen { get; set; }
    public bool IsActive { get; set; }
}

// 新增：裝置列表回應
public class DeviceListResponse
{
    public bool Success { get; set; }
    public List<DeviceInfo> Devices { get; set; } = new();
    public int TotalCount { get; set; }
    public string? Message { get; set; }
}

// 新增：基礎回應
public class BaseResponse
{
    public bool Success { get; set; }
    public string? Message { get; set; }
} 