Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)

$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# 1. Arka Planı Temizle
$g.Clear([System.Drawing.Color]::Transparent)

# 2. Squircle (Yuvarlatılmış Kare) Fonksiyonu
function Create-RoundedRectanglePath ($x, $y, $w, $h, $r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

# 3. Dış Squircle ve Gradyan
$margin = 32
$squircleW = $size - ($margin * 2)
$squircleH = $size - ($margin * 2)
$radius = 210

$bgPath = Create-RoundedRectanglePath $margin $margin $squircleW $squircleH $radius

# Gradyan: Derin Gece Mavisi / İndigo (0x1E, 0x1B, 0x4B) -> Mor (0x4F, 0x46, 0xE5) -> Elektrik Moru (0x7C, 0x3A, 0xED)
$rectF = New-Object System.Drawing.RectangleF($margin, $margin, $squircleW, $squircleH)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rectF,
    [System.Drawing.Color]::FromArgb(255, 30, 27, 75),
    [System.Drawing.Color]::FromArgb(255, 79, 70, 229),
    45.0
)
$g.FillPath($bgBrush, $bgPath)

# 4. İç Yumuşak Işıma (Glow Aura)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($bgPath)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(140, 124, 58, 237)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 30, 27, 75))
$g.FillPath($glowBrush, $bgPath)

# 5. Açık Kitap (Open Book) Çizimi
# Sol Sayfa
$leftPage = New-Object System.Drawing.Drawing2D.GraphicsPath
$leftPage.AddBezier(512, 690, 420, 715, 300, 705, 230, 680)
$leftPage.AddLine(230, 680, 230, 500)
$leftPage.AddBezier(230, 500, 300, 525, 420, 535, 512, 510)
$leftPage.CloseFigure()

$pageGradLeft = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(230, 500)),
    (New-Object System.Drawing.PointF(512, 700)),
    [System.Drawing.Color]::FromArgb(250, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(220, 224, 231, 255)
)
$g.FillPath($pageGradLeft, $leftPage)

# Sağ Sayfa
$rightPage = New-Object System.Drawing.Drawing2D.GraphicsPath
$rightPage.AddBezier(512, 690, 604, 715, 724, 705, 794, 680)
$rightPage.AddLine(794, 680, 794, 500)
$rightPage.AddBezier(794, 500, 724, 525, 604, 535, 512, 510)
$rightPage.CloseFigure()

$pageGradRight = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(512, 500)),
    (New-Object System.Drawing.PointF(794, 700)),
    [System.Drawing.Color]::FromArgb(240, 243, 248, 255),
    [System.Drawing.Color]::FromArgb(210, 216, 245, 255)
)
$g.FillPath($pageGradRight, $rightPage)

# Kitap Omurgası ve Sayfa Çizgileri
$spinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 99, 102, 241), 6)
$g.DrawLine($spinePen, 512, 506, 512, 700)

$linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 99, 102, 241), 4)
# Sol sayfa satırları
$g.DrawLine($linePen, 290, 545, 470, 535)
$g.DrawLine($linePen, 280, 585, 475, 575)
$g.DrawLine($linePen, 275, 625, 480, 615)
# Sağ sayfa satırları
$g.DrawLine($linePen, 545, 535, 735, 545)
$g.DrawLine($linePen, 540, 575, 745, 585)
$g.DrawLine($linePen, 535, 615, 750, 625)

# 6. Kitaptan Yükselen AI Beyin & Sinir Ağı Düğümleri (Neural Network Nodes)
# Düğüm koordinatları
$nodes = @(
    @{X=512; Y=310; R=26; Color=[System.Drawing.Color]::FromArgb(255, 251, 191, 36)}, # Merkez Parlak Lider Düğüm
    @{X=390; Y=370; R=18; Color=[System.Drawing.Color]::FromArgb(255, 56, 189, 248)},
    @{X=634; Y=370; R=18; Color=[System.Drawing.Color]::FromArgb(255, 56, 189, 248)},
    @{X=330; Y=270; R=16; Color=[System.Drawing.Color]::FromArgb(255, 168, 85, 247)},
    @{X=694; Y=270; R=16; Color=[System.Drawing.Color]::FromArgb(255, 168, 85, 247)},
    @{X=430; Y=210; R=17; Color=[System.Drawing.Color]::FromArgb(255, 52, 211, 153)},
    @{X=594; Y=210; R=17; Color=[System.Drawing.Color]::FromArgb(255, 52, 211, 153)},
    @{X=512; Y=170; R=22; Color=[System.Drawing.Color]::FromArgb(255, 244, 63, 94)}
)

# Bağlantı Çizgileri
$connPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 147, 197, 253), 5)
$connPen.DashCap = [System.Drawing.Drawing2D.DashCap]::Round

