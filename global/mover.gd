@tool
extends Node2D

@export var move_x_amplitude := 0
@export var move_x_speed := 1
@export_range(-1.0, 1.0, 0.01) var move_x_offset := 0.0

@export var move_y_amplitude := 0
@export var move_y_speed := 1
@export_range(-1.0, 1.0, 0.01) var move_y_offset := 0.0

var time = 0
var base_position: Vector2

func _ready() -> void:
	base_position = Vector2(position)

func _process(delta: float) -> void:
	time += delta
	position.x = base_position.x + sin((time + move_x_offset) * move_x_speed) * move_x_amplitude
	position.y = base_position.y + sin((time + move_y_offset) * move_y_speed) * move_y_amplitude
