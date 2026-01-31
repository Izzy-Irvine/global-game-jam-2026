@tool
extends Area2D

@export var mask: Types.Mask = Types.Mask.BLUE:
	set(value):
		mask = value
		_update_mask_type(value)


var base_position: Vector2
var elapsed_time = 0

func _ready():
	GameManager.reload_state.connect(_on_reload_state)
	GameManager.save_object_state(get_instance_id(), {
		"collected": false
	})
	base_position = position

func _on_reload_state():
	$Sprite2D.visible = not GameManager.get_object_state(get_instance_id(), "collected")
		
func _update_mask_type(mask: Types.Mask):
	pass
	match mask:
		Types.Mask.NONE:
			$Sprite2D.visible = false
		Types.Mask.BLUE:
			$Sprite2D.visible = true
			$Sprite2D.texture = preload("res://sprites/Masks/Blue.png")
		Types.Mask.RED:
			$Sprite2D.visible = true
			$Sprite2D.texture = preload("res://sprites/Masks/Red.png")
			

func _on_body_entered(body: Node2D) -> void:
	if $Sprite2D.visible:
		print("Picked up " + str(mask))
		GameManager.pickup_mask(mask)
		GameManager.save_object_state(get_instance_id(), { "collected": true })
		$Sprite2D.visible = false

func _physics_process(delta: float) -> void:
	elapsed_time += delta
	position.y = base_position.y + sin(elapsed_time * 2.0) * 2.0
	
