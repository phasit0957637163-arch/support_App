$outputDir = Join-Path $PSScriptRoot '..\assets'
if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
$outputPath = Join-Path $outputDir 'icon.png'

Add-Type -AssemblyName System.Drawing
$img = New-Object System.Drawing.Bitmap 512,512
$g = [System.Drawing.Graphics]::FromImage($img)
$g.Clear([System.Drawing.Color]::FromArgb(8,16,39))
$brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(0,229,255))
$font = New-Object System.Drawing.Font 'Arial', 160, [System.Drawing.FontStyle]::Bold
$g.DrawString('IT', $font, $brush, 80, 120)
$g.FillEllipse($brush, 70, 320, 372, 116)
$font2 = New-Object System.Drawing.Font 'Arial', 36, [System.Drawing.FontStyle]::Bold
$g.DrawString('IT Support', $font2, [System.Drawing.Brushes]::White, 60, 365)
$img.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$img.Dispose()
Write-Output "Created icon: $outputPath"
