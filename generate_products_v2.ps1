$baseDir = "d:\tao web\đồng phục bóng đá"
$imagesDir = "$baseDir\images_bong_da"
$productsDir = "$baseDir"

# Update footer contact info in the template and root files
$filesToUpdate = @(
    "$baseDir\index.html",
    "$baseDir\san-bong-da-mini.html",
    "$baseDir\blog.html",
    "$baseDir\ao-bong-da-aura-a10.html"
)

foreach ($f in $filesToUpdate) {
    if (Test-Path $f) {
        $content = Get-Content -Path $f -Raw -Encoding UTF8
        $content = $content -replace '0988\.XXX\.XXX', '0934.975.913'
        $content = $content -replace 'Zalo: Đồng Phục Bóng Đá', 'Zalo: 0934.975.913'
        $content = $content -replace 'info@dongphucbongda\.com', 'mrslinh@inaodongphucmrslinh.com'
        Set-Content -Path $f -Value $content -Encoding UTF8
    }
}

# The template will just be ao-bong-da-aura-a10.html which we just updated!
$templateHtml = Get-Content "$baseDir\ao-bong-da-aura-a10.html" -Raw -Encoding UTF8

# we need to find the gallery and main image blocks to replace them.
# Title: <title>Áo Bóng Đá AURA Mẫu A10 | Đồng Phục Bóng Đá</title>
# H1: <h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">Mẫu Áo Bóng Đá A10</h1>
# Brand Badge: <span class="badge">AURA</span>
# Description model: Mẫu <strong>A10</strong> nổi bật
# Main Image: <img src="images_bong_da/QUẦN ÁO BÓNG ĐÁ AURA/AURA - A10 (A - 10)/24._AURA_-_A10.png"
# Gallery: <div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;"> ... </div>

# The regex approach works, but splitting by a known marker is easier
# We will use Regex to replace specific bounds

$allProducts = @()

$brands = Get-ChildItem -Path $imagesDir -Directory
foreach ($brandFolder in $brands) {
    $models = Get-ChildItem -Path $brandFolder.FullName -Directory
    # Clean brand name
    $brandClean = $brandFolder.Name -replace '(?i)nhãn hàng\s+', '' -replace 'QUẦN ÁO BÓNG ĐÁ\s*', '' -replace '^\s*-\s*', ''
    $brandClean = $brandClean.Trim()
    
    foreach ($modelFolder in $models) {
        $images = @(Get-ChildItem -Path $modelFolder.FullName -File -Include *.png,*.jpg,*.jpeg,*.webp -Recurse)
        if ($images.Count -eq 0) { continue }
        
        $mainImgRel = $images[0].FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
        
        $galleryHtml = ""
        $count = 0
        foreach ($img in $images) {
            if ($count -ge 5) { break }
            $imgRel = $img.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $galleryHtml += '             <img src="{0}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 1px solid rgba(255,255,255,0.1);">' -f $imgRel
            $galleryHtml += "`n"
            $count++
        }
        
        $title = $modelFolder.Name.Trim()
        
        # Don't recreate a10 if it's the exact same title or something, but we'll overwrite it anyway.
        $slugName = $title -replace '[^a-zA-Z0-9]+', '-'
        $slugName = $slugName.ToLower().Trim("-")
        $fileName = "$slugName.html"
        $filePath = "$productsDir\$fileName"
        
        # Make the page HTML
        $pageHtml = $templateHtml
        
        # Replace Main Image - we use a regex to match the main image
        $pageHtml = $pageHtml -replace '(?s)<img src="images_bong_da/QUẦN ÁO BÓNG ĐÁ AURA/AURA - A10 \(A - 10\)/24._AURA_-_A10.png" alt="[^"]*" style="width: 100%; border-radius: 12px; box-shadow:[^"]*">', ('<img src="{0}" alt="{1}" style="width: 100%; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,255,135,0.2);">' -f $mainImgRel, $title)
        
        # Replace Gallery
        $pageHtml = $pageHtml -replace '(?s)<div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">.*?</div>(?=\s*</div>\s*<div>\s*<span class="badge">)', ('<div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">' + "`n" + $galleryHtml + '          </div>')
        
        # Replace Title and H1
        $pageHtml = $pageHtml -replace '<title>.*?</title>', ("<title>Áo Bóng Đá $title | Đồng Phục Bóng Đá</title>")
        $pageHtml = $pageHtml -replace '<span class="badge">.*?</span>', ("<span class=`"badge`">$brandClean</span>")
        $pageHtml = $pageHtml -replace '<h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">.*?</h1>', ("<h1 style=`"font-size: 42px; font-weight: 800; margin: 15px 0;`">$title</h1>")
        $pageHtml = $pageHtml -replace 'Mẫu <strong>A10</strong> nổi bật', ("Mẫu <strong>$title</strong> nổi bật")
        
        Set-Content -Path $filePath -Value $pageHtml -Encoding UTF8
        
        $allProducts += [PSCustomObject]@{
            Title = $title
            Slug = $fileName
            Thumbnail = $mainImgRel
            Brand = $brandClean
        }
    }
}

Write-Host "Generated $($allProducts.Count) product articles."

# Now update index.html 's grid section.
$indexPath = "$baseDir\index.html"
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8

$startMarker = '<div class="grid">'
$endMarker = '      </div>
      <div style="text-align: center; margin-top: 40px;">'
      
$startIndex = $indexContent.IndexOf('<h2>Bộ Sưu Tập')
if ($startIndex -gt 0) {
    # Find the nearest grid after the section header
    $startGrid = $indexContent.IndexOf('<div class="grid">', $startIndex)
    # The end is the closing div of grid, but it's tricky to find correctly without parser.
    # We will just replace everything between <!-- PRODUCTS SECTION --> and <!-- LATEST NEWS TEASER -->
}

$startMarkerReal = "<!-- PRODUCTS SECTION -->"
$endMarkerReal = "<!-- LATEST NEWS TEASER -->"

$sIdx = $indexContent.IndexOf($startMarkerReal)
$eIdx = $indexContent.IndexOf($endMarkerReal)

if ($sIdx -gt 0 -and $eIdx -gt $sIdx) {
    $cardsHtml = ""
    # Render all products (or up to 24)
    foreach ($p in $allProducts | Select-Object -First 24) {
        $cardsHtml += @"
        <div class="product-card">
          <img src="$($p.Thumbnail)" alt="$($p.Title)" class="product-img">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">$($p.Brand)</span>
            <h3 style="margin-top: 5px; font-size: 18px;">$($p.Title)</h3>
            <div class="product-price">180.000đ - 250.000đ</div>
            <a href="$($p.Slug)" class="btn btn-primary" style="padding: 10px 20px; font-size: 12px; width: 100%;">Tùy Chỉnh & Đặt Hàng</a>
          </div>
        </div>
"@
    }
    
    $replacement = @"
<!-- PRODUCTS SECTION -->
  <section id="san-pham" class="section">
    <div class="container">
      <div class="section-header">
        <h2>Bộ Sưu Tập <span>Đồng Phục Bóng Đá 2026</span></h2>
        <p>Những mẫu thiết kế đặc sắc chuyên nghiệp từ các thương hiệu hàng đầu</p>
      </div>
      <div class="grid">
$cardsHtml
      </div>
    </div>
  </section>

  
"@

    $newIndex = $indexContent.Substring(0, $sIdx) + $replacement + $indexContent.Substring($eIdx)
    Set-Content -Path $indexPath -Value $newIndex -Encoding UTF8
    Write-Host "index.html updated successfully with $($allProducts.Count) products."
} else {
    Write-Host "Coult not update index.html, markers not found"
}
