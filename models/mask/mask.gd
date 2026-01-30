extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if $ColorRect.visible:
		GameManager.pickup_mask(Types.Mask.BLUE)
		$ColorRect.visible = false
