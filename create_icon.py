from PIL import Image, ImageDraw

def create_icon(input_path, output_path, bg_color="#FFFDD0", size=(1024, 1024)):
    # Load the transparent logo
    logo = Image.open(input_path).convert("RGBA")
    
    # Calculate aspect ratio to fit within the new size with padding
    # We want the logo to be about 90% of the icon size to look bigger
    target_logo_size = int(size[0] * 0.9)
    
    # Resize logo maintaining aspect ratio
    logo.thumbnail((target_logo_size, target_logo_size), Image.Resampling.LANCZOS)
    
    # Create background
    # User asked for "circle icon". 
    # If we make a square background, the OS masks it.
    # If we make a circle background on transparent, it works for web/some androids.
    # Let's make a square cream background. It's the safest for "icon with background".
    icon = Image.new("RGBA", size, bg_color)
    
    # Center the logo
    logo_x = (size[0] - logo.width) // 2
    logo_y = (size[1] - logo.height) // 2
    
    # Paste logo
    icon.paste(logo, (logo_x, logo_y), logo)
    
    icon.save(output_path, "PNG")
    print(f"Saved icon to {output_path}")

if __name__ == "__main__":
    # Cream color: #FFFDD0
    create_icon("assets/images/logo.png", "assets/images/logo_icon.png", bg_color="#FFFDD0")
