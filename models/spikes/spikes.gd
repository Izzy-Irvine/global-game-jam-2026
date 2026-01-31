extends Area2D

const TEXTURES = {
	Types.Mask.NONE: preload("res://sprites/Spikes/Spikes_normal.png"),
	Types.Mask.BLUE: preload("res://sprites/Spikes/Spikes_blue.png"),
	Types.Mask.RED: preload("res://sprites/Spikes/Spikes_red.png")
}

func _ready():
	GameManager.changed_mask.connect(_change_texture)
	_change_texture(Types.Mask.NONE)

func _change_texture(mask):
	$Sprite2D.texture = TEXTURES[mask]
	

func _on_body_entered(body: Node2D) -> void:
	GameManager.death()
