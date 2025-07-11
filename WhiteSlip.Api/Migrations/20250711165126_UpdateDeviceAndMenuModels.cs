using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace WhiteSlip.Api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDeviceAndMenuModels : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_menus",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "sku",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "category",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "name",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "price",
                table: "menus");

            migrationBuilder.RenameColumn(
                name: "updated_at",
                table: "menus",
                newName: "last_updated");

            migrationBuilder.AddColumn<int>(
                name: "id",
                table: "menus",
                type: "integer",
                nullable: false,
                defaultValue: 0)
                .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn);

            migrationBuilder.AddColumn<string>(
                name: "menu_data",
                table: "menus",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "device_code",
                table: "devices",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_menus",
                table: "menus",
                column: "id");

            migrationBuilder.CreateIndex(
                name: "IX_devices_device_code",
                table: "devices",
                column: "device_code",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_menus",
                table: "menus");

            migrationBuilder.DropIndex(
                name: "IX_devices_device_code",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "id",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "menu_data",
                table: "menus");

            migrationBuilder.DropColumn(
                name: "device_code",
                table: "devices");

            migrationBuilder.RenameColumn(
                name: "last_updated",
                table: "menus",
                newName: "updated_at");

            migrationBuilder.AddColumn<string>(
                name: "sku",
                table: "menus",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "category",
                table: "menus",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "name",
                table: "menus",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "price",
                table: "menus",
                type: "numeric(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddPrimaryKey(
                name: "PK_menus",
                table: "menus",
                column: "sku");
        }
    }
}
