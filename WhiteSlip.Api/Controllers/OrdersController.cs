using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly WhiteSlipDbContext _context;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(WhiteSlipDbContext context, ILogger<OrdersController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpPost("bulk")]
    [Authorize(Policy = "DeviceActive")]
    public async Task<ActionResult<object>> BulkUpload([FromBody] List<OrderRequest> orders)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("批次訂單上傳: DeviceId={DeviceId}, Count={Count}", deviceId, orders.Count);

            var results = new List<OrderResult>();
            var successCount = 0;
            var duplicateCount = 0;
            var errorCount = 0;

            foreach (var orderRequest in orders)
            {
                try
                {
                    // 檢查訂單是否已存在
                    var existingOrder = await _context.Orders
                        .FirstOrDefaultAsync(o => o.OrderId == orderRequest.OrderId);

                    if (existingOrder != null)
                    {
                        results.Add(new OrderResult
                        {
                            OrderId = orderRequest.OrderId,
                            Success = false,
                            Message = "訂單已存在"
                        });
                        duplicateCount++;
                        continue;
                    }

                    // 創建新訂單
                    var order = new Order
                    {
                        OrderId = orderRequest.OrderId,
                        BusinessDay = DateOnly.FromDateTime(orderRequest.BusinessDay),
                        Total = orderRequest.Total,
                        CreatedAt = DateTime.SpecifyKind(orderRequest.CreatedAt, DateTimeKind.Utc)
                    };

                    _context.Orders.Add(order);

                    // 創建訂單項目
                    for (int i = 0; i < orderRequest.Items.Count; i++)
                    {
                        var item = orderRequest.Items[i];
                        var orderItem = new OrderItem
                        {
                            OrderId = orderRequest.OrderId,
                            LineNo = i + 1,
                            Name = item.Name,
                            Qty = item.Qty,
                            UnitPrice = item.UnitPrice,
                            Subtotal = item.Subtotal
                        };

                        _context.OrderItems.Add(orderItem);
                    }

                    results.Add(new OrderResult
                    {
                        OrderId = orderRequest.OrderId,
                        Success = true,
                        Message = "訂單創建成功"
                    });
                    successCount++;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "處理訂單 {OrderId} 時發生錯誤", orderRequest.OrderId);
                    results.Add(new OrderResult
                    {
                        OrderId = orderRequest.OrderId,
                        Success = false,
                        Message = "處理失敗"
                    });
                    errorCount++;
                }
            }

            // 保存所有變更
            await _context.SaveChangesAsync();

            _logger.LogInformation("批次訂單處理完成: 成功={Success}, 重複={Duplicate}, 錯誤={Error}", 
                successCount, duplicateCount, errorCount);

            return Ok(new
            {
                summary = new
                {
                    total = orders.Count,
                    success = successCount,
                    duplicate = duplicateCount,
                    error = errorCount
                },
                results = results
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "批次訂單處理過程中發生錯誤");
            return StatusCode(500, new { message = "訂單處理服務暫時不可用" });
        }
    }

    [HttpGet]
    [Authorize(Policy = "DeviceActive")]
    public async Task<ActionResult<object>> GetOrders(
        [FromQuery] string? orderId,
        [FromQuery] DateTime? businessDay,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("訂單查詢: DeviceId={DeviceId}, OrderId={OrderId}, BusinessDay={BusinessDay}, StartDate={StartDate}, EndDate={EndDate}", 
                deviceId, orderId, businessDay, startDate, endDate);

            var query = _context.Orders.AsQueryable();

            // 訂單編號篩選
            if (!string.IsNullOrWhiteSpace(orderId))
                query = query.Where(o => o.OrderId.Contains(orderId));

            // 營業日期篩選
            if (businessDay.HasValue)
                query = query.Where(o => o.BusinessDay == DateOnly.FromDateTime(businessDay.Value));

            // 日期範圍篩選
            if (startDate.HasValue)
                query = query.Where(o => o.BusinessDay >= DateOnly.FromDateTime(startDate.Value));

            if (endDate.HasValue)
                query = query.Where(o => o.BusinessDay <= DateOnly.FromDateTime(endDate.Value));

            var totalCount = await query.CountAsync();
            var orders = await query
                .OrderByDescending(o => o.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Include(o => o.OrderItems)
                .ToListAsync();

            var result = orders.Select(o => new
                {
                    o.OrderId,
                    o.BusinessDay,
                    o.Total,
                o.CreatedAt,
                Items = o.OrderItems.Select(oi => new
                {
                    oi.Name,
                    oi.Qty,
                    oi.UnitPrice,
                    oi.Subtotal
                }).ToList()
            }).ToList();

            return Ok(new
            {
                data = result,
                    page,
                    pageSize,
                total = totalCount
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "訂單查詢過程中發生錯誤");
            return StatusCode(500, new { message = "訂單查詢服務暫時不可用" });
        }
    }

    [HttpPost("{orderId}/reprint")]
    [Authorize(Policy = "DeviceActive")]
    public async Task<ActionResult<object>> ReprintOrder(string orderId)
    {
        try
        {
            var deviceId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            _logger.LogInformation("重新列印訂單請求: DeviceId={DeviceId}, OrderId={OrderId}", deviceId, orderId);

            // 檢查訂單是否存在
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return NotFound(new { message = "訂單不存在" });
            }

            // 這裡可以添加實際的列印邏輯
            // 目前只是記錄日誌
            _logger.LogInformation("重新列印訂單: {OrderId}, 總計: {Total}", orderId, order.Total);

            return Ok(new { 
                message = "重新列印成功",
                orderId = orderId,
                total = order.Total
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "重新列印訂單時發生錯誤: {OrderId}", orderId);
            return StatusCode(500, new { message = "重新列印服務暫時不可用" });
        }
    }
}

public class OrderRequest
{
    public string OrderId { get; set; } = string.Empty;
    public DateTime BusinessDay { get; set; }
    public decimal Total { get; set; }
    public DateTime CreatedAt { get; set; }
    public List<OrderItemRequest> Items { get; set; } = new();
}

public class OrderItemRequest
{
    public string Name { get; set; } = string.Empty;
    public int Qty { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal Subtotal { get; set; }
}

public class OrderResult
{
    public string OrderId { get; set; } = string.Empty;
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
} 