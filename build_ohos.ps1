# =============================================================================
# Flass 鸿蒙 (OHOS) 构建脚本
#
# 使用方法：
#   .\build_ohos.ps1          # 运行调试版
#   .\build_ohos.ps1 -Release # 构建 Release 版
# =============================================================================

param(
    [switch]$Release,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

Write-Host "=== Flass 鸿蒙构建脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查是否在项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "错误：请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 检查 pubspec_overrides.yaml 是否存在
if (-not (Test-Path "pubspec_overrides.yaml")) {
    Write-Host "2. 复制 OHOS 依赖配置..." -ForegroundColor Yellow
    if (Test-Path "ohos/pubspec_overrides.yaml") {
        Copy-Item "ohos/pubspec_overrides.yaml" "pubspec_overrides.yaml"
        Write-Host "   已复制 pubspec_overrides.yaml" -ForegroundColor Green
    } else {
        Write-Host "   错误：找不到 ohos/pubspec_overrides.yaml" -ForegroundColor Red
        exit 1
    }
}

# 检查 Flutter OHOS 环境
Write-Host "1. 检查 Flutter OHOS 环境..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    Write-Host "   Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "   错误：找不到 Flutter 命令" -ForegroundColor Red
    exit 1
}

# 清理构建缓存
if ($Clean) {
    Write-Host "2. 清理构建缓存..." -ForegroundColor Yellow
    flutter clean
    Write-Host "   已清理" -ForegroundColor Green
}

# 获取依赖
Write-Host "3. 获取依赖..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "   错误：获取依赖失败" -ForegroundColor Red
    exit 1
}
Write-Host "   依赖获取成功" -ForegroundColor Green

# 构建或运行
if ($Release) {
    Write-Host "4. 构建 Release 版..." -ForegroundColor Yellow
    flutter build hap --release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   错误：构建失败" -ForegroundColor Red
        exit 1
    }
    Write-Host "   构建成功！" -ForegroundColor Green
    Write-Host "   输出路径: build/outputs/default/entry-default-signed.hap" -ForegroundColor Cyan
} else {
    Write-Host "4. 运行调试版..." -ForegroundColor Yellow
    flutter run -d ohos
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
