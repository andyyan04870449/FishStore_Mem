FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5001

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["WhiteSlip.Api.csproj", "./"]
RUN dotnet restore "WhiteSlip.Api.csproj"
COPY . .
RUN dotnet build "WhiteSlip.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WhiteSlip.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WhiteSlip.Api.dll"] 