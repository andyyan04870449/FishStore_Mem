using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Data;

public static class DbInitializer
{
    public static async Task Initialize(WhiteSlipDbContext context)
    {
        // 確保資料庫已建立
        await context.Database.EnsureCreatedAsync();

        // 檢查是否已有管理員帳號
        if (!await context.Users.AnyAsync(u => u.Role == "Admin"))
        {
            // 建立預設管理員帳號
            var adminPassword = "admin123"; // 預設密碼
            var hash = SHA256.HashData(Encoding.UTF8.GetBytes(adminPassword));
            var hashString = BitConverter.ToString(hash).Replace("-", "").ToLower();

            var adminUser = new User
            {
                Account = "admin",
                HashedPw = hashString,
                Role = "Admin",
                CreatedAt = DateTime.UtcNow
            };

            context.Users.Add(adminUser);
            await context.SaveChangesAsync();

            Console.WriteLine("已建立預設管理員帳號：admin / admin123");
        }

        // 檢查是否已有測試裝置
        if (!await context.Devices.AnyAsync())
        {
            var testDevice = new Device
            {
                DeviceCode = "TEST123",
                DeviceName = "測試裝置",
                Status = DeviceStatus.Active,
                LastSeen = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
                ActivatedAt = DateTime.UtcNow
            };

            context.Devices.Add(testDevice);
            await context.SaveChangesAsync();

            Console.WriteLine("已建立測試裝置：TEST123");
        }
    }
} 