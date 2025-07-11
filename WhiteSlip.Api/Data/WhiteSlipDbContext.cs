using Microsoft.EntityFrameworkCore;
using WhiteSlip.Api.Models;

namespace WhiteSlip.Api.Data;

public class WhiteSlipDbContext : DbContext
{
    public WhiteSlipDbContext(DbContextOptions<WhiteSlipDbContext> options) : base(options)
    {
    }

    public DbSet<Device> Devices { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Menu> Menus { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Device 配置
        modelBuilder.Entity<Device>(entity =>
        {
            entity.ToTable("devices");
            entity.HasKey(e => e.DeviceId);
            entity.Property(e => e.DeviceId).HasColumnName("device_id");
            entity.Property(e => e.DeviceCode).HasColumnName("device_code").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Jwt).HasColumnName("jwt").IsRequired();
            entity.Property(e => e.LastSeen).HasColumnName("last_seen");
            entity.HasIndex(e => e.DeviceCode).IsUnique();
        });

        // User 配置
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(e => e.UserId);
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Account).HasColumnName("account").HasMaxLength(100).IsRequired();
            entity.Property(e => e.HashedPw).HasColumnName("hashed_pw").IsRequired();
            entity.Property(e => e.Role).HasColumnName("role").HasMaxLength(20).IsRequired();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasIndex(e => e.Account).IsUnique();
        });

        // Menu 配置
        modelBuilder.Entity<Menu>(entity =>
        {
            entity.ToTable("menus");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id").UseIdentityColumn();
            entity.Property(e => e.Version).HasColumnName("version").IsRequired();
            entity.Property(e => e.MenuData).HasColumnName("menu_data").IsRequired();
            entity.Property(e => e.LastUpdated).HasColumnName("last_updated");
        });

        // Order 配置
        modelBuilder.Entity<Order>(entity =>
        {
            entity.ToTable("orders");
            entity.HasKey(e => e.OrderId);
            entity.Property(e => e.OrderId).HasColumnName("order_id").HasMaxLength(20);
            entity.Property(e => e.BusinessDay).HasColumnName("business_day").IsRequired();
            entity.Property(e => e.Total).HasColumnName("total").HasColumnType("decimal(10,2)").IsRequired();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        // OrderItem 配置
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("order_items");
            entity.HasKey(e => new { e.OrderId, e.LineNo });
            entity.Property(e => e.OrderId).HasColumnName("order_id").HasMaxLength(20);
            entity.Property(e => e.LineNo).HasColumnName("line_no");
            entity.Property(e => e.Sku).HasColumnName("sku").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(200).IsRequired();
            entity.Property(e => e.Qty).HasColumnName("qty").IsRequired();
            entity.Property(e => e.UnitPrice).HasColumnName("unit_price").HasColumnType("decimal(10,2)").IsRequired();
            entity.Property(e => e.Subtotal).HasColumnName("subtotal").HasColumnType("decimal(10,2)").IsRequired();

            // 外鍵關係
            entity.HasOne(e => e.Order)
                .WithMany(e => e.OrderItems)
                .HasForeignKey(e => e.OrderId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
} 