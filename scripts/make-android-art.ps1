# Regenerates the Android launcher icons and splash screens from VAdo.jpg.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File scripts\make-android-art.ps1
$root = Split-Path $PSScriptRoot -Parent
$res = Join-Path $root "android\app\src\main\res"
Add-Type -AssemblyName System.Drawing

$src = New-Object Drawing.Bitmap (Join-Path $root "VAdo.jpg")
$clay = [Drawing.ColorTranslator]::FromHtml("#e7d4c4")
$paper = [Drawing.ColorTranslator]::FromHtml("#f6f0e6")

function New-Canvas($w, $h) {
  $b = New-Object Drawing.Bitmap $w, $h, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($b)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'; $g.SmoothingMode = 'AntiAlias'
  return @($b, $g)
}
# Square crop of Vicky's face; $size is the source square size (bigger = more hair and wall around her).
function Face-Rect($size) {
  $cx = 384; $cy = 454
  $x = [Math]::Max(0, [Math]::Min(768 - $size, $cx - $size / 2))
  return New-Object Drawing.Rectangle ([int]$x), ([int]($cy - $size / 2)), $size, $size
}
function Draw-Face($g, $dest, $size, $shape) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  if ($shape -eq 'circle') { $path.AddEllipse($dest) }
  elseif ($shape -eq 'rounded') {
    $r = [int]($dest.Width * 0.22); $d = $r * 2
    $path.AddArc($dest.X, $dest.Y, $d, $d, 180, 90)
    $path.AddArc($dest.Right - $d, $dest.Y, $d, $d, 270, 90)
    $path.AddArc($dest.Right - $d, $dest.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($dest.X, $dest.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
  } else { $path.AddRectangle($dest) }
  $g.SetClip($path)
  $g.DrawImage($src, $dest, (Face-Rect $size), 'Pixel')
  $g.ResetClip()
}

$dens = @{ mdpi = 1; hdpi = 1.5; xhdpi = 2; xxhdpi = 3; xxxhdpi = 4 }
foreach ($d in $dens.Keys) {
  $s = $dens[$d]; $dir = Join-Path $res "mipmap-$d"
  # Adaptive icon foreground: full-bleed 108dp; launchers show roughly the middle 66-72dp.
  $fg = [int](108 * $s); $c = New-Canvas $fg $fg
  Draw-Face $c[1] (New-Object Drawing.Rectangle 0, 0, $fg, $fg) 768 'square'
  $c[1].Dispose(); $c[0].Save((Join-Path $dir "ic_launcher_foreground.png")); $c[0].Dispose()
  # Legacy icons for older launchers.
  $ic = [int](48 * $s)
  foreach ($kind in @(@{ n = 'ic_launcher.png'; shape = 'rounded' }, @{ n = 'ic_launcher_round.png'; shape = 'circle' })) {
    $c = New-Canvas $ic $ic
    Draw-Face $c[1] (New-Object Drawing.Rectangle 0, 0, $ic, $ic) 600 $kind.shape
    $c[1].Dispose(); $c[0].Save((Join-Path $dir $kind.n)); $c[0].Dispose()
  }
}

# Splash screens: clay background with Vicky's face in a paper-rimmed circle.
Get-ChildItem $res -Recurse -Filter splash.png | ForEach-Object {
  $old = [Drawing.Image]::FromFile($_.FullName); $w = $old.Width; $h = $old.Height; $old.Dispose()
  $c = New-Canvas $w $h; $g = $c[1]
  $g.Clear($clay)
  $dia = [int]([Math]::Min($w, $h) * 0.42); $rim = [int]($dia * 0.035)
  $x = [int](($w - $dia) / 2); $y = [int](($h - $dia) / 2)
  $g.FillEllipse((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(40, 120, 78, 52))), $x, ($y + $rim * 2), $dia, $dia)
  $g.FillEllipse((New-Object Drawing.SolidBrush $paper), $x, $y, $dia, $dia)
  Draw-Face $g (New-Object Drawing.Rectangle ($x + $rim), ($y + $rim), ($dia - 2 * $rim), ($dia - 2 * $rim)) 640 'circle'
  $g.Dispose(); $c[0].Save($_.FullName); $c[0].Dispose()
}
$src.Dispose()
"Android icons and splash screens regenerated."
