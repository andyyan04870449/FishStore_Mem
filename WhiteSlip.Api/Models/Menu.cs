using System.ComponentModel.DataAnnotations;

namespace WhiteSlip.Api.Models;

public class Menu
{
    [Key]
    public int Id { get; set; }
    
    [Required]
    public int Version { get; set; }
    
    [Required]
    public string MenuData { get; set; } = string.Empty;
    
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
} 