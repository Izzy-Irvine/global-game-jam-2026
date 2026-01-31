extends Area2D

@export var mask: Types.Mask = Types.Mask.BLUE:
	set(value):
		mask = value
		_update_mask_type(value)


func _ready():
	GameManager.reload_state.connect(_on_reload_state)
	GameManager.save_object_state(get_instance_id(), {
		"collected": false
	})

func _on_reload_state():
	$Sprite2D.visible = not GameManager.get_object_state(get_instance_id(), "collected")
		
func _update_mask_type(mask: Types.Mask):
	pass
	#match mask:
		#Types.Mask.NONE:
			#$Sprite2D.visible = false
		#Types.Mask.BLUE:
			#$Sprite2D.visible = true
			#$Sprite2D.color = "#0000ff"
		#Types.Mask.RED:
			#$Sprite2D.visible = true
			#$Sprite2D.color = "#ff0000"
			

func _on_body_entered(body: Node2D) -> void:
	if $Sprite2D.visible:
		print("Picked up " + str(mask))
		GameManager.pickup_mask(mask)
		GameManager.save_object_state(get_instance_id(), { "collected": true })
		$Sprite2D.visible = false
