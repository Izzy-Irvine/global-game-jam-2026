@tool
extends Area2D

const TEXTURES = {
	Types.Mask.NONE: preload("res://sprites/Masks/Blue.png"),
	Types.Mask.BLUE: preload("res://sprites/Masks/Blue.png"),
	Types.Mask.RED: preload("res://sprites/Masks/Red.png"),
}

@export var sprite: Sprite2D

var _mask: Types.Mask = Types.Mask.BLUE

@export var mask: Types.Mask:
	get:
		return _mask
	set(value):
		_mask = value
		_apply_mask_visual()

var elapsed_time := 0.0


func _ready():
	# Ensure correct sprite at runtime
	_apply_mask_visual()

	# Runtime-only logic
	if not Engine.is_editor_hint():
		GameManager.reload_state.connect(_on_reload_state)
		GameManager.save_object_state(get_instance_id(), {
			"collected": false
		})


func _apply_mask_visual():
	if sprite == null:
		return

	var tex = TEXTURES[_mask]
	if sprite.texture == tex:
		return
	
	sprite.texture = tex
	sprite.visible = true


func _on_reload_state():
	sprite.visible = not GameManager.get_object_state(get_instance_id(), "collected")


func _on_body_entered(body: Node2D) -> void:
	if sprite.visible:
		print("Picked up ", mask)
		GameManager.pickup_mask(mask)
		GameManager.save_object_state(get_instance_id(), { "collected": true })
		sprite.visible = false


func _physics_process(delta: float) -> void:
	elapsed_time += delta
	sprite.position.y = -64.0 + sin(elapsed_time * 2.0) * 2.0
