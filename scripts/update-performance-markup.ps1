$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content (Join-Path $siteRoot 'assets/optimized/manifest.json') -Raw | ConvertFrom-Json
$pages = @(Get-Item (Join-Path $siteRoot 'index.html')) + @(Get-ChildItem (Join-Path $siteRoot 'public') -Filter '*.html')
foreach ($page in $pages) {
  $html = [IO.File]::ReadAllText($page.FullName)
  $prefix = if ($page.Directory.Name -eq 'public') { '../' } else { '' }
  $html = [regex]::Replace($html, '<link\b[^>]*https://fonts\.[^>]*>\s*', '')
  $html = [regex]::Replace($html, '<script src="([^"]*script\.js)"', '<script defer src="$1"')
  $html = $html.Replace('<button class="menu-toggle"', '<button type="button" aria-label="Toggle navigation" class="menu-toggle"')
  $html = [regex]::Replace($html, '<img\b[^>]*>', [System.Text.RegularExpressions.MatchEvaluator]{ param($match)
    $tag = $match.Value
    $src = [regex]::Match($tag, 'src="([^"]+)"').Groups[1].Value
    $source = [Uri]::UnescapeDataString($src) -replace '^\.\./', ''
    $variants = @($manifest | Where-Object source -eq $source | Sort-Object variant)
    if (!$variants.Count) { return $tag }
    $brand = $tag -match 'class="brand-photo"'
    if ($brand) { $variants = @($variants | Select-Object -First 1) }
    elseif ($source -match 'tokpah-headshot') { $variants = @($variants | Where-Object variant -ge 320) }
    $first = $variants[0]
    $url = $prefix + 'assets/optimized/' + [Uri]::EscapeDataString($first.name)
    $tag = $tag.Replace($src, $url)
    $tag = [regex]::Replace($tag, '\s+(width|height|loading|decoding|fetchpriority|srcset|sizes)="[^"]*"', '')
    $attributes = " width=`"$($first.width)`" height=`"$($first.height)`" decoding=`"async`""
    if ($brand) { $attributes += ' fetchpriority="low"' }
    elseif ($source -match 'tokpah-headshot') { $attributes += ' fetchpriority="high" loading="eager"' }
    else { $attributes += ' loading="lazy"' }
    if ($variants.Count -gt 1) {
      $srcset = ($variants | ForEach-Object { $prefix + 'assets/optimized/' + [Uri]::EscapeDataString($_.name) + " $($_.width)w" }) -join ', '
      $sizes = if ($source -match 'tokpah-headshot') { '(max-width: 800px) 240px, 320px' }
        elseif ($source -match 'corevista') { '(max-width: 540px) calc(100vw - 44px), 400px' }
        elseif ($page.Name -eq 'gallery.html') { '(max-width: 600px) calc(100vw - 44px), (max-width: 1180px) calc((100vw - 96px) / 2), 518px' }
        else { '(max-width: 540px) calc(100vw - 44px), (max-width: 800px) calc((100vw - 60px) / 2), 360px' }
      $attributes += " srcset=`"$srcset`" sizes=`"$sizes`""
    }
    return [regex]::Replace($tag, '\s*/?>$', "$attributes />")
  })
  $html = [regex]::Replace($html, 'data-preview="([^"]+)"', [System.Text.RegularExpressions.MatchEvaluator]{ param($match)
    $source = [Uri]::UnescapeDataString($match.Groups[1].Value) -replace '^\.\./', ''
    $preview = $manifest | Where-Object source -eq $source | Select-Object -First 1
    if (!$preview) { return $match.Value }
    return 'data-preview="' + $prefix + 'assets/optimized/' + [Uri]::EscapeDataString($preview.name) + '"'
  })
  [IO.File]::WriteAllText($page.FullName, $html, (New-Object Text.UTF8Encoding($false)))
}
Write-Output "Updated $($pages.Count) pages."
