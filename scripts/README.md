# Product Collection Scripts

This directory contains scripts to help you collect real product data from Blinkit and other platforms to populate your inventory.

## Prerequisites

1.  Python installed.
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Install Playwright browsers:
    ```bash
    playwright install
    ```

## Usage

1.  Open `collect_products.py` and edit the `targets` list if you want to scrape specific categories.
2.  Run the script:
    ```bash
    python collect_products.py
    ```
    *   This will launch a browser window (Chromium).
    *   **Important**: When the browser opens, you might need to manually select a delivery location on Blinkit's website if it prompts you, so that it shows products and prices relevant to your area. The script pauses/waits for data, but manual intervention for location helps.
3.  The script will look for product data (using Schema.org JSON-LD tags hidden in the page) and save it to `../assets/data/collected_products.json`.

## Integration

Once `collected_products.json` is generated, the Flutter app's `ProductModel` can be updated to load this JSON instead of using mock data.
