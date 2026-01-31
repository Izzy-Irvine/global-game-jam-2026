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
	_set_opacity(Types.Mask.NONE)
	GameManager.changed_mask.connect(_on_mask_change)
	_update_platform()

	
func _set_opacity(mask):
	if mask == platform_type or platform_type == Types.Mask.NONE:
		$TextureRect.modulate = Color.WHITE
	else:
		$TextureRect.modulate = Color(1,1,1,0.1)

func _on_mask_change(mask: Types.Mask) -> void:
	_set_opacity(mask)

func _update_platform():
	if not is_inside_tree():
		return
	
	$TextureRect.size = size
	$TextureRect.position = Vector2(-size.x / 2, -size.y / 2)
	
	match platform_type:
		Types.Mask.NONE:
			collision_layer = Types.OBJECTS_LAYER
		Types.Mask.BLUE:
			collision_layer = Types.BLUE_OBJECT_LAYER
		Types.Mask.RED:
			collision_layer = Types.RED_OBJECT_LAYER
	
	shape.size = size

func _physics_process(delta: float):
	# When you press down you will go through platforms
	$CollisionShape2D.disabled = Input.is_action_pressed("phase_platform")
