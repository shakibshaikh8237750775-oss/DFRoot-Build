# setup.ps1
$ErrorActionPreference = "Stop"

Write-Host "--- Step 1: Generating Keystore ---" -ForegroundColor Cyan
keytool -genkeypair -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dfroot_key -storepass "dfroot123" -keypass "dfroot123" -dname "CN=DFRoot, OU=Dev, O=Dev, L=Delhi, S=Delhi, C=IN"

Write-Host "--- Step 2: Converting to Base64 ---" -ForegroundColor Cyan
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("keystore.jks"))
Set-Content -Path "keystore.b64" -Value $base64

Write-Host "--- Step 3: Creating GitHub Repo ---" -ForegroundColor Cyan
gh repo create DFRoot-Build --private --source=. --remote=origin --push

Write-Host "--- Step 4: Adding Secrets ---" -ForegroundColor Cyan
gh secret set KEYSTORE --body "$base64"
gh secret set KEYSTORE_PASSWORD --body "dfroot123"
gh secret set KEY_ALIAS --body "dfroot_key"
gh secret set KEY_PASSWORD --body "dfroot123"

Write-Host "--- Step 5: Triggering Build ---" -ForegroundColor Cyan
gh workflow run Build

Write-Host "--- DONE! Check https://github.com/$(gh api user -q .login)/DFRoot-Build/actions ---" -ForegroundColor Green