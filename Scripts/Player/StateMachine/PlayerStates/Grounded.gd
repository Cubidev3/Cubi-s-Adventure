extends PlayerState

func _enter():
	if player.has_buffered_jump():
		player.started_fast_fall = false
		
		if player.should_do_a_backflip():
			player.backflip_jump()
			state_machine.transition_to("BackflipUp")
			return
		
		player.jump()
		state_machine.transition_to("AirUp")
		return
	
	player.land()
	player.limit_horizontal_velocity(player.max_speed)
	
func _update(delta: float):
	player.update_input()
	player.update_jump_buffer()
	
func _physics_update(delta: float):
	player.move(delta)
	player.limit_horizontal_velocity(player.max_speed)
	player.move_and_slide(player.velocity, Vector2.UP)
	player.check_for_ground()
	
	if not player.is_on_ground:
		state_machine.transition_to("AirDown")
		return
		
	if player.has_buffered_jump():
		player.jump()
		state_machine.transition_to("AirUp")
		return
		
	if player.should_flip():
		player.flip()

func _exit():
	player.coyoteTime.start()
