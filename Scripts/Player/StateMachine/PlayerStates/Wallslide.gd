extends PlayerState

func _enter():
	player.velocity.x = 0
	player.started_fast_fall = false
	
	player.wall_coyote_time_timer.stop()
	
	var wall_normal = player.get_wall_normal(1)
	player.set_sprite_direction(wall_normal)
	player.last_wall_normal = wall_normal

func _update(delta: float):
	player.update_input()
	player.update_jump_buffer()

func _physics_update(delta: float):
	player.wallslide_accelerate(delta)
	player.limit_wallslide_speed()
	player.move_and_slide(player.velocity, Vector2.UP) 
	player.check_for_ground()
		
	if player.has_buffered_jump():
		player.walljump(player.last_wall_normal)
		state_machine.transition_to("WalljumpUp")
		return
		
	if player.direction == player.last_wall_normal.x:
		state_machine.transition_to("AirDown")
		return
		
	if player.is_on_ground:
		state_machine.transition_to("Grounded")
		return
		
	if not player.is_on_wall():
		state_machine.transition_to("AirDown")
		return
		
func _exit():
	player.wall_coyote_time_timer.start()
