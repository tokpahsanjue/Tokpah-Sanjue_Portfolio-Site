$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$siteRoot = Split-Path $PSScriptRoot -Parent
$output = Join-Path $siteRoot 'assets/optimized'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$quality = New-Object System.Drawing.Imaging.EncoderParameters(1)
$quality.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]78)
$sources = @(Get-ChildItem (Join-Path $siteRoot 'assets/gallery') -File | Where-Object Extension -Match '^\.(jpg|jpeg|png)$')
$sources += Get-Item (Join-Path $siteRoot 'assets/tokpah-headshot.png'), (Join-Path $siteRoot 'assets/corevista-dark.png')
$sources += Get-ChildItem (Join-Path $siteRoot 'assets/certificates/previews') -File -Filter '*.png'
$records = @()
foreach ($file in $sources) {
  $image = [System.Drawing.Image]::FromFile($file.FullName)
  try {
    # Apply camera orientation before removing metadata from resized exports.
    if ($image.PropertyIdList -contains 274) {
      $orientation = $image.GetPropertyItem(274).Value[0]
      $rotations = @{2=4;3=2;4=6;5=5;6=1;7=7;8=3}
      if ($rotations.ContainsKey([int]$orientation)) { $image.RotateFlip($rotations[[int]$orientation]) }
    }
    $stem = $file.BaseName
    $widths = @(480,960)
    if ($stem -eq 'tokpah-headshot') { $widths = @(72,320,640) }
    if ($file.Directory.Name -eq 'previews') { $widths = @(1400) }
    if ($stem -eq 'corevista-dark') { $widths = @(400,800) }
    foreach ($limit in $widths) {
      $width = [Math]::Min($limit, $image.Width)
      $height = [Math]::Max(1, [int][Math]::Round($image.Height * $width / $image.Width))
      $bitmap = New-Object System.Drawing.Bitmap($width, $height)
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.Clear([System.Drawing.Color]::White)
        if ($stem -eq 'corevista-dark') { $graphics.Clear([System.Drawing.Color]::Transparent) }
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $width, $height)
        $name = "$stem-$limit.jpg"
        if ($stem -eq 'corevista-dark') {
          $name = "$stem-$limit.png"
          $bitmap.Save((Join-Path $output $name), [System.Drawing.Imaging.ImageFormat]::Png)
        } else { $bitmap.Save((Join-Path $output $name), $encoder, $quality) }
        $records += [pscustomobject]@{ source=$file.FullName.Substring($siteRoot.Length+1).Replace('\','/'); name=$name; width=$width; height=$height; originalBytes=$file.Length; bytes=(Get-Item (Join-Path $output $name)).Length; variant=$limit }
      } finally { $graphics.Dispose(); $bitmap.Dispose() }
    }
  } finally { $image.Dispose() }
}
$records | ConvertTo-Json | Set-Content (Join-Path $output 'manifest.json') -Encoding UTF8
Write-Output "Generated $($records.Count) image variants."
