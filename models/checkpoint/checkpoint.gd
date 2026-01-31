extends Area2D


var collected = false

@onready var animation = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.reload_state.connect(_on_reload_state)
	_save_state()
	animation.play("idle")

func _save_state() -> void:
	GameManager.save_object_state(get_instance_id(), {
		"collected": collected
	})

func _on_reload_state() -> void:
	collected = GameManager.get_object_state(get_instance_id(), "collected")

func _on_body_entered(body: Node2D) -> void:
	if not collected:
		collected = true
		print("Wooo, checkpoint")
		animation.play("activated")
		_save_state()
		GameManager.save_checkpoint()
