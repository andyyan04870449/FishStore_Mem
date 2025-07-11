using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "Admin")]
public class UsersController : ControllerBase
{
    private readonly WhiteSlipDbContext _context;
    private readonly ILogger<UsersController> _logger;

    public UsersController(WhiteSlipDbContext context, ILogger<UsersController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<object>> GetUsers()
    {
        var users = await _context.Users.Select(u => new
        {
            u.UserId,
            u.Account,
            u.Role,
            u.CreatedAt
        }).ToListAsync();
        return Ok(users);
    }

    [HttpPost]
    public async Task<ActionResult<object>> CreateUser([FromBody] UserCreateRequest req)
    {
        if (string.IsNullOrWhiteSpace(req.Account) || string.IsNullOrWhiteSpace(req.Password) || string.IsNullOrWhiteSpace(req.Role))
            return BadRequest(new { message = "帳號、密碼、角色皆必填" });
        if (await _context.Users.AnyAsync(u => u.Account == req.Account))
            return Conflict(new { message = "帳號已存在" });
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(req.Password));
        var hashString = BitConverter.ToString(hash).Replace("-", "").ToLower();
        var user = new User
        {
            Account = req.Account,
            HashedPw = hashString,
            Role = req.Role,
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return Ok(new { message = "建立成功", user.UserId });
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<object>> UpdateUser(Guid id, [FromBody] UserUpdateRequest req)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound(new { message = "使用者不存在" });
        if (!string.IsNullOrWhiteSpace(req.Password))
        {
            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(req.Password));
            user.HashedPw = BitConverter.ToString(hash).Replace("-", "").ToLower();
        }
        if (!string.IsNullOrWhiteSpace(req.Role))
            user.Role = req.Role;
        await _context.SaveChangesAsync();
        return Ok(new { message = "更新成功" });
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult<object>> DeleteUser(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound(new { message = "使用者不存在" });
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return Ok(new { message = "刪除成功" });
    }
}

public class UserCreateRequest
{
    public string Account { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}

public class UserUpdateRequest
{
    public string? Password { get; set; }
    public string? Role { get; set; }
} 