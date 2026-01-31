extends Area2D

@onready var sprite = $ColorRect

func _ready():
	_set_opacity(Types.Mask.NONE)
	GameManager.changed_mask.connect(_set_opacity)

func _set_opacity(mask):
	if mask == Types.Mask.BLUE:
		sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color(1,1,1,0.1)

func _on_body_entered(body):
	body.bubble_jump = true

func _on_body_exited(body):
	body.bubble_jump = false
