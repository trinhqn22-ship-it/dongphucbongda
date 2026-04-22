param()
$baseDir = (Get-Location).Path
$imagesDir = Join-Path $baseDir "images_bong_da"
$productsDir = $baseDir

$allProducts = @()

$seoKeywords = @(
    @{k="may áo bóng đá Quy Nhơn"; l="Quy Nhơn"},
    @{k="in áo bóng đá Quy Nhơn"; l="Quy Nhơn"},
    @{k="đồng phục bóng đá Bình Định"; l="Bình Định"},
    @{k="may áo bóng đá Pleiku"; l="Pleiku"},
    @{k="in áo bóng đá Gia Lai"; l="Gia Lai"},
    @{k="may áo bóng đá Đà Nẵng"; l="Đà Nẵng"},
    @{k="in áo bóng đá Quảng Ngãi"; l="Quảng Ngãi"},
    @{k="may áo bóng đá Tuy Hòa"; l="Tuy Hòa"},
    @{k="in áo bóng đá Nha Trang"; l="Nha Trang"},
    @{k="may áo bóng đá Phan Thiết"; l="Phan Thiết"}
)
$seoIndex = 0

$brands = Get-ChildItem -Path $imagesDir -Directory
foreach ($brandFolder in $brands) {
    $models = Get-ChildItem -Path $brandFolder.FullName -Directory
    $brandClean = $brandFolder.Name -replace '(?i)nh.n h.ng\s+', '' 
    $brandClean = $brandClean -replace 'QU.N .O B.NG ..\s*', ''
    $brandClean = $brandClean -replace '^\s*-\s*', ''
    $brandClean = $brandClean.Trim()
    
    foreach ($modelFolder in $models) {
        $images = @(Get-ChildItem -Path $modelFolder.FullName -File -Include *.png,*.jpg,*.jpeg,*.webp -Recurse)
        if ($images.Count -eq 0) { continue }
        
        $titleRaw = $modelFolder.Name.Trim()
        $slugName = $titleRaw -replace '[^a-zA-Z0-9]+', '-'
        $slugName = $slugName.ToLower().Trim("-")
        $fileName = "$slugName.html"
        $filePath = Join-Path $productsDir $fileName
        
        $kw1 = $seoKeywords[$seoIndex % $seoKeywords.Count]
        $seoIndex++
        $kw2 = $seoKeywords[$seoIndex % $seoKeywords.Count]
        $seoIndex++
        
        $loc1 = $kw1.l
        $word1 = $kw1.k
        $word2 = $kw2.k
        
        # Identify main image (person = not demo/ghep/size)
        $personImages = @()
        $sizeImages = @()
        $textureImages = @()
        
        foreach ($img in $images) {
            $n = $img.Name.ToLower()
            if ($n -match "size") {
                $sizeImages += $img
            } elseif ($n -match "demo" -or $n -match "ghep" -or $n -match "ai") {
                $personImages += $img
            } else {
                $textureImages += $img
            }
        }
        
        if ($personImages.Count -gt 0) {
            $mainImg = $personImages[0]
        } else {
            $mainImg = $images[0]
        }
        $mainImgRel = $mainImg.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
        
        $galleryHtml = ""
        foreach ($img in $images) {
            $imgRel = $img.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $galleryHtml += @"
              <div class="gallery-item" onclick="changeMainImage('$imgRel')" style="width: 80px; height: 80px; min-width: 80px; cursor: pointer; border-radius: 8px; overflow: hidden; border: 2px solid transparent; transition: 0.3s;" onmouseover="this.style.borderColor='var(--primary-color)'" onmouseout="this.style.borderColor='transparent'">
                 <img src="$imgRel" loading="lazy" style="width: 100%; height: 100%; object-fit: cover;">
              </div>
"@
        }
        
        $articleBody = ""
        if ($textureImages.Count -gt 0) {
            $tRel = $textureImages[0].FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $articleBody += @"
            <div style="margin: 40px auto; max-width: 700px;">
               <h3 style="font-size: 28px; margin-bottom: 20px; color: var(--primary-color); border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px; text-align: center;">🌟 CHẤT LIỆU VẢI THỂ THAO</h3>
               <p style="color: var(--text-muted); font-size: 16px; line-height: 1.8; margin-bottom: 20px; text-align: center;">
                 Sản phẩm được chau chuốt từ sợi vải công nghệ mới, thiết kế dệt tinh xảo tạo rãnh thoát khí. 
                 Cam kết đem lại sự khô ráo, thoải mái tuyệt đối và khả năng co giãn 4 chiều cho mọi chuyển động.
               </p>
               <img src="$tRel" loading="lazy" style="width: 100%; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); margin: 0 auto; display: block;" alt="thiết kế in ấn theo yêu cầu tại $loc1">
            </div>
"@
        }
        
        if ($sizeImages.Count -gt 0) {
            $sRel = $sizeImages[0].FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $articleBody += @"
            <div style="margin: 40px auto; max-width: 700px;">
               <h3 style="font-size: 28px; margin-bottom: 20px; color: var(--primary-color); border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px; text-align: center;">📏 BẢNG SIZE CHUẨN MỰC</h3>
               <p style="color: var(--text-muted); font-size: 16px; line-height: 1.8; margin-bottom: 20px; text-align: center;">
                 Thiết kế form dáng chuẩn người Việt Nam, dễ dàng tùy chọn size vừa vặn giúp tôn lên vẻ đẹp hình thể và đảm bảo tối đa sự linh hoạt.
               </p>
               <img src="$sRel" loading="lazy" style="width: 100%; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); margin: 0 auto; display: block;" alt="đồng phục bóng đá team công ty $loc1">
            </div>
"@
        }
        
        $seoBlock = @"
            <div style="margin: 40px auto; max-width: 700px; padding: 25px; background: rgba(0,255,135,0.05); border-radius: 12px; border: 1px dashed var(--primary-color);">
               <h3 style="font-size: 22px; margin-bottom: 15px; color: var(--primary-color);">Dịch Vụ $word1 Và Đặt Đo Đội Nhóm</h3>
               <p style="color: var(--text-muted); font-size: 16px; line-height: 1.8; margin-bottom: 0;">
                 Tại khu vực $loc1 và các tỉnh miền Trung, nhu cầu <a href="index.html#san-pham" style="color: #fff; text-decoration: underline; font-weight: bold;">$word2</a> đang tăng mạnh, đặc biệt với các đội bóng phong trào, công ty và nhóm bạn bè. Xưởng may của chúng tôi tự hào cung cấp dịch vụ thiết kế, in ấn và giao hàng tận nơi với chất lượng vượt trội.
               </p>
            </div>
"@
        $articleBody += $seoBlock

        # Build full HTML dynamically
        $htmlContent = @"
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mẫu áo $titleRaw | $word1 | Đồng Phục Bóng Đá</title>
  <meta name="description" content="Khám phá chi tiết mẫu áo $titleRaw. Dịch vụ $word1 chuyên nghiệp, uy tín tại các tỉnh miền Trung.">
  <link rel="canonical" href="https://www.inaodongphucmrslinh.com/p/$fileName">
  
  <!-- Open Graph / Facebook / Zalo -->
  <meta property="og:type" content="product">
  <meta property="og:title" content="Mẫu áo $titleRaw VIP - Đồng Phục Bóng Đá">
  <meta property="og:description" content="Giá chỉ từ 180.000đ. Nhấn để xem form dáng, chất liệu áo $titleRaw. Dịch vụ $word1.">
  <meta property="og:image" content="https://raw.githubusercontent.com/mrslinh2024/dongphucbongda/main/$mainImgRel">
  <meta property="og:url" content="https://www.inaodongphucmrslinh.com/p/$fileName">
  
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="css/style.css">
  <style>
    /* Premium layout for product details */
    .product-layout {
      display: grid;
      grid-template-columns: 1.5fr 1fr; /* approx 60% and 40% */
      gap: 50px;
      align-items: start;
    }
    .product-left, .product-right {
      min-width: 0; /* CRITICAL: Prevents grid item from expanding beyond its column width */
    }
    .product-left-sticky {
      position: sticky;
      top: 100px;
    }
    .main-image-container {
      width: 100%;
      background: #0f131a;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      margin-bottom: 25px;
      aspect-ratio: 4/3; /* Better than square for model photos to show the body */
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .main-image-container img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .product-right {
      background: var(--surface-color);
      padding: 40px;
      border-radius: 20px;
      border: 1px solid rgba(255,255,255,0.05);
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }
    .article-details {
      margin-top: 80px;
      border-top: 1px solid rgba(255,255,255,0.05);
      padding-top: 50px;
    }
    @media (max-width: 900px) {
      .product-layout { 
        grid-template-columns: 1fr; 
        gap: 30px;
      }
      .product-left-sticky { position: static; }
      .product-right { padding: 25px; }
      .main-image-container { aspect-ratio: 1/1; }
    }
  </style>
</head>
<body>
  <header>
    <div class="container nav-wrapper">
      <a href="index.html" class="logo">Đồng Phục<span>Bóng Đá</span></a>
      <nav class="nav-links">
        <a href="index.html">Trang Chủ</a>
        <a href="index.html#san-pham" class="active">Sản Phẩm</a>
        <a href="san-bong-da-mini.html">Sân Bóng Mini 2026</a>
        <a href="blog.html">Tin Thể Thao</a>
        <a href="https://www.inaodongphucmrslinh.com/p/lien-he.html" target="_blank" rel="noopener">Liên Hệ</a>
      </nav>
      <div class="header-cta"><a href="https://www.inaodongphucmrslinh.com/p/lien-he.html" target="_blank" rel="noopener" class="btn">Đặt Hàng Ngay</a></div>
    </div>
  </header>

  <section class="section" style="padding-top: 120px;">
    <div class="container">
      
      <!-- BREADCRUMBS -->
      <nav aria-label="breadcrumb" style="margin-bottom: 30px; font-size: 14px; font-weight: 500;">
        <ol style="list-style: none; padding: 0; margin: 0; display: flex; flex-wrap: wrap; gap: 8px; align-items: center;">
          <li><a href="index.html" style="color: var(--text-muted); transition: 0.3s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-muted)'">Trang Chủ</a></li>
          <li style="color: var(--text-muted); font-size: 12px;">▶</li>
          <li><a href="index.html#san-pham" style="color: var(--text-muted); transition: 0.3s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-muted)'">Bộ Sưu Tập Đồng Phục Bóng Đá</a></li>
          <li style="color: var(--text-muted); font-size: 12px;">▶</li>
          <li><a href="#" style="color: var(--text-muted); transition: 0.3s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-muted)'">$brandClean</a></li>
          <li style="color: var(--text-muted); font-size: 12px;">▶</li>
          <li style="color: var(--primary-color);" aria-current="page">$titleRaw</li>
        </ol>
      </nav>

      <!-- PRODUCT TOP GRID -->
      <div class="product-layout">
        <!-- LEFT: IMAGES -->
        <div class="product-left">
          <div class="product-left-sticky">
            <div class="main-image-container">
              <img id="main-img" src="$mainImgRel" alt="$titleRaw - mẫu $word1">
            </div>
            
            <h4 style="margin-bottom: 10px; color: var(--text-muted); font-size: 14px; text-transform: uppercase;">Bộ Sưu Tập Cùng Dòng</h4>
            <div class="gallery-scroll" style="display: flex; gap: 10px; overflow-x: auto; padding-bottom: 15px;">
$galleryHtml
            </div>
          </div>
        </div>
        
        <!-- RIGHT: INFO -->
        <div class="product-right">
          <span class="badge" style="font-size: 14px; padding: 6px 16px; margin-bottom: 20px; display: inline-block;">$brandClean</span>
          <h1 style="font-size: 38px; font-weight: 800; margin: 0 0 20px 0; line-height: 1.3; color: #ffffff;">Mẫu áo $titleRaw VIP</h1>
          
          <div style="padding-bottom: 25px; border-bottom: 1px solid rgba(255,255,255,0.1); margin-bottom: 25px;">
            <div style="color: var(--primary-color); font-size: 32px; font-weight: bold; line-height: 1.1; white-space: nowrap;">
              180.000đ&nbsp;-&nbsp;250.000đ
              <span style="font-size: 18px; font-weight: 500; color: var(--text-muted);">/ Bộ</span>
            </div>
            <p style="color: var(--text-muted); font-size: 17px; margin-top: 20px; line-height: 1.8;">
              Mẫu <strong>$titleRaw</strong> nổi bật rực rỡ với thiết kế đột phá, mang tinh thần chiến binh trên sân cỏ. Đi đầu xu hướng thời trang thể thao 2026.
            </p>
          </div>
          
          <div style="margin-bottom: 35px;">
            <h4 style="color: #fff; font-size: 18px; margin-bottom: 15px;">Điểm nổi bật</h4>
            <ul style="color: var(--text-main); font-size: 15px; margin: 0; padding: 0; list-style: none;">
               <li style="margin-bottom: 12px; background: rgba(0,0,0,0.2); padding: 16px 20px; border-radius: 10px; border-left: 4px solid var(--primary-color); display: flex; align-items: flex-start; gap: 15px;">
                 <span style="font-size: 20px;">👕</span>
                 <div><strong>Đa dạng màu sắc:</strong> Có đủ bảng màu tùy chỉnh cực ngầu theo đội của bộ sưu tập.</div>
               </li>
               <li style="margin-bottom: 12px; background: rgba(0,0,0,0.2); padding: 16px 20px; border-radius: 10px; border-left: 4px solid var(--primary-color); display: flex; align-items: flex-start; gap: 15px;">
                 <span style="font-size: 20px;">📏</span>
                 <div><strong>Size đầy đủ:</strong> S, M, L, XL, XXL - Chuẩn form body tôn dáng người Việt Nam.</div>
               </li>
               <li style="margin-bottom: 0; background: rgba(0,0,0,0.2); padding: 16px 20px; border-radius: 10px; border-left: 4px solid var(--primary-color); display: flex; align-items: flex-start; gap: 15px;">
                 <span style="font-size: 20px;">✨</span>
                 <div><strong>Công nghệ in đỉnh cao:</strong> In lụa, chuyển nhiệt sắc nét, sắc sảo từng chi tiết, bảo hành không phai.</div>
               </li>
            </ul>
          </div>

          <a href="https://www.inaodongphucmrslinh.com/p/lien-he.html" target="_blank" rel="noopener" class="btn btn-primary" style="display: block; padding: 20px; font-size: 18px; font-weight: 800; text-align: center; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,255,135,0.3); letter-spacing: 0.5px;">
            🛒 LIÊN HỆ ĐẶT HÀNG NGAY
          </a>
        </div>
      </div>
      
      <!-- BOTTOM: EXTRAS (Material, Size charts) -->
      <div class="article-details">
$articleBody
      </div>

    </div>
  </section>

  <!-- FOOTER -->
  <footer id="lien-he" style="margin-top: 20px;">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div class="footer-logo">Đồng Phục<span>Bóng Đá</span></div>
          <p class="footer-desc">Đồng phục bóng đá thể thao chuyên nghiệp với thiết kế dẫn đầu xu hướng và công nghệ vải hiện đại.</p>
        </div>
        <div>
          <h4 class="footer-title">Khám Phá</h4>
          <ul class="footer-links">
            <li><a href="index.html#san-pham">Bộ Sưu Tập</a></li>
            <li><a href="https://www.inaodongphucmrslinh.com/search/label/dong-phuc-bong-da" target="_blank" rel="noopener">Blog Design Đồng Phục</a></li>
            <li><a href="san-bong-da-mini.html">Danh Bạ Sân Bóng 2026</a></li>
            <li><a href="blog.html">Tin Tức Thể Thao</a></li>
          </ul>
        </div>
        <div>
          <h4 class="footer-title">Liên Hệ</h4>
          <ul class="footer-links">
            <li><a href="#">Hotline: 0934.975.913</a></li>
            <li><a href="#">Email: mrslinh@inaodongphucmrslinh.com</a></li>
            <li><a href="#">Zalo: 0934.975.913</a></li>
          </ul>
        </div>
      </div>
      <div class="footer-bottom">
        &copy; 2026 Đồng Phục Bóng Đá. Đã đăng ký bản quyền.
      </div>
    </div>
  </footer>

  <script>
    function changeMainImage(srcPath) {
      document.getElementById('main-img').src = srcPath;
    }
  </script>
  
  <!-- JSON-LD Product Schema -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org/",
    "@type": "Product",
    "name": "Áo bóng đá $titleRaw",
    "image": [
      "https://raw.githubusercontent.com/mrslinh2024/dongphucbongda/main/$mainImgRel"
    ],
    "description": "Mẫu áo bóng đá $titleRaw nổi bật rực rỡ với thiết kế đột phá. Cam kết mang đến trải nghiệm đồ thể thao cao cấp nhất với công nghệ vải mè hiện đại.",
    "sku": "$slugName",
    "brand": {
      "@type": "Brand",
      "name": "$brandClean"
    },
    "offers": {
      "@type": "AggregateOffer",
      "url": "https://www.inaodongphucmrslinh.com/p/$fileName",
      "priceCurrency": "VND",
      "lowPrice": "180000",
      "highPrice": "250000",
      "offerCount": "100",
      "availability": "https://schema.org/InStock",
      "itemCondition": "https://schema.org/NewCondition"
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.9",
      "reviewCount": "185",
      "bestRating": "5",
      "worstRating": "1"
    }
  }
  </script>
</body>
</html>
"@

        # Write to file directly with BOM
        Set-Content -Path $filePath -Value $htmlContent -Encoding UTF8
        
        $allProducts += [PSCustomObject]@{
            Title = $titleRaw
            Slug = $fileName
            Thumbnail = $mainImgRel
            Brand = $brandClean
        }
    }
}

