extends Node

const MASK_KEY_MAPPING = {
	"mask1": Types.Mask.NONE,
	"mask2": Types.Mask.BLUE,
	"mask3": Types.Mask.RED
}

var game_state = GameState.new()

signal changed_mask(mask: Types.Mask)


func change_mask(new_mask: Types.Mask):
	game_state.current_mask = new_mask
	print("changed to " + str(new_mask))
	changed_mask.emit(new_mask)

func pickup_mask(new_mask: Types.Mask):
	game_state.masks_collected.append(new_mask)
	change_mask(new_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in MASK_KEY_MAPPING:
		var mask = MASK_KEY_MAPPING[key]
		
		if game_state.current_mask == mask:
			continue
			
		if not game_state.masks_collected.has(mask):
			continue
		
		if Input.is_action_just_pressed(key):
			change_mask(mask)
		
