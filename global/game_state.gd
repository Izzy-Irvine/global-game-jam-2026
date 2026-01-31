extends Node

class_name GameState

var current_mask: Types.Mask = Types.Mask.NONE

var masks_collected = [Types.Mask.NONE]

# object states will be just to track position and whether things are collected/destroyed or not. Actual key game state things should be something else.
var object_states = {}

func copy() -> GameState:
	var new_state = GameState.new()
	new_state.current_mask = self.current_mask
	new_state.masks_collected = self.masks_collected.duplicate()
	new_state.object_states = self.object_states.duplicate()
	
	return new_state
