using System.ComponentModel.DataAnnotations;

namespace WhiteSlip.Api.Models;

public class Device
{
    [Key]
    public Guid DeviceId { get; set; } = Guid.NewGuid();
    
    [Required]
    public string Jwt { get; set; } = string.Empty;
    
    public DateTime LastSeen { get; set; } = DateTime.UtcNow;
} 