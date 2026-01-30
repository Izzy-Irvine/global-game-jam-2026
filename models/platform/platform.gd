@tool
extends StaticBody2D

@export var platform_type := Types.Mask.NONE:
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
	$CollisionShape2D.shape = shape
	_update_platform()

func _update_platform():
	if not is_inside_tree():
		return
	
	$ColorRect.size = size
	$ColorRect.position = Vector2(-size.x / 2, -size.y / 2)
	
	match platform_type:
		Types.Mask.NONE:
			collision_layer = 1
			$ColorRect.color = Color.WHITE
		Types.Mask.BLUE:
			collision_layer = 2
			$ColorRect.color = Color.BLUE
		Types.Mask.RED:
			collision_layer = 4
			$ColorRect.color = Color.RED
	
	shape.size = size
