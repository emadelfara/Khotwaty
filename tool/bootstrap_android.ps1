$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Temp = Join-Path $env:TEMP ("khotwaty-scaffold-" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $Temp | Out-Null
try {
  flutter create --platforms=android --org com.khotwaty --project-name khotwaty $Temp
  New-Item -ItemType Directory -Force -Path (Join-Path $Root "android/gradle") | Out-Null
  Copy-Item (Join-Path $Temp "android/gradle/*") (Join-Path $Root "android/gradle") -Recurse -Force
  Copy-Item (Join-Path $Temp "android/gradlew") (Join-Path $Root "android/gradlew") -Force
  Copy-Item (Join-Path $Temp "android/gradlew.bat") (Join-Path $Root "android/gradlew.bat") -Force
  Write-Host "Android Gradle wrapper installed."
} finally {
  Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue
}
