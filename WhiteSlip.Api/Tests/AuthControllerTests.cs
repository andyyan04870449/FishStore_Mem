using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Moq;
using WhiteSlip.Api.Controllers;
using WhiteSlip.Api.Data;
using WhiteSlip.Api.Models;
using WhiteSlip.Api.Services;
using Xunit;

namespace WhiteSlip.Api.Tests;

public class AuthControllerTests
{
    private readonly Mock<IJwtService> _mockJwtService;
    private readonly Mock<ILogger<AuthController>> _mockLogger;
    private readonly WhiteSlipDbContext _context;
    private readonly AuthController _controller;

    public AuthControllerTests()
    {
        // 設定 In-Memory 資料庫
        var options = new DbContextOptionsBuilder<WhiteSlipDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new WhiteSlipDbContext(options);

        _mockJwtService = new Mock<IJwtService>();
        _mockLogger = new Mock<ILogger<AuthController>>();
        _controller = new AuthController(_context, _mockJwtService.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task Authenticate_WithValidDeviceCode_ShouldReturnSuccess()
    {
        // Arrange
        var request = new AuthRequest { DeviceCode = "TEST123" };
        var expectedToken = "test.jwt.token";
        _mockJwtService.Setup(x => x.GenerateToken(It.IsAny<string>()))
            .Returns(expectedToken);

        // Act
        var result = await _controller.Authenticate(request);

        // Assert
        result.Should().BeOfType<ActionResult<AuthResponse>>();
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var response = okResult.Value.Should().BeOfType<AuthResponse>().Subject;
        response.Success.Should().BeTrue();
        response.Token.Should().Be(expectedToken);
        response.Message.Should().Be("認證成功");
    }

    [Fact]
    public async Task Authenticate_WithInvalidDeviceCode_ShouldReturnBadRequest()
    {
        // Arrange
        var request = new AuthRequest { DeviceCode = "AB" }; // 太短

        // Act
        var result = await _controller.Authenticate(request);

        // Assert
        result.Should().BeOfType<ActionResult<AuthResponse>>();
        var badRequestResult = result.Result.Should().BeOfType<BadRequestObjectResult>().Subject;
        var response = badRequestResult.Value.Should().BeOfType<AuthResponse>().Subject;
        response.Success.Should().BeFalse();
        response.Message.Should().Be("無效的裝置代碼");
    }

    [Fact]
    public async Task UserLogin_WithValidCredentials_ShouldReturnSuccess()
    {
        // Arrange
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Account = "testuser",
            HashedPw = "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3", // "123"
            Role = "Admin",
            CreatedAt = DateTime.UtcNow
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var request = new UserLoginRequest { Account = "testuser", Password = "123" };
        var expectedToken = "test.user.jwt.token";
        _mockJwtService.Setup(x => x.GenerateUserToken(It.IsAny<string>(), It.IsAny<string>()))
            .Returns(expectedToken);

        // Act
        var result = await _controller.UserLogin(request);

        // Assert
        result.Should().BeOfType<ActionResult<UserLoginResponse>>();
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var response = okResult.Value.Should().BeOfType<UserLoginResponse>().Subject;
        response.Success.Should().BeTrue();
        response.Token.Should().Be(expectedToken);
        response.Role.Should().Be("Admin");
        response.Message.Should().Be("登入成功");
    }

    [Fact]
    public async Task UserLogin_WithInvalidCredentials_ShouldReturnUnauthorized()
    {
        // Arrange
        var request = new UserLoginRequest { Account = "nonexistent", Password = "wrong" };

        // Act
        var result = await _controller.UserLogin(request);

        // Assert
        result.Should().BeOfType<ActionResult<UserLoginResponse>>();
        var unauthorizedResult = result.Result.Should().BeOfType<UnauthorizedObjectResult>().Subject;
        var response = unauthorizedResult.Value.Should().BeOfType<UserLoginResponse>().Subject;
        response.Success.Should().BeFalse();
        response.Message.Should().Be("帳號或密碼錯誤");
    }

    [Fact]
    public async Task UserLogin_WithEmptyCredentials_ShouldReturnBadRequest()
    {
        // Arrange
        var request = new UserLoginRequest { Account = "", Password = "" };

        // Act
        var result = await _controller.UserLogin(request);

        // Assert
        result.Should().BeOfType<ActionResult<UserLoginResponse>>();
        var badRequestResult = result.Result.Should().BeOfType<BadRequestObjectResult>().Subject;
        var response = badRequestResult.Value.Should().BeOfType<UserLoginResponse>().Subject;
        response.Success.Should().BeFalse();
        response.Message.Should().Be("帳號或密碼不得為空");
    }

    public void Dispose()
    {
        _context?.Dispose();
    }
} 