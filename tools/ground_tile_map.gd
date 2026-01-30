@tool
extends Node2D

signal tiles_updated

enum TerrainType {
	GROUND,
	STONE
}

enum PaintLayer {
	FOREGROUND,
	BACKGROUND
}

@export var tile_set_resource: GroundTileSet:
	set(value):
		tile_set_resource = value
		_rebuild_tiles()

@export var grid_size: Vector2i = Vector2i(10, 5):
	set(value):
		grid_size = value
		_ensure_tile_data()
		_rebuild_tiles()

@export_range(1, 4) var tile_scale: int = 2:
	set(value):
		tile_scale = value
		_rebuild_tiles()

@export var show_grid_in_editor: bool = true:
	set(value):
		show_grid_in_editor = value
		if is_inside_tree():
			queue_redraw()

@export_range(0.0, 1.0) var background_dim: float = 0.5:
	set(value):
		background_dim = value
		_update_background_modulation()

@export_category("Tile Data")
@export var foreground_data: PackedByteArray:
	set(value):
		foreground_data = value
		_rebuild_tiles()

@export var background_data: PackedByteArray:
	set(value):
		background_data = value
		_rebuild_tiles()

@export_category("Editor Tools")
@export var paint_mode: bool = false:
	set(value):
		paint_mode = value
		if value:
			erase_mode = false
		if is_inside_tree():
			queue_redraw()

@export var erase_mode: bool = false:
	set(value):
		erase_mode = value
		if value:
			paint_mode = false
		if is_inside_tree():
			queue_redraw()

@export_enum("Foreground", "Background") var paint_layer: int = 0:
	set(value):
		paint_layer = value
		if is_inside_tree():
			queue_redraw()

@export_enum("Ground", "Stone") var paint_terrain: int = 0:
	set(value):
		paint_terrain = value
		if is_inside_tree():
			queue_redraw()

@export_category("Quick Actions")
@export var fill_foreground: bool = false:
	set(value):
		if value:
			_fill_layer(PaintLayer.FOREGROUND, true)

@export var clear_foreground: bool = false:
	set(value):
		if value:
			_fill_layer(PaintLayer.FOREGROUND, false)

@export var fill_background: bool = false:
	set(value):
		if value:
			_fill_layer(PaintLayer.BACKGROUND, true)

@export var clear_background: bool = false:
	set(value):
		if value:
			_fill_layer(PaintLayer.BACKGROUND, false)

@export var clear_all: bool = false:
	set(value):
		if value:
			_fill_layer(PaintLayer.FOREGROUND, false)
			_fill_layer(PaintLayer.BACKGROUND, false)

var _fg_sprites: Dictionary = {}
var _bg_sprites: Dictionary = {}
var _current_mask: int = 0
var _static_body: StaticBody2D = null

func _ready() -> void:
	if not Engine.is_editor_hint():
		if has_node("/root/GameManager"):
			var gm = get_node("/root/GameManager")
			gm.changed_mask.connect(_on_mask_changed)
			# Access current_mask through game_state
			_current_mask = gm.game_state.current_mask
	
	_ensure_tile_data()
	_rebuild_tiles()

func _on_mask_changed(mask):
	# mask is Types.Mask enum, convert to int
	_current_mask = int(mask)
	_update_all_tile_textures()

func _get_scaled_tile_size() -> int:
	if tile_set_resource:
		return tile_set_resource.tile_size * tile_scale
	return 32 * tile_scale  # Default 32 now

func _get_grid_offset() -> Vector2:
	var scaled_size = _get_scaled_tile_size()
	return Vector2(
		-(grid_size.x * scaled_size) / 2.0,
		-(grid_size.y * scaled_size) / 2.0
	)

func _ensure_tile_data():
	var required_size = grid_size.x * grid_size.y
	if foreground_data.size() != required_size:
		foreground_data.resize(required_size)
		for i in range(required_size):
			foreground_data[i] = 0
	if background_data.size() != required_size:
		background_data.resize(required_size)
		for i in range(required_size):
			background_data[i] = 0

func _fill_layer(layer: PaintLayer, solid: bool):
	_ensure_tile_data()
	var terrain_value = (paint_terrain + 1) if solid else 0
	
	if layer == PaintLayer.FOREGROUND:
		for i in range(foreground_data.size()):
			foreground_data[i] = terrain_value
	else:
		for i in range(background_data.size()):
			background_data[i] = terrain_value
	
	_rebuild_tiles()

