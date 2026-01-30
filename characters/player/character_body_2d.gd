extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var rect = $ColorRect

const MASK_COLOURS = {
	GameManager.Mask.NONE: "#aaaaaa",
	GameManager.Mask.BLUE: "#0000ff",
	GameManager.Mask.GREEN: "#00ff00"
}


func _ready():
	GameManager.changed_mask.connect(_on_mask_changed)
	
func _on_mask_changed(mask):
	rect.color = MASK_COLOURS[mask]
	match mask:
		GameManager.Mask.NONE:
			collision_mask = 1
		GameManager.Mask.BLUE:
			collision_mask = 3
		GameManager.Mask.GREEN:
			collision_mask = 5
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