Write-Host "Generated $($allProducts.Count) product articles flawlessly."

# Update index.html
$indexPath = Join-Path $baseDir "index.html"
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8

$sIdx = $indexContent.IndexOf("<!-- PRODUCTS SECTION -->")
$eIdx = $indexContent.IndexOf("<!-- LATEST NEWS TEASER -->")

if ($sIdx -gt 0 -and $eIdx -gt $sIdx) {
    $cardsHtml = ""
    foreach ($p in $allProducts) {
        $cardsHtml += @"
        <div class="product-card">
          <img src="$($p.Thumbnail)" loading="lazy" alt="$($p.Title)" style="width: 100%; height: 350px; object-fit: contain; background: #161b22; padding: 10px;">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">$($p.Brand)</span>
            <h3 style="margin-top: 5px; font-size: 18px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">$($p.Title)</h3>
            <div class="product-price" style="margin-top: 10px; margin-bottom: 15px; color: var(--primary-color); font-size: 18px; font-weight: 700;">180.000đ - 250.000đ</div>
            <a href="$($p.Slug)" class="btn btn-primary" style="padding: 10px 20px; font-size: 14px; width: 100%; text-align: center;">Xem Chi Tiết</a>
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
        <p style="margin-top: 15px; color: var(--primary-color); font-weight: bold; font-size: 16px;">⭐ Chúng tôi nhận may in áo bóng đá theo yêu cầu tại Quy Nhơn, Gia Lai, Đà Nẵng và các tỉnh miền Trung…</p>
      </div>
      <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 30px;">
$cardsHtml
      </div>
    </div>
  </section>

  
"@

    $newIndex = $indexContent.Substring(0, $sIdx) + $replacement + $indexContent.Substring($eIdx)
    Set-Content -Path $indexPath -Value $newIndex -Encoding UTF8
    Write-Host "index.html updated successfully with new thumbnails."
}

