extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -550.0
const TERMINAL_VELOCITY = -600
const GRAVITY = 3800.0

var facing_direction = "right"
var jump_held_duration = 0
var is_jumping = false
var time_in_air = 0

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
	
	collision_mask = Types.OBJECTS_LAYER
	
	save_state()
	
func _on_mask_changed(mask):
	update_mask(mask)

func _on_reload_state():
	var state = GameManager.game_state
	velocity.x = 0
	velocity.y = 0
	position = state.object_states[get_instance_id()]["position"]
	

func update_mask(mask):
	match mask:
		Types.Mask.NONE:
			collision_mask = Types.OBJECTS_LAYER
		Types.Mask.BLUE:
			collision_mask = Types.OBJECTS_LAYER | Types.BLUE_MASK_LAYER
		Types.Mask.RED:
			collision_mask = Types.OBJECTS_LAYER | Types.RED_MASK_LAYER


func jump():
	velocity.y = JUMP_VELOCITY
	is_jumping = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		time_in_air = 0
		if jump_held_duration < 0.1 and jump_held_duration > 0:
			jump()
	else:
		time_in_air += delta
		velocity.y += GRAVITY * delta
		if velocity.y < TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY 
	
	
	if Input.is_action_just_pressed("jump"):
		if time_in_air < 0.1:
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
		# set a multiplier for your acceleration based on if you're quickly turning around vs just trying to speed up
		var multiplier = 12.0 if (velocity.x > 0 and direction < 0) or (velocity.x < 0 and direction > 0) else 4.0
		
		velocity.x += direction * SPEED * delta * multiplier
		
		# bound speed to SPEED
		if velocity.x > SPEED:
			velocity.x = SPEED
		elif velocity.x < -SPEED:
			velocity.x = -SPEED
		
		if direction < 0:
			facing_direction = "left"
		else:
			facing_direction = "right"
			
		animation.play("walk_" + facing_direction + "_" + mask_name)
	else:
		if velocity.x > 0:
			velocity.x -= SPEED * delta * 8.0
		elif velocity.x < 0:
			velocity.x += SPEED * delta * 8.0
		
		if velocity.x > -50 and velocity.x < 50:
			velocity.x = 0
	
		animation.play("idle_" + facing_direction + "_" + mask_name)
			
	if not is_on_floor():
		animation.play("jump_" + facing_direction + "_" + mask_name)

	move_and_slide()
	save_state()
