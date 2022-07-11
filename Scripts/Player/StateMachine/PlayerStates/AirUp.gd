extends PlayerState

func _enter():
	player.is_on_ground = false

func _update(delta: float):
	player.update_input()
	
func _physics_update(delta: float):
	player.move(delta)
	player.fall(delta)
	player.move_and_slide(player.velocity, Vector2.UP)
	
	if sign(player.velocity.y) == Vector2.DOWN.y:
		state_machine.transition_to("AirDown")
		return 
		
	if player.is_on_ceiling():
		player.velocity.y = Vector2.DOWN.y
		state_machine.transition_to("AirDown")
		return 
