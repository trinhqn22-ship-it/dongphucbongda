param()
# ascii only
# no unicode
# we can discover the path using Get-Location if we run it from that dir, to avoid unicode path issues
$baseDir = (Get-Location).Path
$imagesDir = Join-Path $baseDir "images_bong_da"
$productsDir = $baseDir

$filesToUpdate = @("index.html", "san-bong-da-mini.html", "blog.html", "ao-bong-da-aura-a10.html")
foreach ($f in $filesToUpdate) {
    if (Test-Path $f) {
        $content = Get-Content -Path $f -Raw -Encoding UTF8
        # use regex to replace phone numbers
        $content = $content -replace "0988\.XXX\.XXX", "0934.975.913"
        $content = $content -replace "Zalo:\s*(.*?)</", "Zalo: 0934.975.913</"
        $content = $content -replace "info@.*?\</", "mrslinh@inaodongphucmrslinh.com</"
        Set-Content -Path $f -Value $content -Encoding UTF8
    }
}

$templateHtml = Get-Content (Join-Path $baseDir "ao-bong-da-aura-a10.html") -Raw -Encoding UTF8

$allProducts = @()

$brands = Get-ChildItem -Path $imagesDir -Directory
foreach ($brandFolder in $brands) {
    $models = Get-ChildItem -Path $brandFolder.FullName -Directory
    # clean brand name dynamically
    $brandClean = $brandFolder.Name
    $brandClean = $brandClean -replace '(?i)nh.n h.ng\s+', '' 
    $brandClean = $brandClean -replace 'QU.N .O B.NG ..\s*', ''
    $brandClean = $brandClean -replace '^\s*-\s*', ''
    $brandClean = $brandClean.Trim()
    
    foreach ($modelFolder in $models) {
        $images = @(Get-ChildItem -Path $modelFolder.FullName -File -Include *.png,*.jpg,*.jpeg,*.webp -Recurse)
        if ($images.Count -eq 0) { continue }
        
        $mainImgFullPath = $images[0].FullName
        $mainImgRel = $mainImgFullPath.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
        
        $galleryHtml = ""
        $count = 0
        foreach ($img in $images) {
            if ($count -ge 5) { break }
            $imgRel = $img.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $galleryHtml += "             <img src=`"$($imgRel)`" style=`"width: 80px; height: 80px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 1px solid rgba(255,255,255,0.1);`">`n"
            $count++
        }
        
        $titleRaw = $modelFolder.Name.Trim()
        
        $slugName = $titleRaw -replace '[^a-zA-Z0-9]+', '-'
        $slugName = $slugName.ToLower().Trim("-")
        $fileName = "$slugName.html"
        $filePath = Join-Path $productsDir $fileName
        
        $pageHtml = $templateHtml
        
        # We replace the img tag using a dynamic regex
        $pageHtml = $pageHtml -replace '(?s)<img src="images_bong_da/.*?" alt="[^"]*" style="width: 100%; border-radius: 12px; box-shadow:[^"]*">', ("<img src=`"$mainImgRel`" alt=`"$titleRaw`" style=`"width: 100%; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,255,135,0.2);`">")
        
        $pageHtml = $pageHtml -replace '(?s)<div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">.*?</div>(?=\s*</div>\s*<div>\s*<span class="badge">)', ("<div style=`"display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;`">`n" + $galleryHtml + "          </div>")
        
        $pageHtml = $pageHtml -replace '<title>.*?</title>', ("<title>Model $titleRaw | Aura Sports</title>")
        $pageHtml = $pageHtml -replace '<span class="badge">.*?</span>', ("<span class=`"badge`">$brandClean</span>")
        $pageHtml = $pageHtml -replace '<h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">.*?</h1>', ("<h1 style=`"font-size: 42px; font-weight: 800; margin: 15px 0;`">$titleRaw</h1>")
        $pageHtml = $pageHtml -replace 'M.u <strong>.*?</strong> n.i b.t', ("Models <strong>$titleRaw</strong> VIP")
        
        Set-Content -Path $filePath -Value $pageHtml -Encoding UTF8
        
        $allProducts += [PSCustomObject]@{
            Title = $titleRaw
            Slug = $fileName
            Thumbnail = $mainImgRel
            Brand = $brandClean
        }
    }
}

Write-Host "Generated $($allProducts.Count) product articles."

$indexPath = Join-Path $baseDir "index.html"
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8

$sIdx = $indexContent.IndexOf("<!-- PRODUCTS SECTION -->")
$eIdx = $indexContent.IndexOf("<!-- LATEST NEWS TEASER -->")

if ($sIdx -gt 0 -and $eIdx -gt $sIdx) {
    $cardsHtml = ""
    foreach ($p in $allProducts | Select-Object -First 24) {
        $cardsHtml += @"
        <div class="product-card">
          <img src="$($p.Thumbnail)" alt="$($p.Title)" class="product-img">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">$($p.Brand)</span>
            <h3 style="margin-top: 5px; font-size: 18px;">$($p.Title)</h3>
            <div class="product-price">180.000d - 250.000d</div>
            <a href="$($p.Slug)" class="btn btn-primary" style="padding: 10px 20px; font-size: 12px; width: 100%;">Order Now</a>
          </div>
        </div>
"@
    }
    
    $replacement = @"
<!-- PRODUCTS SECTION -->
  <section id="san-pham" class="section">
    <div class="container">
      <div class="section-header">
        <h2>Top Models <span>2026</span></h2>
        <p>Best quality from top brands</p>
      </div>
      <div class="grid">
$cardsHtml
      </div>
    </div>
  </section>

  
"@

    $newIndex = $indexContent.Substring(0, $sIdx) + $replacement + $indexContent.Substring($eIdx)
    Set-Content -Path $indexPath -Value $newIndex -Encoding UTF8
    Write-Host "index.html updated successfully."
} else { Write-Host "markers not found" }
