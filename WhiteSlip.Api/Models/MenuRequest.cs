using System.ComponentModel.DataAnnotations;

namespace WhiteSlip.Api.Models;

public class CreateMenuRequest
{
    [Required]
    public int Version { get; set; }
    
    public string? Description { get; set; }
    
    [Required]
    [MinLength(1, ErrorMessage = "至少需要一個分類")]
    public List<MenuCategoryRequest> Categories { get; set; } = new();
}

public class MenuCategoryRequest
{
    [Required(ErrorMessage = "分類名稱不能為空")]
    [StringLength(100, ErrorMessage = "分類名稱不能超過100個字元")]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public List<MenuItemRequest> Items { get; set; } = new();
}

public class MenuItemRequest
{
    [Required(ErrorMessage = "項目名稱不能為空")]
    [StringLength(200, ErrorMessage = "項目名稱不能超過200個字元")]
    public string Name { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "價格不能為空")]
    [Range(0.01, 99999.99, ErrorMessage = "價格必須在 0.01 到 99999.99 之間")]
    public decimal Price { get; set; }
} 