
import json
import time
import random
from playwright.sync_api import sync_playwright
from bs4 import BeautifulSoup
import os

# Configuration
OUTPUT_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'assets', 'data', 'collected_products.json')

# Generic wrapper to categorize keywords if URL doesn't specify
CATEGORY_KEYWORDS = {
    'Milk': ['Milk', 'Curd', 'Yogurt', 'Paneer', 'Butter', 'Cheese', 'Cream'],
    'Vegetables': ['Tomato', 'Onion', 'Potato', 'Spinach', 'Okra', 'Vegetable'],
    'Fruits': ['Apple', 'Banana', 'Mango', 'Orange', 'Grape', 'Papaya', 'Fruit'],
    'Bread': ['Bread', 'Bun', 'Pav', 'Rusk'],
    'Atta & Rice': ['Atta', 'Rice', 'Flour', 'Basmati'],
    'Oil & Masala': ['Oil', 'Ghee', 'Masala', 'Spices', 'Salt', 'Sugar'],
    'Snacks': ['Biscuit', 'Chips', 'Cookie', 'Noodle', 'Pasta', 'Chocolate', 'Candy'],
    'Beverages': ['Tea', 'Coffee', 'Juice', 'Soda', 'Drink', 'Water'],
    'Cleaning': ['Detergent', 'Cleaner', 'Soap', 'Wash', 'Liquid'],
    'Personal Care': ['Shampoo', 'Soap', 'Face', 'Cream', 'Lotion', 'Sanitary']
}

def determine_category(product_name, default_category="General"):
    for cat, keywords in CATEGORY_KEYWORDS.items():
        for kw in keywords:
            if kw.lower() in product_name.lower():
                return cat
    return default_category

def scrape_blinkit_category(page, url, category_name):
    print(f"Scraping Blinkit Category: {category_name} - {url}")
    try:
        page.goto(url, timeout=60000)
        page.wait_for_load_state('networkidle')
        
        # Scroll to load more items
        for _ in range(5):
            page.mouse.wheel(0, 5000)
            time.sleep(1)

        # Parse content
        # Blinkit structure usually involves product cards. 
        # We will try to extract data from generic attributes if specific classes change.
        # Look for price symbol ₹
        
        products = []
        
        # Method 1: Try JSON-LD (Schema.org)
        # Often e-commerce sites put product data in a script tag
        metadata = page.evaluate('''() => {
            const scripts = document.querySelectorAll('script[type="application/ld+json"]');
            const data = [];
            scripts.forEach(s => {
                try {
                    const json = JSON.parse(s.innerText);
                    if (json['@type'] === 'Product' || json['@type'] === 'ItemList') {
                        data.push(json);
                    }
                } catch(e) {}
            });
            return data;
        }''')
        
        if metadata:
            print(f"Found {len(metadata)} JSON-LD blocks")
            for item in metadata:
                if item.get('@type') == 'Product':
                    products.append({
                        "name": item.get('name'),
                        "price": float(item.get('offers', {}).get('price', 0)),
                        "imageUrl": item.get('image'),
                        "brand": item.get('brand', {}).get('name', 'Unknown'),
                        "category": category_name,
                        "description": item.get('description', '')
                    })
                elif item.get('@type') == 'ItemList':
                     for element in item.get('itemListElement', []):
                         listing = element.get('item', {})
                         if listing:
                             products.append({
                                 "name": listing.get('name'),
                                 "price": float(listing.get('offers', {}).get('price', 0)),
                                 "imageUrl": listing.get('image'),
                                 "brand": listing.get('brand', {}).get('name', 'Unknown'),
                                 "category": category_name
                             })

        if not products:
            print("No JSON-LD products found, trying CSS selectors...")
            # Fallback to CSS selectors (These might need updating as site changes)
            # Identifying product cards by looking for price and add button
            product_cards = page.query_selector_all('div[data-test-id*="product-card"]') # Hypothesis
            
            if not product_cards:
                 # Try a more generic strategy: find elements with "₹" text
                 cards = page.locator('div:has-text("₹")').all()
                 # This is tricky without exact classes.
                 # Let's try to grab generic images and text near them.
                 pass

        print(f"Collected {len(products)} products from {url}")
        return products

    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return []

