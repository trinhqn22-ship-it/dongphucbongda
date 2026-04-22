$baseDir = "d:\tao web\đồng phục bóng đá"
$imagesDir = "$baseDir\images_bong_da"
$productsDir = "$baseDir\san-pham"
$indexPath = "$baseDir\index.html"

if (-Not (Test-Path $productsDir)) {
    New-Item -ItemType Directory -Path $productsDir | Out-Null
}

$productTemplate = @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{0} | Đồng Phục Bóng Đá</title>
  <meta name="description" content="Khám phá mẫu áo bóng đá {0} - chất liệu cao cấp, form chuẩn thể thao.">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>

  <!-- HEADER -->
  <header>
    <div class="container nav-wrapper">
      <a href="../index.html" class="logo">
        Đồng Phục<span>Bóng Đá</span>
      </a>
      <nav class="nav-links">
        <a href="../index.html">Trang Chủ</a>
        <a href="../index.html#san-pham" class="active">Sản Phẩm</a>
        <a href="../san-bong-da-mini.html">Sân Bóng Mini 2026</a>
        <a href="../blog.html">Tin Thể Thao</a>
        <a href="#lien-he">Liên Hệ</a>
      </nav>
      <div class="header-cta">
        <a href="#lien-he" class="btn">Đặt Hàng Ngay</a>
      </div>
    </div>
  </header>

  <section class="section" style="padding-top: 150px;">
    <div class="container">
      <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 50px;">
        <div>
          <img src="{2}" alt="{0}" style="width: 100%; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,255,135,0.2);">
          
          <div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">
{3}
          </div>
        </div>
        <div>
          <span class="badge">{1}</span>
          <h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">{0}</h1>
          <div style="color: var(--primary-color); font-size: 28px; font-weight: bold; margin-bottom: 30px;">180.000đ - 250.000đ / Bộ</div>
          
          <p style="color: var(--text-muted); font-size: 18px; margin-bottom: 20px;">
            Mẫu <strong>{0}</strong> nổi bật với thiết kế đột phá, mang tinh thần thể thao mạnh mẽ. 
            Được sản xuất từ chất liệu vải thun lạnh thể thao siêu cao cấp, giúp người mặc luôn cảm thấy mát mẻ và thoáng khí kể cả khi vận động cường độ cao.
          </p>
          
          <ul style="color: var(--text-muted); margin-bottom: 40px; padding-left: 20px;">
             <li style="margin-bottom: 10px;">👕 <strong>Chất liệu:</strong> Mèo thun lạnh, siêu thấm hút mồ hôi.</li>
             <li style="margin-bottom: 10px;">🌟 <strong>Đặc điểm:</strong> Co giãn 4 chiều, không nhăn, không xù lông.</li>
             <li style="margin-bottom: 10px;">📏 <strong>Size:</strong> S, M, L, XL, XXL Chuẩn form người Việt.</li>
             <li style="margin-bottom: 10px;">🏷️ <strong>In ấn:</strong> Hỗ trợ in tên, số, logo sắc nét, bảo hành in vĩnh viễn.</li>
          </ul>

          <a href="#lien-he" class="btn btn-primary" style="padding: 15px 40px; font-size: 18px;">🛒 Tư Vấn & Đặt Hàng Zalo</a>
        </div>
      </div>
    </div>
  </section>

  <!-- FOOTER -->
  <footer id="lien-he" style="margin-top: 50px;">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div class="footer-logo">Đồng Phục<span>Bóng Đá</span></div>
          <p class="footer-desc">Đồng phục bóng đá thể thao chuyên nghiệp với thiết kế dẫn đầu xu hướng và công nghệ vải hiện đại.</p>
        </div>
        <div>
          <h4 class="footer-title">Khám Phá</h4>
          <ul class="footer-links">
            <li><a href="../index.html#san-pham">Bộ Sưu Tập</a></li>
            <li><a href="../san-bong-da-mini.html">Danh Bạ Sân Bóng 2026</a></li>
            <li><a href="../blog.html">Tin Tức Thể Thao</a></li>
          </ul>
        </div>
        <div>
          <h4 class="footer-title">Liên Hệ</h4>
          <ul class="footer-links">
            <li><a href="#">Hotline: 0988.XXX.XXX</a></li>
            <li><a href="#">Email: info@dongphucbongda.com</a></li>
            <li><a href="#">Zalo: Đồng Phục Bóng Đá</a></li>
          </ul>
        </div>
      </div>
      <div class="footer-bottom">
        &copy; 2026 Đồng Phục Bóng Đá. Đã đăng ký bản quyền.
      </div>
    </div>
  </footer>
