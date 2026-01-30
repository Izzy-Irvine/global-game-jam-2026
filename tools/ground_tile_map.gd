@tool
extends Node2D

signal tiles_updated

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

@export var tile_data: PackedByteArray:
	set(value):
		tile_data = value
		_rebuild_tiles()

@export var show_grid_in_editor: bool = true:
	set(value):
		show_grid_in_editor = value
		if is_inside_tree():
			queue_redraw()

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

@export var fill_all: bool = false:
	set(value):
		if value:
			_fill_grid(true)

@export var clear_all: bool = false:
	set(value):
		if value:
			_clear_grid()

var _tile_sprites: Dictionary = {}
var _current_mask: int = 0  # Use int instead of enum type
var _static_body: StaticBody2D = null

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Connect to GameManager at runtime only
		if has_node("/root/GameManager"):
			var gm = get_node("/root/GameManager")
			gm.changed_mask.connect(_on_mask_changed)
			_current_mask = gm.current_mask
	
	_ensure_tile_data()
	_rebuild_tiles()

func _get_scaled_tile_size() -> int:
	if tile_set_resource:
		return tile_set_resource.tile_size * tile_scale
	return 64 * tile_scale

func _get_grid_offset() -> Vector2:
	var scaled_size = _get_scaled_tile_size()
	return Vector2(
		-(grid_size.x * scaled_size) / 2.0,
		-(grid_size.y * scaled_size) / 2.0
	)

func _ensure_tile_data():
	var required_size = grid_size.x * grid_size.y
	if tile_data.size() != required_size:
		tile_data.resize(required_size)
		for i in range(required_size):
			tile_data[i] = 0

func _fill_grid(solid: bool):
	_ensure_tile_data()
	for i in range(tile_data.size()):
		tile_data[i] = 1 if solid else 0
	_rebuild_tiles()

func _clear_grid():
	_fill_grid(false)

func _on_mask_changed(mask: int):
	_current_mask = mask
	_update_all_tile_textures()

func _rebuild_tiles():
	if not is_inside_tree():
		return
	
	# Clear existing sprites
	for sprite in _tile_sprites.values():
		if is_instance_valid(sprite):
			sprite.queue_free()
	_tile_sprites.clear()
	
	# Clear old collision body
	if _static_body and is_instance_valid(_static_body):
		_static_body.queue_free()
		_static_body = null
	
	_ensure_tile_data()
	
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var coord = Vector2i(x, y)
			if _is_solid(coord):
				var sprite = Sprite2D.new()
				sprite.position = Vector2(
					offset.x + x * scaled_size + scaled_size / 2.0,
					offset.y + y * scaled_size + scaled_size / 2.0
				)
				sprite.centered = true
				sprite.scale = Vector2(tile_scale, tile_scale)
				add_child(sprite)
				_tile_sprites[coord] = sprite
				_update_tile_texture(coord)
	
	_rebuild_collision()
	queue_redraw()

func _rebuild_collision():
	if _tile_sprites.is_empty():
		return
	
	var scaled_size = _get_scaled_tile_size()
	var offset = _get_grid_offset()
	
	_static_body = StaticBody2D.new()
	_static_body.name = "GroundCollision"
	add_child(_static_body)
	
	for coord in _tile_sprites.keys():
		var collision = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(scaled_size, scaled_size)
		collision.shape = rect_shape
		collision.position = Vector2(
			offset.x + coord.x * scaled_size + scaled_size / 2.0,
			offset.y + coord.y * scaled_size + scaled_size / 2.0
		)
		_static_body.add_child(collision)

func _update_all_tile_textures():
	for coord in _tile_sprites.keys():
		_update_tile_texture(coord)

func _update_tile_texture(coord: Vector2i):
	if not _tile_sprites.has(coord) or tile_set_resource == null:
		return
	
	var tile_position = _determine_tile_position(coord)
	var texture = tile_set_resource.get_texture(_current_mask, tile_position)
	_tile_sprites[coord].texture = texture

func _determine_tile_position(coord: Vector2i) -> String:
	var above = not _is_solid(coord + Vector2i(0, -1))
	var below = not _is_solid(coord + Vector2i(0, 1))
	var left_empty = not _is_solid(coord + Vector2i(-1, 0))
	var right_empty = not _is_solid(coord + Vector2i(1, 0))
	
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

func _is_solid(coord: Vector2i) -> bool:
	if coord.x < 0 or coord.x >= grid_size.x:
		return false
	if coord.y < 0 or coord.y >= grid_size.y:
		return false
	var idx = coord.y * grid_size.x + coord.x
	if idx >= tile_data.size():
		return false
	return tile_data[idx] == 1

func set_tile(coord: Vector2i, solid: bool):
	if coord.x < 0 or coord.x >= grid_size.x:
		return
	if coord.y < 0 or coord.y >= grid_size.y:
		return
	var idx = coord.y * grid_size.x + coord.x
	var new_value = 1 if solid else 0
	if tile_data[idx] != new_value:
		tile_data[idx] = new_value
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
	
	# Draw grid lines
	if show_grid_in_editor or paint_mode or erase_mode:
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
	
	# Highlight cells
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var coord = Vector2i(x, y)
			var rect = Rect2(
				offset.x + x * scaled_size + 2,
				offset.y + y * scaled_size + 2,
				scaled_size - 4,
				scaled_size - 4
			)
			
			if _is_solid(coord):
				draw_rect(rect, Color(0.5, 0.8, 0.5, 0.3))
			elif paint_mode or erase_mode:
				draw_rect(rect, Color(0.3, 0.3, 0.3, 0.2))
	
	# Draw border
	draw_rect(
		Rect2(offset.x, offset.y, grid_size.x * scaled_size, grid_size.y * scaled_size),
		Color.WHITE, false, 2.0
	)
	
	# Draw origin crosshair
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color.RED, 2.0)
	draw_line(Vector2(0, -10), Vector2(0, 10), Color.GREEN, 2.0)
	
	# Draw mode indicator
	if paint_mode:
		_draw_mode_label("PAINT MODE", Color.GREEN)
	elif erase_mode:
		_draw_mode_label("ERASE MODE", Color.RED)

func _draw_mode_label(text: String, color: Color):
	var font = ThemeDB.fallback_font
	var font_size = 16
	var offset = _get_grid_offset()
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var label_pos = Vector2(offset.x, offset.y - 10)
	draw_rect(Rect2(label_pos.x - 2, label_pos.y - 18, text_size.x + 10, 22), Color(0, 0, 0, 0.7))
	draw_string(font, Vector2(label_pos.x + 3, label_pos.y - 2), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
