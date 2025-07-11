using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using System.Text;
using WhiteSlip.Api.Data;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "Admin,Manager")]
public class ReportsController : ControllerBase
{
    private readonly WhiteSlipDbContext _context;
    private readonly ILogger<ReportsController> _logger;

    public ReportsController(WhiteSlipDbContext context, ILogger<ReportsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<object>> GetReport([FromQuery] DateTime? from, [FromQuery] DateTime? to)
    {
        try
        {
            var query = _context.Orders.AsQueryable();
            if (from.HasValue)
                query = query.Where(o => o.BusinessDay >= DateOnly.FromDateTime(from.Value));
            if (to.HasValue)
                query = query.Where(o => o.BusinessDay <= DateOnly.FromDateTime(to.Value));
            var orders = await query.ToListAsync();
            var total = orders.Sum(o => o.Total);
            var count = orders.Count;
            return Ok(new
            {
                from,
                to,
                count,
                total,
                orders = orders.Select(o => new
                {
                    o.OrderId,
                    o.BusinessDay,
                    o.Total,
                    o.CreatedAt
                })
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "報表查詢失敗");
            return StatusCode(500, new { message = "報表服務暫時不可用" });
        }
    }

    [HttpGet("csv")]
    public async Task<IActionResult> ExportCsv([FromQuery] DateTime? from, [FromQuery] DateTime? to)
    {
        try
        {
            var query = _context.Orders.AsQueryable();
            if (from.HasValue)
                query = query.Where(o => o.BusinessDay >= DateOnly.FromDateTime(from.Value));
            if (to.HasValue)
                query = query.Where(o => o.BusinessDay <= DateOnly.FromDateTime(to.Value));
            var orders = await query.ToListAsync();
            var sb = new StringBuilder();
            sb.AppendLine("OrderId,BusinessDay,Total,CreatedAt");
            foreach (var o in orders)
            {
                sb.AppendLine($"{o.OrderId},{o.BusinessDay},{o.Total},{o.CreatedAt.ToString("s", CultureInfo.InvariantCulture)}");
            }
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            return File(bytes, "text/csv", "report.csv");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "CSV 匯出失敗");
            return StatusCode(500, new { message = "CSV 匯出失敗" });
        }
    }
} 