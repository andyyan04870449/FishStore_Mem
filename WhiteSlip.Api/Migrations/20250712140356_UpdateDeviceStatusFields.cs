using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WhiteSlip.Api.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDeviceStatusFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "activated_at",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "created_at",
                table: "devices",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "deleted_at",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "device_name",
                table: "devices",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "disabled_at",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "status",
                table: "devices",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "activated_at",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "created_at",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "deleted_at",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "device_name",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "disabled_at",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "status",
                table: "devices");
        }
    }
}
