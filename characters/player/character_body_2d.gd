extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const TERMINAL_VELOCITY = -600
const GRAVITY = 3500.0

var facing_direction = "right"
var jump_held_duration = 0
var is_jumping = false

@onready var animation = $Animation

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
	position = state.object_states[get_instance_id()]["position"]
	

func update_mask(mask):
	#rect.color = MASK_COLOURS[mask]
	match mask:
		Types.Mask.NONE:
			collision_mask = 1
		Types.Mask.BLUE:
			collision_mask = 3
		Types.Mask.RED:
			collision_mask = 5


func jump():
	velocity.y = JUMP_VELOCITY
	is_jumping = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		if jump_held_duration < 0.1 and jump_held_duration > 0:
			jump()
	else:
		velocity.y += GRAVITY * delta
		if velocity.y < TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY 
	
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if is_on_floor():
			jump()
		
		jump_held_duration = 0
	elif Input.is_action_pressed("jump"):
		jump_held_duration += delta 
		if jump_held_duration < 0.25 and is_jumping:
			velocity.y = JUMP_VELOCITY + jump_held_duration * JUMP_VELOCITY
	else:
		jump_held_duration = 0
		is_jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	var mask_name = str(Types.Mask.keys()[GameManager.game_state.current_mask]).to_lower()
	
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			facing_direction = "left"
		else:
			facing_direction = "right"
			
		animation.play("walk_" + facing_direction + "_" + mask_name)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		animation.play("idle_" + facing_direction + "_" + mask_name)
			
	if not is_on_floor():
		animation.play("jump_" + facing_direction + "_" + mask_name)
			
		
		

	move_and_slide()
	save_state()