# Bağlantılar
$g.DrawLine($connPen, 512, 510, 512, 310) # Kitaptan beyne enerji sütunu
$g.DrawLine($connPen, 512, 310, 390, 370)
$g.DrawLine($connPen, 512, 310, 634, 370)
$g.DrawLine($connPen, 390, 370, 330, 270)
$g.DrawLine($connPen, 634, 370, 694, 270)
$g.DrawLine($connPen, 330, 270, 430, 210)
$g.DrawLine($connPen, 694, 270, 594, 210)
$g.DrawLine($connPen, 430, 210, 512, 170)
$g.DrawLine($connPen, 594, 210, 512, 170)
$g.DrawLine($connPen, 430, 210, 594, 210)
$g.DrawLine($connPen, 390, 370, 512, 170)
$g.DrawLine($connPen, 634, 370, 512, 170)

# Düğümleri Çiz
foreach ($node in $nodes) {
    # Dış Işıma
    $haloBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, $node.Color.R, $node.Color.G, $node.Color.B))
    $g.FillEllipse($haloBrush, ($node.X - $node.R - 12), ($node.Y - $node.R - 12), (($node.R + 12) * 2), (($node.R + 12) * 2))

    # Ana Düğüm
    $nodeBrush = New-Object System.Drawing.SolidBrush($node.Color)
    $g.FillEllipse($nodeBrush, ($node.X - $node.R), ($node.Y - $node.R), ($node.R * 2), ($node.R * 2))

    # Merkez Beyaz Nokta
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 255, 255, 255))
    $g.FillEllipse($whiteBrush, ($node.X - [int]($node.R/2.5)), ($node.Y - [int]($node.R/2.5)), ([int]($node.R * 0.8)), ([int]($node.R * 0.8)))
}

# 7. Yapay Zekâ Işık Kıvılcımları (Sparkle Stars)
function Draw-Star ($cx, $cy, $radius, $color) {
    $pts = @(
        (New-Object System.Drawing.PointF($cx, ($cy - $radius))),
        (New-Object System.Drawing.PointF(($cx + $radius * 0.25), ($cy - $radius * 0.25))),
        (New-Object System.Drawing.PointF(($cx + $radius), $cy)),
        (New-Object System.Drawing.PointF(($cx + $radius * 0.25), ($cy + $radius * 0.25))),
        (New-Object System.Drawing.PointF($cx, ($cy + $radius))),
        (New-Object System.Drawing.PointF(($cx - $radius * 0.25), ($cy + $radius * 0.25))),
        (New-Object System.Drawing.PointF(($cx - $radius), $cy)),
        (New-Object System.Drawing.PointF(($cx - $radius * 0.25), ($cy - $radius * 0.25)))
    )
    $starPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $starPath.AddPolygon($pts)
    $starBrush = New-Object System.Drawing.SolidBrush($color)
    $g.FillPath($starBrush, $starPath)
}

Draw-Star 210 320 28 ([System.Drawing.Color]::FromArgb(240, 251, 191, 36))
Draw-Star 814 320 28 ([System.Drawing.Color]::FromArgb(240, 56, 189, 248))
Draw-Star 512 800 24 ([System.Drawing.Color]::FromArgb(220, 168, 85, 247))
Draw-Star 512 310 18 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255))

# 8. İkon Çerçeve Parlaması (Subtle Border)
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 4)
$g.DrawPath($borderPen, $bgPath)

# 9. Dosyayı Kaydet
$outputDir = "C:\Users\Semih\Desktop\Myless\smart_study_assistant\assets\images"
$outputPath = Join-Path $outputDir "app_logo.png"
$bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Logo basariyla olusturuldu: $outputPath"

# 10. Android Mipmap İkonlarını Yeniden Boyutlandırarak Kaydet
$mipmapSizes = @{
    "mipmap-mdpi" = 48;
    "mipmap-hdpi" = 72;
    "mipmap-xhdpi" = 96;
    "mipmap-xxhdpi" = 144;
    "mipmap-xxxhdpi" = 192;
}

$resBaseDir = "C:\Users\Semih\Desktop\Myless\smart_study_assistant\android\app\src\main\res"

foreach ($entry in $mipmapSizes.GetEnumerator()) {
    $folderName = $entry.Key
    $targetSize = $entry.Value
    $folderPath = Join-Path $resBaseDir $folderName
    
    if (Test-Path $folderPath) {
        $resizedBmp = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
        $rg = [System.Drawing.Graphics]::FromImage($resizedBmp)
        $rg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $rg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $rg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $rg.DrawImage($bmp, 0, 0, $targetSize, $targetSize)
        $rg.Dispose()
        
        $launcherPath = Join-Path $folderPath "ic_launcher.png"
        $resizedBmp.Save($launcherPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $resizedBmp.Dispose()
        Write-Host "Android ikonu guncellendi: $launcherPath ($targetSize x $targetSize)"
    }
}

$g.Dispose()
$bmp.Dispose()
