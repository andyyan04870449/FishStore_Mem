using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WhiteSlip.Api.Models;

public class Order
{
    [Key]
    [MaxLength(20)]
    public string OrderId { get; set; } = string.Empty;
    
    [Required]
    public DateOnly BusinessDay { get; set; }
    
    [Required]
    [Column(TypeName = "decimal(10,2)")]
    public decimal Total { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation property
    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
} 