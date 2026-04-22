param()
# ascii only
$baseDir = (Get-Location).Path
$imagesDir = Join-Path $baseDir "images_bong_da"
$productsDir = $baseDir

$templateHtml = Get-Content (Join-Path $baseDir "ao-bong-da-aura-a10.html") -Raw -Encoding UTF8

$allProducts = @()

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
        
        $demoImages = @()
        $sizeImages = @()
        $otherImages = @()
        
        foreach ($img in $images) {
            $name = $img.Name.ToLower()
            if ($name -match "bangsize" -or $name -match "size") {
                $sizeImages += $img
            } elseif ($name -match "demo" -or $name -match "ghep" -or $name -match "ai") {
                $demoImages += $img
            } else {
                $otherImages += $img
            }
        }
        
        $mainImg = $null
        if ($demoImages.Count -gt 0) {
            $mainImg = $demoImages[0]
        } elseif ($otherImages.Count -gt 0) {
            $mainImg = $otherImages[0]
        } else {
            $mainImg = $images[0]
        }
        
        $mainImgRel = $mainImg.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
        
        $galleryHtml = ""
        $titleRaw = $modelFolder.Name.Trim()
        $slugId = $titleRaw -replace '[^a-zA-Z0-9]', ''
        
        foreach ($img in $demoImages) {
            $imgRel = $img.FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $galleryHtml += "             <img src=`"$($imgRel)`" onclick=`"document.getElementById('main-img_$slugId').src=this.src`" style=`"width: 80px; height: 80px; min-width: 80px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 2px solid transparent; transition: 0.3s;`" onmouseover=`"this.style.borderColor='var(--primary-color)'`" onmouseout=`"this.style.borderColor='transparent'`">`n"
        }
        
        $articleBody = ""
        
        if ($otherImages.Count -gt 0) {
            $matRel = $otherImages[0].FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $articleBody += @"
            <div style=`"margin: 40px 0;`">
               <h3 style=`"font-size: 24px; margin-bottom: 20px; color: var(--text-main);`">VIP_CHAT_LIEU</h3>
               <p style=`"color: var(--text-muted); margin-bottom: 15px;`">VIP_CHAT_LIEU_DESC</p>
               <img src=`"$matRel`" style=`"width: 100%; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3);`">
            </div>
"@
        }
        
        if ($sizeImages.Count -gt 0) {
            $sizeRel = $sizeImages[0].FullName.Replace($baseDir, "").Replace("\", "/").TrimStart("/")
            $articleBody += @"
            <div style=`"margin: 40px 0;`">
               <h3 style=`"font-size: 24px; margin-bottom: 20px; color: var(--text-main);`">VIP_BANG_SIZE</h3>
               <p style=`"color: var(--text-muted); margin-bottom: 15px;`">VIP_BANG_SIZE_DESC</p>
               <img src=`"$sizeRel`" style=`"width: 100%; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3);`">
            </div>
"@
        }
        
        $slugName = $titleRaw -replace '[^a-zA-Z0-9]+', '-'
        $slugName = $slugName.ToLower().Trim("-")
        $fileName = "$slugName.html"
        $filePath = Join-Path $productsDir $fileName
        
        $pageHtml = $templateHtml
        
        $pageHtml = $pageHtml -replace '(?s)<img src="images_bong_da/.*?" alt="[^"]*" style="width: 100%; border-radius: 12px; box-shadow:[^"]*">', ("<img id=`"main-img_$slugId`" src=`"$mainImgRel`" alt=`"$titleRaw`" style=`"width: 100%; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,255,135,0.2); object-fit: cover; aspect-ratio: 1/1;`">")
        
        $pageHtml = $pageHtml -replace '(?s)<div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">.*?</div>(?=\s*</div>\s*<div>\s*<span class="badge">)', ("<div class=`"gallery-scroll`" style=`"display: flex; gap: 10px; margin-top: 20px; overflow-x: auto; padding-bottom: 15px;`">`n" + $galleryHtml + "          </div>")
        
        $pageHtml = $pageHtml -replace '<title>.*?</title>', ("<title>Model $titleRaw | Dong Phuc Bong Da</title>")
        $pageHtml = $pageHtml -replace '<span class="badge">.*?</span>', ("<span class=`"badge`">$brandClean</span>")
        $pageHtml = $pageHtml -replace '<h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">.*?</h1>', ("<h1 style=`"font-size: 42px; font-weight: 800; margin: 15px 0;`">$titleRaw</h1>")
        $pageHtml = $pageHtml -replace 'Models <strong>.*?</strong> VIP', ("M.u <strong>$titleRaw</strong> n.i b.t")
        $pageHtml = $pageHtml -replace 'M.u <strong>.*?</strong> n.i b.t', ("M.u <strong>$titleRaw</strong> n.i b.t")
        
        $pageHtml = $pageHtml -replace '(?s)(<ul style="color: var\(--text-muted\); margin-bottom: 40px; padding-left: 20px;">)', ("$articleBody`n          `$1")
        
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
    # Sort the products randomly or just take all
    foreach ($p in $allProducts) {
        $cardsHtml += @"
        <div class="product-card">
          <img src="$($p.Thumbnail)" alt="$($p.Title)" style="width: 100%; height: 350px; object-fit: cover; background: #252b42;">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">$($p.Brand)</span>
            <h3 style="margin-top: 5px; font-size: 18px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">$($p.Title)</h3>
            <div class="product-price" style="margin-top: 10px; margin-bottom: 15px; color: var(--primary-color); font-size: 18px; font-weight: 700;">GIA_TIEN</div>
            <a href="$($p.Slug)" class="btn btn-primary" style="padding: 10px 20px; font-size: 14px; width: 100%; text-align: center;">XEM_CHI_TIET</a>
          </div>
        </div>
"@
    }
    
    $replacement = @"
<!-- PRODUCTS SECTION -->
  <section id="san-pham" class="section">
    <div class="container">
      <div class="section-header">
        <h2>BO_SUU_TAP</h2>
        <p>BO_SUU_TAP_DESC</p>
      </div>
      <div class="grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 30px;">
$cardsHtml
      </div>
    </div>
  </section>

  
"@

    $newIndex = $indexContent.Substring(0, $sIdx) + $replacement + $indexContent.Substring($eIdx)
    Set-Content -Path $indexPath -Value $newIndex -Encoding UTF8
    Write-Host "index.html updated successfully."
} else { Write-Host "markers not found" }
