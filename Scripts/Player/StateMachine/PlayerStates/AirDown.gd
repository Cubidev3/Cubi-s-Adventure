extends PlayerState

func _update(delta: float):
	player.update_input()

func _physics_update(delta: float):
	player.air_move(delta)
	player.fast_fall(delta)
	player.limit_fall_speed()
	player.move_and_slide(player.velocity, Vector2.UP)
	player.check_for_ground()
	
	if player.is_on_ground:
		state_machine.transition_to("Grounded")
		return
