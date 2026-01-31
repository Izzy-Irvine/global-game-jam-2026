extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	_set_opacity(Types.Mask.NONE)
	GameManager.changed_mask.connect(_set_opacity)
	

func _set_opacity(mask):
	if mask == Types.Mask.RED:
		sprite.modulate = Color.WHITE
		sprite.play("default")
	else:
		sprite.modulate = Color(1,1,1,0.1)
		sprite.pause()

func _on_body_entered(body: Node2D) -> void:
	GameManager.death()
