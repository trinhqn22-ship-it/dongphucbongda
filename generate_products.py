import os
import glob
import re

# Base directory for the workspace
BASE_DIR = r"d:\tao web\đồng phục bóng đá"
IMAGES_DIR = os.path.join(BASE_DIR, "images_bong_da")
PRODUCTS_DIR = os.path.join(BASE_DIR, "san-pham")

if not os.path.exists(PRODUCTS_DIR):
    os.makedirs(PRODUCTS_DIR)

# HTML Template for a product article
PRODUCT_TEMPLATE = """<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title} | Đồng Phục Bóng Đá</title>
  <meta name="description" content="Khám phá mẫu áo bóng đá {title} - chất liệu cao cấp, form chuẩn thể thao.">
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
          <img src="{main_image}" alt="{title}" style="width: 100%; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,255,135,0.2);">
          
          <div style="display: flex; gap: 10px; margin-top: 20px; overflow-x: auto;">
             {gallery_html}
          </div>
        </div>
        <div>
          <span class="badge">{brand}</span>
          <h1 style="font-size: 42px; font-weight: 800; margin: 15px 0;">{title}</h1>
          <div style="color: var(--primary-color); font-size: 28px; font-weight: bold; margin-bottom: 30px;">180.000đ - 250.000đ / Bộ</div>
          
          <p style="color: var(--text-muted); font-size: 18px; margin-bottom: 20px;">
            Mẫu <strong>{title}</strong> nổi bật với thiết kế đột phá, mang tinh thần thể thao mạnh mẽ. 
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
"""

def generate_products():
    brands = [d for d in os.listdir(IMAGES_DIR) if os.path.isdir(os.path.join(IMAGES_DIR, d))]
    
    products_data = []

    for brand_folder in brands:
        brand_path = os.path.join(IMAGES_DIR, brand_folder)
        models = [d for d in os.listdir(brand_path) if os.path.isdir(os.path.join(brand_path, d))]
        
        brand_clean = re.sub(r'nhãn hàng\s+', '', brand_folder, flags=re.IGNORECASE).replace("QUẦN ÁO BÓNG ĐÁ", "").strip()
        
        for model in models:
            model_path = os.path.join(brand_path, model)
            
            # Use glob to find common image formats
            images = []
            for ext in ('*.png', '*.jpg', '*.jpeg', '*.webp'):
                images.extend(glob.glob(os.path.join(model_path, ext)))
                
            if not images:
                continue
            
            # First image as main using relative web path
            main_image_sys = images[0]
            # Replace absolute path with relative web path
            main_image_web = "../" + os.path.relpath(main_image_sys, BASE_DIR).replace('\\', '/')
            
            gallery_html = ""
            for img in images[:5]: # Take up to 5 images for gallery
                img_web = "../" + os.path.relpath(img, BASE_DIR).replace('\\', '/')
                gallery_html += f'<img src="{img_web}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 8px; cursor: pointer; border: 1px solid rgba(255,255,255,0.1);">'
                
            title = model.strip()
            slug = re.sub(r'[^a-zA-Z0-9]+', '-', title).lower()
            html_filename = f"{slug}.html"
            html_filepath = os.path.join(PRODUCTS_DIR, html_filename)
            
            # Generate the file
            content = PRODUCT_TEMPLATE.format(
                title=title,
                brand=brand_clean,
                main_image=main_image_web,
                gallery_html=gallery_html
            )
            
            with open(html_filepath, 'w', encoding='utf-8') as f:
                f.write(content)
                
            products_data.append({
                'title': title,
                'slug': f"san-pham/{html_filename}",
                'thumbnail': main_image_web.replace("../", ""), # relative to index.html
                'brand': brand_clean
            })
            
    print(f"Generated {len(products_data)} product articles.")
    return products_data

def update_index_html(products):
    index_path = os.path.join(BASE_DIR, "index.html")
    with open(index_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    start_marker = "<!-- PRODUCTS SECTION -->"
    end_marker = "<!-- LATEST NEWS TEASER -->"
    
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    if start_idx == -1 or end_idx == -1:
        print("Could not find markers in index.html")
        return
        
    cards_html = []
    # Take up to 9 products for the homepage
    for p in products[:9]:
        card = f"""
        <div class="product-card">
          <img src="{p['thumbnail']}" alt="{p['title']}" class="product-img">
          <div class="product-info">
            <span style="font-size: 12px; color: var(--secondary-color); font-weight: bold; text-transform: uppercase;">{p['brand']}</span>
            <h3 style="margin-top: 5px;">{p['title']}</h3>
            <div class="product-price">Liên hệ</div>
            <a href="{p['slug']}" class="btn btn-primary" style="padding: 10px 20px; font-size: 12px; width: 100%;">Xem Chi Tiết</a>
          </div>
        </div>"""
        cards_html.append(card)
        
    new_section = f"""<!-- PRODUCTS SECTION -->
  <section id="san-pham" class="section">
    <div class="container">
      <div class="section-header">
        <h2>Bộ Sưu Tập <span>Đồng Phục Bóng Đá 2026</span></h2>
        <p>Những mẫu thiết kế đặc sắc chuyên nghiệp từ các thương hiệu hàng đầu</p>
      </div>
      <div class="grid">
        {"".join(cards_html)}
      </div>
      <div style="text-align: center; margin-top: 40px;">
        <a href="#lien-he" class="btn btn-outline" style="border-color: rgba(255,255,255,0.1); color: var(--text-muted);">Tải Thêm Sản Phẩm ⬇️</a>
      </div>
    </div>
  </section>

  """
  
    new_content = content[:start_idx] + new_section + content[end_idx:]
    
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Updated index.html with new products.")

if __name__ == "__main__":
    products = generate_products()
    if products:
        update_index_html(products)