</body>
</html>
"@

$brands = Get-ChildItem -Path $imagesDir -Directory

$allProducts = @()

foreach ($brandFolder in $brands) {
    $models = Get-ChildItem -Path $brandFolder.FullName -Directory
    $brandClean = $brandFolder.Name -replace '(?i)nhãn hàng\s+', '' -replace 'QUẦN ÁO BÓNG ĐÁ\s*', ''
    $brandClean = $brandClean.Trim()
    
    foreach ($model in $models) {
        $images = @(Get-ChildItem -Path $model.FullName -File -Include *.png,*.jpg,*.jpeg,*.webp -Recurse)
        if ($images.Count -eq 0) {
            continue
        }
        
        $mainImg = $images[0].FullName
        $mainImgRel = $mainImg.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
        $mainImgWeb = "../$mainImgRel"
        
        $galleryHtml = ""
        $count = 0
        foreach ($img in $images) {
            if ($count -ge 5) { break }
            $imgRel = $img.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $imgWeb = "../$imgRel"
            $galleryHtml += "            <img src=`"$imgWeb`" style=`"width: 80px; height: 80px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 1px solid rgba(255,255,255,0.1);`">`n"
            $count++
        }
        
        $title = $model.Name.Trim()
        $slugName = $title -replace '[^a-zA-Z0-9]+', '-'
        $slugName = $slugName.ToLower().Trim("-")
        $fileName = "$slugName.html"
        $filePath = "$productsDir\$fileName"
        
        $content = $productTemplate -f $title, $brandClean, $mainImgWeb, $galleryHtml
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        
        $allProducts += [PSCustomObject]@{
            Title = $title
            Slug = "san-pham/$fileName"
            Thumbnail = $mainImgRel
            Brand = $brandClean
        }
    }
}

Write-Host "Generated $($allProducts.Count) product articles."

# Update index.html
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8
$startMarker = "<!-- PRODUCTS SECTION -->"
$endMarker = "<!-- LATEST NEWS TEASER -->"

$startIdx = $indexContent.IndexOf($startMarker)
$endIdx = $indexContent.IndexOf($endMarker)

if ($startIdx -ge 0 -and $endIdx -ge 0) {
    $cardsHtml = ""
    $limitHtml = $allProducts | Select-Object -First 24
    foreach ($p in $limitHtml) {
        $cardsHtml += @"
        <div class="product-card">
          <img src="$($p.Thumbnail)" alt="$($p.Title)" class="product-img">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">$($p.Brand)</span>
            <h3 style="margin-top: 5px;">$($p.Title)</h3>
            <div class="product-price">180.000đ - 250.000đ</div>
            <a href="$($p.Slug)" class="btn btn-primary" style="padding: 10px 20px; font-size: 12px; width: 100%;">Xem Chi Tiết</a>
          </div>
        </div>
"@
    }
    
    $newSection = @"
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
    
    $newContent = $indexContent.Substring(0, $startIdx) + $newSection + $indexContent.Substring($endIdx)
    Set-Content -Path $indexPath -Value $newContent -Encoding UTF8
    Write-Host "Updated index.html with new products."
} else {
    Write-Host "Could not find markers in index.html"
}
