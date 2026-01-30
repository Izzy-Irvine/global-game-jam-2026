extends Node

enum Mask {
	NONE,
	BLUE,
	GREEN
}

var current_mask: Mask = Mask.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Got here")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mask1"):
		current_mask = Mask.NONE
	elif Input.is_action_just_pressed("mask2"):
		current_mask = Mask.BLUE
	elif Input.is_action_just_pressed("mask3"):
		current_mask = Mask.GREEN
	
	print("Current mask" + str(current_mask))
		
