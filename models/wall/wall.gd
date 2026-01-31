@tool
extends StaticBody2D

var TEXTURES = {
	Types.Mask.NONE: preload("res://sprites/Walls/NONE_Wall.png"),
	Types.Mask.BLUE: preload("res://sprites/Walls/BLUE_Wall.png"),
	Types.Mask.RED: preload("res://sprites/Walls/RED_Wall.png")
}

@export var wall_type := Types.Mask.NONE:
	set(value):
		$TextureRect.texture = TEXTURES[value]
		wall_type = value
		_update_wall()

@export var size: Vector2 = Vector2(64, 32):
	set(value):
		size = value
		_update_wall()

func _ready() -> void:
	_set_opacity(Types.Mask.NONE)
	GameManager.changed_mask.connect(_on_mask_change)
	_update_wall()

	
func _set_opacity(mask):
	if mask == wall_type or wall_type == Types.Mask.NONE:
		$TextureRect.modulate = Color.WHITE
	else:
		$TextureRect.modulate = Color(1,1,1,0.1)

func _on_mask_change(mask: Types.Mask) -> void:
	_set_opacity(mask)

func _update_wall():
	if not is_inside_tree():
		return
	
	match wall_type:
		Types.Mask.NONE:
			collision_layer = Types.OBJECTS_LAYER
		Types.Mask.BLUE:
			collision_layer = Types.BLUE_OBJECT_LAYER
		Types.Mask.RED:
			collision_layer = Types.RED_OBJECT_LAYER
