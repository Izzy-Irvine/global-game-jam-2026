extends Area2D

@export var mask: Types.Mask = Types.Mask.BLUE:
	set(value):
		mask = value
		_update_mask_type(value)
		
func _update_mask_type(mask: Types.Mask):
	match mask:
		Types.Mask.NONE:
			$ColorRect.visible = false
		Types.Mask.BLUE:
			$ColorRect.visible = true
			$ColorRect.color = "#0000ff"
		Types.Mask.RED:
			$ColorRect.visible = true
			$ColorRect.color = "#ff0000"
			

func _on_body_entered(body: Node2D) -> void:
	if $ColorRect.visible:
		print("Picked up " + str(mask))
		GameManager.pickup_mask(mask)
		$ColorRect.visible = false
