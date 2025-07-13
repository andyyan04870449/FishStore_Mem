using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WhiteSlip.Api.Migrations
{
    /// <inheritdoc />
    public partial class RemoveSkuConstraint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 移除 sku 欄位的 NOT NULL 約束
            migrationBuilder.AlterColumn<string>(
                name: "sku",
                table: "order_items",
                type: "character varying(50)",
                maxLength: 50,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // 恢復 sku 欄位的 NOT NULL 約束
            migrationBuilder.AlterColumn<string>(
                name: "sku",
                table: "order_items",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false);
        }
    }
}
