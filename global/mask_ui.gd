extends Node2D

@export var mask_type: Types.Mask = Types.Mask.NONE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mask_type != Types.Mask.NONE:
		visible = false
		$Outline.visible = false
	GameManager.changed_mask.connect(_on_mask_change)


func _on_mask_change(mask):
	if mask != mask_type:
		$Outline.visible = false
		return
	
	visible = true
	$Outline.visible = true
