class_name StateMachine
extends Node

signal transitioned(state_name)
export var initial_state := NodePath()

# Current active state
onready var state: State = get_node(initial_state) as State

func _ready():
	yield(owner, "ready")
	
	# Initializes State's state machine variable. This is important so we can change states
	for child in get_children():
		if child is State:
			child.state_machine = self
			
	state._enter()
	
func _process(delta):
	state._update(delta)
	
func _physics_process(delta):
	state._physics_update(delta)
	
func transition_to(state_name: String):
	var new_state = get_state(state_name)
	
	if new_state == null:
		return
		
	state._exit()
	state = new_state
	emit_signal("transitioned", state_name)
	state._enter()

func get_state(state_name) -> State:
	for child in get_children():
		if child is State and child.name == state_name:
			return child
			
	return null