func _rebuild_tiles():
	if not is_inside_tree():
		return
	
	for sprite in _fg_sprites.values():
		if is_instance_valid(sprite):
			sprite.queue_free()
	_fg_sprites.clear()
	
	for sprite in _bg_sprites.values():
		if is_instance_valid(sprite):
			sprite.queue_free()
	_bg_sprites.clear()
	
	if _static_body and is_instance_valid(_static_body):
		_static_body.queue_free()
		_static_body = null
	
	_ensure_tile_data()
	
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	
	# Background tiles first (lower z-index)
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var coord = Vector2i(x, y)
			var bg_value = _get_tile_value(coord, PaintLayer.BACKGROUND)
			if bg_value > 0:
				var sprite = Sprite2D.new()
				sprite.position = Vector2(
					offset.x + x * scaled_size + scaled_size / 2.0,
					offset.y + y * scaled_size + scaled_size / 2.0
				)
				sprite.centered = true
				sprite.scale = Vector2(tile_scale, tile_scale)
				sprite.z_index = -1
				sprite.modulate = Color(background_dim, background_dim, background_dim, 1.0)
				add_child(sprite)
				_bg_sprites[coord] = sprite
				_update_tile_texture(coord, PaintLayer.BACKGROUND)
	
	# Foreground tiles
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var coord = Vector2i(x, y)
			var fg_value = _get_tile_value(coord, PaintLayer.FOREGROUND)
			if fg_value > 0:
				var sprite = Sprite2D.new()
				sprite.position = Vector2(
					offset.x + x * scaled_size + scaled_size / 2.0,
					offset.y + y * scaled_size + scaled_size / 2.0
				)
				sprite.centered = true
				sprite.scale = Vector2(tile_scale, tile_scale)
				sprite.z_index = 0
				add_child(sprite)
				_fg_sprites[coord] = sprite
				_update_tile_texture(coord, PaintLayer.FOREGROUND)
	
	_rebuild_collision()
	queue_redraw()

func _rebuild_collision():
	if _fg_sprites.is_empty():
		return
	
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	
	_static_body = StaticBody2D.new()
	_static_body.name = "TileCollision"
	add_child(_static_body)
	
	for coord in _fg_sprites.keys():
		var collision = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(scaled_size, scaled_size)
		collision.shape = rect_shape
		collision.position = Vector2(
			offset.x + coord.x * scaled_size + scaled_size / 2.0,
			offset.y + coord.y * scaled_size + scaled_size / 2.0
		)
		_static_body.add_child(collision)

func _update_background_modulation():
	for sprite in _bg_sprites.values():
		if is_instance_valid(sprite):
			sprite.modulate = Color(background_dim, background_dim, background_dim, 1.0)

func _update_all_tile_textures():
	for coord in _fg_sprites.keys():
		_update_tile_texture(coord, PaintLayer.FOREGROUND)
	for coord in _bg_sprites.keys():
		_update_tile_texture(coord, PaintLayer.BACKGROUND)

func _update_tile_texture(coord: Vector2i, layer: PaintLayer):
	var sprites = _fg_sprites if layer == PaintLayer.FOREGROUND else _bg_sprites
	
	if not sprites.has(coord) or tile_set_resource == null:
		return
	
	var tile_value = _get_tile_value(coord, layer)
	if tile_value == 0:
		return
	
	var terrain = tile_value - 1
	var tile_position = _determine_tile_position(coord, layer)
	var texture = tile_set_resource.get_texture(terrain, _current_mask, tile_position)
	sprites[coord].texture = texture

func _determine_tile_position(coord: Vector2i, layer: PaintLayer) -> String:
	var above = not _is_solid(coord + Vector2i(0, -1), layer)
	var below = not _is_solid(coord + Vector2i(0, 1), layer)
	var left_empty = not _is_solid(coord + Vector2i(-1, 0), layer)
	var right_empty = not _is_solid(coord + Vector2i(1, 0), layer)
	
	if above:
		if left_empty:
			return "Top_Left"
		elif right_empty:
			return "Top_Right"
		else:
			return "Top_Center"
	elif below:
		if left_empty:
			return "Bottom_Left"
		elif right_empty:
			return "Bottom_Right"
		else:
			return "Bottom_Center"
	elif left_empty:
		return "Left"
	elif right_empty:
		return "Right"
	else:
		return "Center"

