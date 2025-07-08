extends Node
##STATE MACHINE OF FINAL BOSS

## Variables
@export var initial_state : State
var current_state : State
var states : Dictionary = {}

#Called when the node enters the scene tree for the first time.
func _ready():
	#setup dictionary of states
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			#important signal of how we swap between states
	
	#set boss to inital state
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

#calls the current state's update function each frame
func _process(delta: float):
	if current_state:
		current_state.Update(delta)

#calls the current state's physics update function each frame
func _physics_process(delta: float):
	if current_state:
		current_state.Physics_Update(delta)


# FUNCTION TO SWAP BETWEEN STATES #1st param: state we are currently in, 2nd param: state we want to transition to
func on_child_transition(state, new_state_name):
	#if first param doesnt match current_state then stop
	if state != current_state:
		return
	
	#grab the state from our dictionary
	var new_state = states.get(new_state_name.to_lower()) #to_lower just to reduce caps errors
	if !new_state:
		return
	
	#call the exit function of our old state
	if current_state:
		current_state.Exit()
	
	#camll the enter function of our new state
	new_state.Enter()
	
	#overwrite old state with new state in var current_state
	current_state = new_state
