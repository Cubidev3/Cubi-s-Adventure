extends PlayerState

func _enter():
	player.is_on_ground = false
	player.is_inert = false
	player.started_fast_fall = false
	
	print("walljumped")

func _update(delta: float):
	player.update_input()
	player.update_jump_buffer()

func _physics_update(delta: float):
	player.walljump_move(delta)
	player.limit_horizontal_velocity(player.walljump_max_speed)
	player.walljump_fall(delta)
	player.move_and_slide(player.velocity, Vector2.UP)
	
	if sign(player.velocity.y) == Vector2.DOWN.y:
		state_machine.transition_to("WalljumpDown")
		return 
		
	if player.is_on_ceiling():
		player.velocity.y = Vector2.DOWN.y
		state_machine.transition_to("WalljumpDown")
		return 
		
	var wall_normal = player.get_wall_normal(player.wall_distance_tolerance)
	if player.check_for_walljump(wall_normal):
		player.walljump(wall_normal)
		state_machine.transition_to("WalljumpUp")
		return
		
	if player.is_on_wall():
		player.velocity.x = 0
		
func _exit():
	player.is_inert = false
