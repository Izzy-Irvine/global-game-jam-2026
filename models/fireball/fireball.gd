extends Area2D

func _ready():
	_set_opacity(Types.Mask.NONE)

func _set_opacity(mask):
	if mask == Types.Mask.RED:
		$ColorRect.modulate = Color.WHITE
	else:
		$ColorRect.modulate = Color(1,1,1,0.1)

func _on_body_entered(body: Node2D) -> void:
	GameManager.death()
