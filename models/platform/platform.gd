@tool
extends Node2D

@export_enum("None", "Blue", "Red") var platform_type := "None":
	set(value):
		platform_type = value
		_update_platform()

@export var size := Vector2(300, 100):
	set(value):
		size = value
		_update_platform()

var shape: Shape2D = RectangleShape2D.new()

func _ready() -> void:
	shape.size = size
	$StaticBody2D/CollisionShape2D.shape = shape
	_update_platform()

func _update_platform():
	if not is_inside_tree():
		return
	
	$StaticBody2D/ColorRect.size = size
	$StaticBody2D/ColorRect.position = Vector2(-size.x / 2, -size.y / 2)
	
	match platform_type:
		"None":
			$StaticBody2D.collision_layer = 1
			$StaticBody2D/ColorRect.color = Color.WHITE
		"Blue":
			$StaticBody2D.collision_layer = 2
			$StaticBody2D/ColorRect.color = Color.BLUE
		"Red":
			$StaticBody2D.collision_layer = 4
			$StaticBody2D/ColorRect.color = Color.RED
	
	shape.size = size