func _get_tile_value(coord: Vector2i, layer: PaintLayer) -> int:
	if coord.x < 0 or coord.x >= grid_size.x:
		return 0
	if coord.y < 0 or coord.y >= grid_size.y:
		return 0
	var idx = coord.y * grid_size.x + coord.x
	var data = foreground_data if layer == PaintLayer.FOREGROUND else background_data
	if idx >= data.size():
		return 0
	return data[idx]

func _is_solid(coord: Vector2i, layer: PaintLayer) -> bool:
	return _get_tile_value(coord, layer) > 0

func set_tile(coord: Vector2i, solid: bool):
	if coord.x < 0 or coord.x >= grid_size.x:
		return
	if coord.y < 0 or coord.y >= grid_size.y:
		return
	
	var idx = coord.y * grid_size.x + coord.x
	var new_value = (paint_terrain + 1) if solid else 0
	
	if paint_layer == PaintLayer.FOREGROUND:
		if foreground_data[idx] != new_value:
			foreground_data[idx] = new_value
			_rebuild_tiles()
	else:
		if background_data[idx] != new_value:
			background_data[idx] = new_value
			_rebuild_tiles()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local_pos = world_pos - global_position
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	var adjusted_pos = local_pos - offset
	
	return Vector2i(
		int(floor(adjusted_pos.x / scaled_size)),
		int(floor(adjusted_pos.y / scaled_size))
	)

func _draw():
	if not Engine.is_editor_hint():
		return
	
	if not show_grid_in_editor and not paint_mode and not erase_mode:
		return
	
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	
	# Grid lines
	for y in range(grid_size.y + 1):
		draw_line(
			Vector2(offset.x, offset.y + y * scaled_size),
			Vector2(offset.x + grid_size.x * scaled_size, offset.y + y * scaled_size),
			Color(0.5, 0.5, 0.5, 0.5), 1.0
		)
	
	for x in range(grid_size.x + 1):
		draw_line(
			Vector2(offset.x + x * scaled_size, offset.y),
			Vector2(offset.x + x * scaled_size, offset.y + grid_size.y * scaled_size),
			Color(0.5, 0.5, 0.5, 0.5), 1.0
		)
	
	# Cell highlights
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var coord = Vector2i(x, y)
			var rect = Rect2(
				offset.x + x * scaled_size + 2,
				offset.y + y * scaled_size + 2,
				scaled_size - 4,
				scaled_size - 4
			)
			
			var fg_value = _get_tile_value(coord, PaintLayer.FOREGROUND)
			var bg_value = _get_tile_value(coord, PaintLayer.BACKGROUND)
			
			if fg_value > 0:
				var color = Color.GREEN if fg_value == 1 else Color.SLATE_GRAY
				draw_rect(rect, Color(color.r, color.g, color.b, 0.4))
			elif bg_value > 0:
				var color = Color.GREEN if bg_value == 1 else Color.SLATE_GRAY
				draw_rect(rect, Color(color.r, color.g, color.b, 0.2))
			elif paint_mode or erase_mode:
				draw_rect(rect, Color(0.3, 0.3, 0.3, 0.15))
	
	# Border
	draw_rect(
		Rect2(offset.x, offset.y, grid_size.x * scaled_size, grid_size.y * scaled_size),
		Color.WHITE, false, 2.0
	)
	
	# Origin crosshair
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color.RED, 2.0)
	draw_line(Vector2(0, -10), Vector2(0, 10), Color.GREEN, 2.0)
	
	# Mode label
	if paint_mode or erase_mode:
		_draw_mode_label()

func _draw_mode_label():
	var font = ThemeDB.fallback_font
	var font_size = 14
	var offset = _get_grid_offset()
	
	var mode_text = "PAINT" if paint_mode else "ERASE"
	var layer_text = "FG" if paint_layer == 0 else "BG"
	var terrain_text = "GROUND" if paint_terrain == 0 else "STONE"
	
	var text = "%s | %s | %s" % [mode_text, layer_text, terrain_text]
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	
	var label_pos = Vector2(offset.x, offset.y - 10)
	var mode_color = Color.GREEN if paint_mode else Color.RED
	
	draw_rect(Rect2(label_pos.x - 2, label_pos.y - 18, text_size.x + 10, 22), Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(label_pos.x + 3, label_pos.y - 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, mode_color)
