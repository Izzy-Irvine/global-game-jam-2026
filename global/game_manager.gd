extends Node

const MASK_KEY_MAPPING = {
	"mask1": Types.Mask.NONE,
	"mask2": Types.Mask.BLUE,
	"mask3": Types.Mask.RED
}

var game_state = GameState.new()

signal changed_mask(mask: Types.Mask)


func change_state(new_mask: Types.Mask):
	game_state.current_mask = new_mask
	print("changed to " + str(new_mask))
	changed_mask.emit(new_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in MASK_KEY_MAPPING:
		var mask = MASK_KEY_MAPPING[key]
		if Input.is_action_just_pressed(key) and game_state.current_mask != mask:
			change_state(mask)
		
