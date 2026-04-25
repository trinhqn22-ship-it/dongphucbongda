import feedparser
import datetime
import urllib.request
import re
import os

try:
    import google.generativeai as genai
except ImportError:
    genai = None

# RSS feeds from VnExpress, Tuoi Tre, Tien Phong
RSS_FEEDS = [
    "https://vnexpress.net/rss/the-thao.rss",
    "https://tuoitre.vn/rss/the-thao.rss",
    "https://tienphong.vn/rss/the-thao-11.rss"
]

def fetch_sports_news():
    news_items = []
    
    for url in RSS_FEEDS:
        try:
            feed = feedparser.parse(url)
            for entry in feed.entries[:2]: # Get top 2 from each source
                title = entry.title
                link = entry.link
                summary_clean = re.sub(r'<[^>]+>', '', entry.description)
                
                # Try finding image in description or use a generic one
                image_url = 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=600&auto=format&fit=crop'
                img_match = re.search(r'<img[^>]+src="([^">]+)"', entry.description)
                if img_match:
                    image_url = img_match.group(1)
                
                news_items.append({
                    'title': title,
                    'link': link,
                    'summary': summary_clean[:150] + '...',
                    'image': image_url,
                    'published': datetime.datetime.now().strftime("%d/%m/%Y, %H:%M AM")
                })
        except Exception as e:
            print(f"Error fetching {url}: {e}")
            
    return news_items[:3] # We return top 3 combined

def generate_expert_summary(news_items):
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key or not genai:
        print("GEMINI_API_KEY not found or google-generativeai not installed. Skipping expert summary.")
        return None
        
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        news_text = ""
        for i, item in enumerate(news_items):
            news_text += f"{i+1}. {item['title']}\n{item['summary']}\n\n"
            
        prompt = f"""
Bạn là một chuyên gia phân tích thể thao và bóng đá chuyên nghiệp.
Dưới đây là các tin tức thể thao nổi bật vừa được hệ thống tự động tổng hợp:

{news_text}

Hãy viết một bài tóm tắt tổng hợp (khoảng 150-200 từ), dưới góc nhìn chuyên sâu của một chuyên gia thể thao. Hãy kết nối các sự kiện trên lại với nhau thành một bức tranh toàn cảnh, đưa ra nhận định, đánh giá hoặc dự đoán sắc bén của bạn.
Văn phong cần chuyên nghiệp, lôi cuốn, mang tính định hướng và hấp dẫn người đọc đam mê bóng đá.
Trả về văn bản thuần túy, có thể chia thành các đoạn văn ngắn, KHÔNG sử dụng markdown phức tạp.
"""
        response = model.generate_content(prompt)
        if response.text:
            expert_item = {
                'title': '👑 Góc Nhìn Chuyên Gia: Toàn Cảnh Thể Thao Hôm Nay',
                'link': '#',
                'summary': response.text.replace('\n', '<br>'),
                'image': 'https://images.unsplash.com/photo-1518605368461-1ee1252199b4?q=80&w=800&auto=format&fit=crop',
                'published': datetime.datetime.now().strftime("%d/%m/%Y, %H:%M AM") + ' - Chuyên mục đặc biệt'
            }
            return expert_item
    except Exception as e:
        print(f"Error generating expert summary: {e}")
    
    return None

def generate_blog_html(news_items):
    html_items = []
    for item in news_items:
        html = f"""
        <article class="blog-card">
          <img src="{item['image']}" alt="{item['title']}">
          <div class="blog-content">
            <div class="blog-date">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
              {item['published']}
            </div>
            <h3>{item['title']}</h3>
            <p>{item['summary']}</p>
            <a href="{item['link']}" target="_blank" class="read-more-btn">Đọc Tiếp <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 8l4 4m0 0l-4 4m4-4H3"></path></svg></a>
          </div>
        </article>
        """
        html_items.append(html)
    return "\n".join(html_items)

def update_file(filepath, new_html):
    if not os.path.exists(filepath):
        print(f"File {filepath} not found.")
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will replace the content inside the markers
    start_tag = '<!-- START BLOG LIST -->'
    end_tag = '<!-- END BLOG LIST -->'
    
    start_idx = content.find(start_tag)
    if start_idx != -1:
        # Find the closing matching marker
        end_idx = content.find(end_tag, start_idx)
        if end_idx != -1:
            # We want to replace the inner content between the markers
            new_content = content[:start_idx + len(start_tag)] + "\n" + new_html + "\n        " + content[end_idx:]
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Successfully updated {filepath}")

if __name__ == "__main__":
    print("Fetching sports news...")
    news = fetch_sports_news()
    if news:
        # Generate expert summary
        expert_item = generate_expert_summary(news)
        if expert_item:
            news.insert(0, expert_item)
            
        html_snippets = generate_blog_html(news)
        update_file('../blog.html', html_snippets)
        print("Blog updated successfully.")
    else:
        print("No news fetched.")
