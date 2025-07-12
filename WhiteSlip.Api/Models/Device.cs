using System.ComponentModel.DataAnnotations;

namespace WhiteSlip.Api.Models;

public enum DeviceStatus
{
    Inactive = 0,    // 未激活
    Active = 1,      // 激活
    Disabled = 2,    // 停用
    Deleted = 3      // 已刪除
}

public class Device
{
    [Key]
    public Guid DeviceId { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(50)]
    public string DeviceCode { get; set; } = string.Empty;
    
    [Required]
    public string Jwt { get; set; } = string.Empty;
    
    public DateTime LastSeen { get; set; } = DateTime.UtcNow;
    
    [Required]
    public DeviceStatus Status { get; set; } = DeviceStatus.Inactive;
    
    public string? DeviceName { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? ActivatedAt { get; set; }
    
    public DateTime? DisabledAt { get; set; }
    
    public DateTime? DeletedAt { get; set; }
} 