def scrape_instamart(page):
    # Instamart is tough, often app-only or heavy SPA.
    # But Swiggy has a web interface.
    print("Scraping Instamart (Placeholder - requires specific location/login cookies often)")
    return []

def main():
    print("Starting collection...")
    
    # 1. Define Categories/URLs
    # Note: These URLs might expire or redirect based on location. 
    # Best practice is to visit blinkit.com, set location, then scrape.
    targets = [
        {"name": "Dairy", "url": "https://blinkit.com/cn/milk/cid/14/922", "source": "blinkit"},
        {"name": "Vegetables", "url": "https://blinkit.com/cn/vegetables-fruits/cid/1489/1495", "source": "blinkit"},
        {"name": "Snacks", "url": "https://blinkit.com/cn/munchies/cid/1239", "source": "blinkit"},
         # User can add more here
    ]

    all_products = []

    with sync_playwright() as p:
        # Launch browser (Headless=False to see what's happening)
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        )
        page = context.new_page()

        # Step 1: Set Location (Important for quick commerce)
        print("Navigating to Blinkit home...")
        try:
            page.goto("https://blinkit.com/", timeout=60000)
            page.wait_for_load_state('networkidle')
            print("Please manually set location if prompted! Waiting 10s...")
            time.sleep(10) 
            
            # Step 2: Discover Categories
            print("Discovering categories...")
            # Look for category links. Usually on home page or sidebar.
            # We try to find links that look like /cn/<category>/cid/<id>
            category_links = page.evaluate('''() => {
                const links = Array.from(document.querySelectorAll('a'));
                return links
                    .map(a => a.href)
                    .filter(href => href.includes('/cn/') && href.includes('/cid/'))
                    .filter((v, i, a) => a.indexOf(v) === i); // Unique
            }''')
            
            print(f"Found {len(category_links)} potential category links.")
            
            # Filter and Limit to avoid scraping sub-sub-categories if they duplicate
            # For now, we take top 20 distinct ones to cover "all grocery" broadly without taking forever
            targets = []
            seen_cids = set()
            
            for link in category_links:
                # Basic dedup based on CID to avoid multiple banners pointing to same cat
                try:
                    cid = link.split('/cid/')[1].split('/')[0]
                    if cid not in seen_cids:
                        seen_cids.add(cid)
                        # Infer name from URL
                        name_part = link.split('/cn/')[1].split('/')[0].replace('-', ' ').title()
                        targets.append({"name": name_part, "url": link, "source": "blinkit"})
                except:
                    continue
            
            print(f"Refined to {len(targets)} unique categories: {[t['name'] for t in targets]}")
            
        except Exception as e:
            print(f"Error during discovery: {e}")
            targets = [] # Fallback

        # Step 3: Scrape Discovered Categories
        for target in targets:
            if target['source'] == 'blinkit':
                items = scrape_blinkit_category(page, target['url'], target['name'])
                all_products.extend(items)
                # Short pause between categories
                time.sleep(3)
        
        # Step 4: Specific Search for "Rice" (as requested by user)
        # Search URLs usually follow pattern: https://blinkit.com/s/?q=rice
        search_terms = ["Rice"]
        for term in search_terms:
            search_url = f"https://blinkit.com/s/?q={term}"
            print(f"Executing specific search for: {term}")
            items = scrape_blinkit_category(page, search_url, "Rice")
            all_products.extend(items)

        browser.close()

    # Post-processing data
    # Filter valid items
    cleaned_products = []
    seen_names = set()
    
    for p in all_products:
        if p['name'] and p['name'] not in seen_names and p['price'] > 0:
            seen_names.add(p['name'])
            # Ensure fields
            if 'stockQuantity' not in p:
                p['stockQuantity'] = 50 # Default
            if 'inStock' not in p:
                p['inStock'] = True
            if 'brand' not in p or p['brand'] == 'Unknown':
                 # Guess brand from name (first word)
                 p['brand'] = p['name'].split()[0]
            
            cleaned_products.append(p)

    # Save to file
    if cleaned_products:
        print(f"Saving {len(cleaned_products)} unique products to {OUTPUT_FILE}")
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(cleaned_products, f, indent=2)
    else:
        print("No products collected. Please check URLs or your internet/location settings.")

if __name__ == "__main__":
    main()
