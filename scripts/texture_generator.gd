extends Node

# Procedural Texture Generator
# Creates basic textures at runtime for walls/floors
# No external files needed — generates pixel patterns

func create_grid_texture(size: int = 128, line_color: Color = Color(0.3, 0.3, 0.32), bg_color: Color = Color(0.2, 0.2, 0.22), line_width: int = 2, grid_size: int = 16) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(bg_color)
	
	# Draw grid lines
	for x in range(size):
		for y in range(size):
			if x % grid_size < line_width or y % grid_size < line_width:
				img.set_pixel(x, y, line_color)
	
	var tex = ImageTexture.create_from_image(img)
	return tex

func create_brick_texture(size: int = 128, mortar: Color = Color(0.25, 0.25, 0.27), brick: Color = Color(0.35, 0.33, 0.3), mortar_width: int = 2, brick_h: int = 16, brick_w: int = 32) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(brick)
	
	var row = 0
	var y = 0
	while y < size:
		# Horizontal mortar lines
		for x in range(size):
			for mw in range(mortar_width):
				if y + mw < size:
					img.set_pixel(x, y + mw, mortar)
		
		# Vertical mortar lines (offset every other row)
		var offset = (brick_w / 2) if row % 2 == 1 else 0
		var x2 = offset
		while x2 < size:
			for mw in range(mortar_width):
				for by in range(brick_h):
					if x2 + mw < size and y + by < size:
						img.set_pixel(x2 + mw, y + by, mortar)
			x2 += brick_w
		
		# Slight color variation per brick
		var bx = offset if row % 2 == 1 else 0
		while bx < size:
			var shade = randf_range(-0.03, 0.03)
			var b_color = Color(brick.r + shade, brick.g + shade, brick.b + shade)
			for px in range(mortar_width, min(brick_w, size - bx)):
				for py in range(mortar_width, min(brick_h, size - y)):
					if bx + px < size and y + py < size:
						img.set_pixel(bx + px, y + py, b_color)
			bx += brick_w
		
		y += brick_h
		row += 1
	
	return ImageTexture.create_from_image(img)

func create_metal_panel_texture(size: int = 128, base: Color = Color(0.28, 0.3, 0.32), rivet: Color = Color(0.4, 0.4, 0.42)) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(base)
	
	# Horizontal panel lines
	for x in range(size):
		for line_y in [0, size/4, size/2, size*3/4]:
			if line_y < size:
				img.set_pixel(x, line_y, base.darkened(0.15))
				if line_y + 1 < size:
					img.set_pixel(x, line_y + 1, base.lightened(0.1))
	
	# Rivets in corners of panels
	var rivet_r = 2
	var positions = []
	for px in [8, size - 8]:
		for py in [8, size/4 + 8, size/2 + 8, size*3/4 + 8]:
			positions.append(Vector2i(px, py))
	
	for pos in positions:
		for dx in range(-rivet_r, rivet_r + 1):
			for dy in range(-rivet_r, rivet_r + 1):
				if dx*dx + dy*dy <= rivet_r*rivet_r:
					var rx = pos.x + dx
					var ry = pos.y + dy
					if rx >= 0 and rx < size and ry >= 0 and ry < size:
						img.set_pixel(rx, ry, rivet)
	
	return ImageTexture.create_from_image(img)

func create_concrete_texture(size: int = 128, base: Color = Color(0.22, 0.22, 0.24)) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	# Noisy concrete
	for x in range(size):
		for y in range(size):
			var noise_val = randf_range(-0.04, 0.04)
			var c = Color(base.r + noise_val, base.g + noise_val, base.b + noise_val)
			img.set_pixel(x, y, c)
	
	return ImageTexture.create_from_image(img)

func create_floor_tile_texture(size: int = 128, tile_color: Color = Color(0.3, 0.3, 0.32), grout: Color = Color(0.2, 0.2, 0.22), tile_size: int = 32) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(grout)
	
	for tx in range(0, size, tile_size):
		for ty in range(0, size, tile_size):
			var shade = randf_range(-0.02, 0.02)
			var tc = Color(tile_color.r + shade, tile_color.g + shade, tile_color.b + shade)
			for px in range(1, tile_size - 1):
				for py in range(1, tile_size - 1):
					if tx + px < size and ty + py < size:
						img.set_pixel(tx + px, ty + py, tc)
	
	return ImageTexture.create_from_image(img)

func apply_texture_to_material(mat: StandardMaterial3D, tex: ImageTexture, uv_scale: float = 4.0):
	mat.albedo_texture = tex
	mat.uv1_scale = Vector3(uv_scale, uv_scale, uv_scale)
