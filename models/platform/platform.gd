@tool
extends StaticBody2D

var TEXTURES = {
	Types.Mask.NONE: preload("res://sprites/Ground/NONE/NONE_Top_Center.png"),
	Types.Mask.BLUE: preload("res://sprites/Ground/BLUE/BLUE_Top_Center.png"),
	Types.Mask.RED: preload("res://sprites/Ground/RED/RED_Top_Center.png")
}

@export var platform_type := Types.Mask.NONE:
	set(value):
		$TextureRect.texture = TEXTURES[value]
		platform_type = value
		_update_platform()

@export var size: Vector2 = Vector2(64, 32):
	set(value):
		size = value
		_update_platform()

var shape: Shape2D = RectangleShape2D.new()

func _ready() -> void:
	shape.size = size
	$CollisionShape2D.shape = shape
	_update_platform()

func _update_platform():
	if not is_inside_tree():
		return
	
	$TextureRect.size = size
	$TextureRect.position = Vector2(-size.x / 2, -size.y / 2)
	
	match platform_type:
		Types.Mask.NONE:
			collision_layer = 1
		Types.Mask.BLUE:
			collision_layer = 2
		Types.Mask.RED:
			collision_layer = 4
	
	shape.size = size
