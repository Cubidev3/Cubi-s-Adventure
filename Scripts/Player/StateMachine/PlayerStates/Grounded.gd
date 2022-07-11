extends PlayerState

func _enter():
	player.land()
	
func _update(delta: float):
	player.update_input()
	
func _physics_update(delta: float):
	player.move(delta)
	player.move_and_slide(player.velocity, Vector2.UP)
	player.check_for_ground()
	
	if not player.is_on_ground:
		state_machine.transition_to("AirDown")
		return
		
	if player.jump:
		player.jump(delta)
		state_machine.transition_to("AirUp")
		return
