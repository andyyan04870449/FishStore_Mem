using System.ComponentModel.DataAnnotations;

namespace WhiteSlip.Api.Models;

public class User
{
    [Key]
    public Guid UserId { get; set; } = Guid.NewGuid();
    
    [Required]
    [MaxLength(100)]
    public string Account { get; set; } = string.Empty;
    
    [Required]
    public string HashedPw { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(20)]
    public string Role { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
} 