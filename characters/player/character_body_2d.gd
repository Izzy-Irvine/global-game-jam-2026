extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -500.0

@onready var rect = $ColorRect

const MASK_COLOURS = {
	Types.Mask.NONE: "#aaaaaa",
	Types.Mask.BLUE: "#0000ff",
	Types.Mask.RED: "#ff0000"
}

func save_state():
	GameManager.save_object_state(get_instance_id(), {
		"position": position
	})

func _ready():
	GameManager.changed_mask.connect(_on_mask_changed)
	GameManager.reload_state.connect(_on_reload_state)
	
	save_state()
	
func _on_mask_changed(mask):
	update_mask(mask)

func _on_reload_state():
	var state = GameManager.game_state
	update_mask(state.current_mask)
	position = state.object_states[get_instance_id()]["position"]
	

func update_mask(mask):
	rect.color = MASK_COLOURS[mask]
	match mask:
		Types.Mask.NONE:
			collision_mask = 1
		Types.Mask.BLUE:
			collision_mask = 3
		Types.Mask.RED:
			collision_mask = 5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	save_state()
