using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WhiteSlip.Api.Models;

public class Menu
{
    [Key]
    [MaxLength(50)]
    public string Sku { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Price { get; set; }
    
    [MaxLength(100)]
    public string? Category { get; set; }
    
    public int Version { get; set; } = 1;
    
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
} 