extends Node

const MASK_KEY_MAPPING = {
	"mask1": Types.Mask.NONE,
	"mask2": Types.Mask.BLUE,
	"mask3": Types.Mask.RED
}

var death_count = 0

var game_state = GameState.new()

var saved_checkpoint = game_state

signal changed_mask(mask: Types.Mask)
signal died()

signal reload_state()

func change_mask(new_mask: Types.Mask):
	game_state.current_mask = new_mask
	print("changed to " + str(new_mask))
	changed_mask.emit(new_mask)

func pickup_mask(new_mask: Types.Mask):
	game_state.masks_collected.append(new_mask)
	change_mask(new_mask)
	save_checkpoint()

func save_object_state(object, state):
	game_state.object_states[object] = state

func get_object_state(object, key):
	return game_state.object_states[object][key]

func death():
	print("You died!")
	print("Reloading state: " + str(saved_checkpoint.object_states))
	death_count += 1
	died.emit(death_count)
	game_state = saved_checkpoint.copy()
	reload_state.emit()
	change_mask(game_state.current_mask)
	
func save_checkpoint():
	print("Saving state: " + str(game_state.object_states))
	saved_checkpoint = game_state.copy()


# Save initial save of the game after first frame is complete - to allow all objects to set their object state
func _ready():
	call_deferred("save_checkpoint")

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
		
