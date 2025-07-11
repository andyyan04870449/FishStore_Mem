using FluentAssertions;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WhiteSlip.Api.Models;
using WhiteSlip.Api.Services;
using Xunit;

namespace WhiteSlip.Api.Tests;

public class JwtServiceTests
{
    private readonly JwtSettings _settings;
    private readonly JwtService _jwtService;

    public JwtServiceTests()
    {
        _settings = new JwtSettings
        {
            Secret = "CHANGE_ME_32_BYTE_SECRET_KEY_HERE",
            Issuer = "test-issuer",
            Audience = "test-audience",
            ExpirationHours = 1
        };
        _jwtService = new JwtService(_settings);
    }

    [Fact]
    public void GenerateToken_ShouldReturnValidToken()
    {
        // Arrange
        var deviceId = "test-device-123";

        // Act
        var token = _jwtService.GenerateToken(deviceId);

        // Assert
        token.Should().NotBeNullOrEmpty();
        token.Should().Contain(".");
    }

    [Fact]
    public void GenerateUserToken_ShouldReturnValidToken()
    {
        // Arrange
        var userId = "test-user-123";
        var role = "Admin";

        // Act
        var token = _jwtService.GenerateUserToken(userId, role);

        // Assert
        token.Should().NotBeNullOrEmpty();
        token.Should().Contain(".");
    }

    [Fact]
    public void ValidateToken_WithValidToken_ShouldReturnPrincipal()
    {
        // Arrange
        var deviceId = "test-device-123";
        var token = _jwtService.GenerateToken(deviceId);

        // Act
        var principal = _jwtService.ValidateToken(token);

        // Assert
        principal.Should().NotBeNull();
        principal!.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value.Should().Be(deviceId);
        principal.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value.Should().Be("Device");
    }

    [Fact]
    public void ValidateToken_WithValidUserToken_ShouldReturnPrincipal()
    {
        // Arrange
        var userId = "test-user-123";
        var role = "Admin";
        var token = _jwtService.GenerateUserToken(userId, role);

        // Act
        var principal = _jwtService.ValidateToken(token);

        // Assert
        principal.Should().NotBeNull();
        principal!.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value.Should().Be(userId);
        principal.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value.Should().Be(role);
    }

    [Fact]
    public void ValidateToken_WithInvalidToken_ShouldReturnNull()
    {
        // Arrange
        var invalidToken = "invalid.token.here";

        // Act
        var principal = _jwtService.ValidateToken(invalidToken);

        // Assert
        principal.Should().BeNull();
    }

    [Fact]
    public void ValidateToken_WithExpiredToken_ShouldReturnNull()
    {
        // Arrange
        var invalidToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

        // Act
        var principal = _jwtService.ValidateToken(invalidToken);

        // Assert
        principal.Should().BeNull();
    }
} 