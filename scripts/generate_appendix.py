
import os
import re

def remove_comments(content):
    # Remove multi-line comments
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    
    # Remove single-line comments // or ///
    lines = content.split('\n')
    cleaned_lines = []
    for line in lines:
        stripped_line = line.strip()
        if not stripped_line.startswith('//') and not stripped_line.startswith('///'):
             # Handle trailing comments
             if '//' in line:
                 # Check if // is not inside quotes
                 parts = line.split('//')
                 if parts[0].strip():
                     cleaned_lines.append(parts[0].rstrip())
             elif stripped_line:
                 cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines)

files = [
    r"d:\vs\anti\near_basket\lib\core\constants\app_colors.dart",
    r"d:\vs\anti\near_basket\lib\core\data\popular_products_catalog.dart",
    r"d:\vs\anti\near_basket\lib\core\models\shop_models.dart",
    r"d:\vs\anti\near_basket\lib\core\providers\auth_provider.dart",
    r"d:\vs\anti\near_basket\lib\core\providers\cart_provider.dart",
    r"d:\vs\anti\near_basket\lib\core\providers\sales_provider.dart",
    r"d:\vs\anti\near_basket\lib\core\providers\store_provider.dart",
    r"d:\vs\anti\near_basket\lib\core\providers\theme_provider.dart",
    r"d:\vs\anti\near_basket\lib\core\theme\app_theme.dart",
    r"d:\vs\anti\near_basket\lib\core\widgets\theme_toggle_button.dart",
    r"d:\vs\anti\near_basket\lib\core\widgets\web_layout.dart",
    r"d:\vs\anti\near_basket\lib\features\auth\screens\customer_login_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\auth\screens\role_selection_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\auth\screens\shop_login_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\auth\screens\shop_signup_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\customer_dashboard\stats_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\models\category_model.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\models\product_model.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\models\shop_model.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\cart_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\home_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\offers_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\search_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\shop_details_view.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\store_map_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\map_discovery\screens\stores_list_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\models\models.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\product_onboarding.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\providers\onboarding_provider.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\screens\custom_product_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\screens\product_onboarding_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\services\catalog_service.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\widgets\brand_step.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\widgets\category_step.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\widgets\product_type_step.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\widgets\subcategory_step.dart",
    r"d:\vs\anti\near_basket\lib\features\product_onboarding\widgets\variant_step.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\add_offer_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\add_product_catalog_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\add_product_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\analytics_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\billing_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\dashboard_screen.dart",
    r"d:\vs\anti\near_basket\lib\features\shop_dashboard\screens\inventory_screen.dart",
    r"d:\vs\anti\near_basket\lib\firebase_options.dart",
    r"d:\vs\anti\near_basket\lib\main.dart",
    r"d:\vs\anti\near_basket\lib\screens\database_seed_screen.dart",
    r"d:\vs\anti\near_basket\lib\test_app.dart",
    r"d:\vs\anti\near_basket\lib\utils\seed_firestore.dart"
]

all_code = []

for file_path in files:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            all_code.append(f"\n\n// --- FILE: {os.path.basename(file_path)} ---\n")
            all_code.append(remove_comments(content))

joined_code = "".join(all_code)
joined_code = re.sub(r'\n\s*\n', '\n\n', joined_code)

output_file = r"C:\Users\SRK\.gemini\antigravity\brain\fd813824-ed65-4d5a-853d-15eafa05cd9a\NEST_APPENDIX_CODE.txt"
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(joined_code)

print(f"Saved to {output_file}")
