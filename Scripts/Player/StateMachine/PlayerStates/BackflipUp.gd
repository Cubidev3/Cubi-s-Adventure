extends PlayerState

func _enter():
	player.is_on_ground = false
	player.is_inert = false
	player.started_fast_fall = false
	
	if abs(player.velocity.x) < player.min_backflip_speed:
		player.velocity.x = sign(player.velocity.x) * player.min_backflip_speed

func _update(delta: float):
	player.update_input()
	player.update_jump_buffer()
	
func _physics_update(delta: float):
	player.air_move(delta)
	player.limit_horizontal_velocity(player.backflip_max_speed)
	player.backflip_fall(delta)
	player.move_and_slide(player.velocity, Vector2.UP)
	
	if sign(player.velocity.y) == Vector2.DOWN.y:
		state_machine.transition_to("BackflipDown")
		return 
		
	if player.is_on_ceiling():
		player.velocity.y = Vector2.DOWN.y
		state_machine.transition_to("BackflipDown")
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
