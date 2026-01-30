extends Node

enum Mask {
	NONE,
	BLUE,
	GREEN
}

const MASK_KEY_MAPPING = {
	"mask1": Mask.NONE,
	"mask2": Mask.BLUE,
	"mask3": Mask.GREEN
}

var current_mask: Mask = Mask.NONE

signal changed_mask(mask: Mask)


func change_state(new_mask: Mask):
	current_mask = new_mask
	print("changed to " + str(new_mask))
	changed_mask.emit(new_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in MASK_KEY_MAPPING:
		var mask = MASK_KEY_MAPPING[key]
		if Input.is_action_just_pressed(key) and current_mask != mask:
			change_state(mask)
		
