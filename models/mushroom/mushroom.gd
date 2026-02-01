extends Area2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("default")
	_set_opacity(Types.Mask.NONE)
	GameManager.changed_mask.connect(_set_opacity)

func _set_opacity(mask):
	if mask == Types.Mask.RED:
		sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color(1,1,1,0.1)

func _on_body_entered(body):
	body.velocity.y = -1100
	body.is_jumping = true
	body.jump_held_duration = 0
	body.mushroom_bounce = 1
