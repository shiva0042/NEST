from PIL import Image, ImageDraw

def remove_background_flood(input_path, output_path, tolerance=50):
    img = Image.open(input_path).convert("RGBA")
    width, height = img.size
    
    # Get the background color from the top-left corner
    bg_color = img.getpixel((0, 0))
    
    # Create a mask initialized to 0 (transparent)
    # We will flood fill this mask with 1 (opaque) for the background
    # But wait, ImageDraw.floodfill fills the *image*.
    
    # Let's try a different approach. 
    # We want to make the background transparent.
    # We can use ImageDraw.floodfill to fill the background with a specific unique color (e.g., magenta),
    # then turn that color transparent.
    
    # Find a color not in the image? Or just use (0,0,0,0) directly if possible?
    # ImageDraw.floodfill doesn't support alpha channel filling well in all versions.
    
    # Alternative: BFS/DFS from corners.
    
    visited = set()
    queue = [(0, 0), (width-1, 0), (0, height-1), (width-1, height-1)]
    
    pixels = img.load()
    
    # Helper to check if color is close to bg_color
    def is_similar(c1, c2, tol):
        return abs(c1[0] - c2[0]) <= tol and \
               abs(c1[1] - c2[1]) <= tol and \
               abs(c1[2] - c2[2]) <= tol

    # Verify corners are actually background
    start_nodes = []
    for x, y in queue:
        if is_similar(pixels[x, y], bg_color, tolerance):
            start_nodes.append((x, y))
            visited.add((x, y))
            
    queue = start_nodes
    
    while queue:
        x, y = queue.pop(0)
        
        # Set to transparent
        pixels[x, y] = (0, 0, 0, 0)
        
        # Check neighbors
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited:
                    if is_similar(pixels[nx, ny], bg_color, tolerance):
                        visited.add((nx, ny))
                        queue.append((nx, ny))
                        
    img.save(output_path, "PNG")
    print(f"Saved flood-filled transparent image to {output_path}")

if __name__ == "__main__":
    remove_background_flood("assets/images/logo_original.png", "assets/images/logo.png", tolerance=30)
