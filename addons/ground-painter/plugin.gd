

# TO USE IN SCENE:
# Create Node2D, preferably name it "TileMap" or something
# Drag ground_tile_map.gd script onto it from tools folder
# make sure the folders for sprite tiles are being accessed properly.

@tool
extends EditorPlugin

var _tilemap: Node2D = null
var _painting: bool = false

func _handles(object) -> bool:
	if object is Node2D:
		return object.get_script() and object.has_method("set_tile") and object.has_method("world_to_grid")
	return false

func _edit(object):
	_tilemap = object as Node2D

func _make_visible(visible: bool):
	if not visible:
		_tilemap = null

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _tilemap == null:
		return false
	
	var paint_mode = _tilemap.get("paint_mode")
	var erase_mode = _tilemap.get("erase_mode")
	
	if not (paint_mode or erase_mode):
		return false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_painting = true
			_do_paint(event.position, paint_mode)
			return true
		else:
			_painting = false
			# Painting stopped - could trigger immediate collision rebuild here
			# _tilemap.call("_rebuild_collision_immediate")
			return true
	
	if event is InputEventMouseMotion and _painting:
		var current_paint_mode = _tilemap.get("paint_mode")
		_do_paint(event.position, current_paint_mode)
		return true
	
	return false

func _do_paint(viewport_pos: Vector2, solid: bool):
	if _tilemap == null:
		return
	
	var transform = _tilemap.get_viewport_transform() * _tilemap.get_global_transform()
	var local_pos = transform.affine_inverse() * viewport_pos
	
	var coord = _tilemap.world_to_grid(local_pos + _tilemap.global_position)
	_tilemap.set_tile(coord, solid)
