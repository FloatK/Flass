# =============================================================================
# Flass 常规构建脚本（Android/iOS/Windows/Linux/macOS）
#
# 使用方法：
#   .\build_regular.ps1              # 运行调试版
#   .\build_regular.ps1 -Release     # 构建 Release 版
#   .\build_regular.ps1 -Platform android  # 指定平台
# =============================================================================

param(
    [switch]$Release,
    [switch]$Clean,
    [string]$Platform = "auto"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Flass 常规构建脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "错误：请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 如果存在 pubspec_overrides.yaml，备份并删除
if (Test-Path "pubspec_overrides.yaml") {
    Write-Host "1. 检测到 pubspec_overrides.yaml，正在备份..." -ForegroundColor Yellow
    Copy-Item "pubspec_overrides.yaml" "pubspec_overrides.yaml.ohos"
    Remove-Item "pubspec_overrides.yaml"
    Write-Host "   已备份为 pubspec_overrides.yaml.ohos" -ForegroundColor Green
}

# 清理构建缓存
if ($Clean) {
    Write-Host "2. 清理构建缓存..." -ForegroundColor Yellow
    flutter clean
    Write-Host "   已清理" -ForegroundColor Green
}

# 获取依赖
Write-Host "2. 获取依赖..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "   错误：获取依赖失败" -ForegroundColor Red
    exit 1
}
Write-Host "   依赖获取成功" -ForegroundColor Green

# 构建或运行
if ($Release) {
    Write-Host "3. 构建 Release 版..." -ForegroundColor Yellow
    
    if ($Platform -eq "auto") {
        # 自动检测平台
        if ($IsWindows) {
            flutter build apk --release
        } elseif ($IsMacOS) {
            flutter build ios --release
        } else {
            flutter build linux --release
        }
    } else {
        switch ($Platform) {
            "android" { flutter build apk --release }
            "ios" { flutter build ios --release }
            "windows" { flutter build windows --release }
            "linux" { flutter build linux --release }
            "macos" { flutter build macos --release }
            default {
                Write-Host "   错误：不支持的平台 $Platform" -ForegroundColor Red
                exit 1
            }
        }
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   错误：构建失败" -ForegroundColor Red
        exit 1
    }
    Write-Host "   构建成功！" -ForegroundColor Green
} else {
    Write-Host "3. 运行调试版..." -ForegroundColor Yellow
    flutter run
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
