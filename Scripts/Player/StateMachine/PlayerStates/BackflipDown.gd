extends PlayerState

func _enter():
	player.is_inert = false

func _update(delta: float):
	player.update_input()
	player.update_jump_buffer()

func _physics_update(delta: float):
	player.air_move(delta)
	player.limit_horizontal_velocity(player.backflip_max_speed)
	player.backflip_fast_fall(delta)
	player.limit_fall_speed()
	player.move_and_slide(player.velocity, Vector2.UP)
	player.check_for_ground()
	
	if player.is_on_ground:
		state_machine.transition_to("Grounded")
		return
		
	var wall_normal = player.get_wall_normal(player.wall_distance_tolerance)
	if player.check_for_walljump(wall_normal):
		player.walljump(wall_normal)
		state_machine.transition_to("WalljumpUp")
		return
		
	if player.is_on_wall():
		state_machine.transition_to("Wallslide")
		return

func _exit():
	player.is_inert = false
