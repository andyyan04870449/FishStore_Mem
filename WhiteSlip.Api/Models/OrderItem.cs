using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WhiteSlip.Api.Models;

public class OrderItem
{
    [Key]
    [Column(Order = 0)]
    [MaxLength(20)]
    public string OrderId { get; set; } = string.Empty;
    
    [Key]
    [Column(Order = 1)]
    public int LineNo { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Sku { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public int Qty { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal UnitPrice { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Subtotal { get; set; }
    
    // Navigation property
    public virtual Order Order { get; set; } = null!;
} 