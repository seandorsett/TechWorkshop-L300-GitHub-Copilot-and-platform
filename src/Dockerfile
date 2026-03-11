# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build

WORKDIR /src

# Copy project files
COPY ["ZavaStorefront.csproj", "./"]

# Restore dependencies
RUN dotnet restore "ZavaStorefront.csproj"

# Copy source code
COPY . .

# Build application
RUN dotnet build "ZavaStorefront.csproj" -c Release -o /app/build

# Publish
FROM build AS publish
RUN dotnet publish "ZavaStorefront.csproj" -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS runtime

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 dotnet && \
    adduser -D -u 1001 -G dotnet dotnet

# Copy published application from build stage
COPY --from=publish /app/publish .

# Set ownership to non-root user
RUN chown -R dotnet:dotnet /app

# Switch to non-root user
USER dotnet

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Set entrypoint
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
