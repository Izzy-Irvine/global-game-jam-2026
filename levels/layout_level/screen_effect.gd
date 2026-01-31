extends ColorRect

@onready var shader_material: ShaderMaterial = material

# Map your enum to shader integers
const MASK_TO_SHADER = {
	Types.Mask.NONE: 0,
	Types.Mask.BLUE: 1,
	Types.Mask.RED: 2,
	# Types.Mask.BLACK: 3  # Add when ready
}

func _ready() -> void:
	# Connect to GameManager signal
	GameManager.changed_mask.connect(_on_mask_changed)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Set initial state
	_on_mask_changed(GameManager.game_state.current_mask)

# In your ColorRect script
var tween: Tween

func _on_mask_changed(new_mask: Types.Mask) -> void:
	var shader_state = MASK_TO_SHADER.get(new_mask, 0)
	# Cancel existing tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		func(value): shader_material.set_shader_parameter("mask_state", value),
		shader_material.get_shader_parameter("mask_state"),
		shader_state,
		0.5  # Transition duration
	)
