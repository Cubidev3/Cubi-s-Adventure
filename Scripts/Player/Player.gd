class_name Player
extends KinematicBody2D

var velocity = Vector2.ZERO

# Inputs
var direction = 1
var jump = false
var holding_jump = false

# Horizontal Grounded movement
export var horizontal_distance_per_second = 1152
export var start_speed_percent = 0.2
export var horizontal_distance_traveled_while_accelerating_to_max_speed = 128
export var horizontal_distance_traveled_while_decelerating_to_zero_speed = 96
export var horizontal_distance_traveled_while_trying_to_turn_around = 48

var max_speed = 0
var start_speed = 0
var acceleration = 0
var deceleration = 0
var turn_around_deceleration = 0
var is_inert = true

# Horizontal Aerial Movement
export var horizontal_distance_traveled_on_air_while_accelerating_to_max_speed = 128
export var horizontal_distance_traveled_on_air_while_decelerating_to_zero_speed = 368
export var horizontal_distance_traveled_on_air_while_trying_to_turn_around = 64

var air_acceleration = 0
var air_deceleration = 0
var air_turn_around_deceleration = 0

# Jump
export var jump_heigth = 384
export var min_jump_heigth = 256
export var horizontal_distance_going_up = 448
export var horizontal_distance_going_down = 320
export var max_fall_speed = 5000

var jump_force = 0
var normal_gravity = 0
var fall_gravity = 0
var low_jump_gravity = 0

var is_on_ground = false
var started_fast_fall = false

# Backflip Jump
export var backflip_max_speed = 1408
export var min_backflip_speed = 256
export var backflip_heigth = 512
export var min_backflip_jump_heigth = 386
export var backflip_horizontal_distance_going_up = 704
export var backflip_horizontal_distance_going_down = 448

var backflip_jump_force = 0
var backflip_normal_gravity = 0
var backflip_fall_gravity = 0
var low_backflip_gravity = 0

# Fliping
onready var sprite = $Sprite
var facing_right = true

# Buffers
onready var jumpBuffer = $JumpBuffer
onready var coyoteTime = $CoyoteTime

# Wall Jump
export var wall_distance_tolerance = 16
export var walljump_max_speed = 1024
export var min_walljump_horizontal_distance = 320
export var walljump_heigth = 320
export var min_walljump_heigth = 128
export var walljump_horizontal_distance_going_up = 448
export var walljump_horizontal_distance_going_down = 288

var last_wall_normal = Vector2.ZERO
var walljump_force = 0
var walljump_normal_gravity = 0
var walljump_fall_gravity = 0
var low_walljump_gravity = 0
var walljump_turn_around_deceleration = 0

# Wall Slide
onready var wall_coyote_time_timer = $WallCoyoteTime

export var max_wallslide_speed = 1024
export var distance_travelled_while_accelerating = 192

var wallslide_acceleration = 0

func _ready():
	max_speed = horizontal_distance_per_second
	start_speed = max_speed * start_speed_percent
	
	acceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_while_accelerating_to_max_speed)
	deceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_while_decelerating_to_zero_speed)
	turn_around_deceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_while_trying_to_turn_around)
	
	air_acceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_on_air_while_accelerating_to_max_speed)
	air_deceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_on_air_while_decelerating_to_zero_speed)
	air_turn_around_deceleration = (max_speed * max_speed) / (2 * horizontal_distance_traveled_on_air_while_trying_to_turn_around)
	
	jump_force = (2 * jump_heigth * max_speed) / horizontal_distance_going_up
	normal_gravity = (jump_force * max_speed) / horizontal_distance_going_up
	fall_gravity = (2 * jump_heigth * max_speed * max_speed) / (horizontal_distance_going_down * horizontal_distance_going_down)
	low_jump_gravity = (jump_force * jump_force) / (2 * min_jump_heigth)
	
	backflip_jump_force = (2 * backflip_heigth * backflip_max_speed) / backflip_horizontal_distance_going_up
	backflip_normal_gravity = (backflip_jump_force * backflip_max_speed) / backflip_horizontal_distance_going_up
	backflip_fall_gravity = (2 * backflip_heigth * backflip_max_speed * backflip_max_speed) / (backflip_horizontal_distance_going_down * backflip_horizontal_distance_going_down)
	low_backflip_gravity = (backflip_jump_force * backflip_jump_force) / (2 * min_backflip_jump_heigth)
	
	walljump_force = (2 * walljump_heigth * walljump_max_speed) / walljump_horizontal_distance_going_up
	walljump_normal_gravity = (walljump_force * walljump_max_speed) / walljump_horizontal_distance_going_up
	walljump_fall_gravity = (2 * walljump_heigth * walljump_max_speed * walljump_max_speed) / (walljump_horizontal_distance_going_down * walljump_horizontal_distance_going_down)
	low_walljump_gravity = (walljump_force * walljump_force) / (2 * min_walljump_heigth)
	walljump_turn_around_deceleration = (walljump_max_speed * walljump_max_speed) / (2 * min_walljump_horizontal_distance)
	
	wallslide_acceleration = (2 * max_wallslide_speed * max_wallslide_speed) / (distance_travelled_while_accelerating)

func update_input():
	direction = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	jump = Input.is_action_just_pressed("jump")
	holding_jump = Input.is_action_pressed("jump")

func move(delta: float):
	if direction != 0:
		accelerate(delta)
	else:
		decelerate(delta)
		
func air_move(delta: float):
	if direction != 0:
		air_accelerate(delta)
	else:
		air_decelerate(delta)
		
func walljump_move(delta: float):
	if direction != 0:
		walljump_accelerate(delta)
	else:	
		air_decelerate(delta)
	
func walljump_accelerate(delta: float):
	var velocity_to_add = air_acceleration * direction * delta
	if is_turning_around():
		velocity_to_add = walljump_turn_around_deceleration * direction * delta
		
	velocity.x += velocity_to_add

func accelerate(delta: float) -> void:
	if is_inert:
		velocity.x = start_speed * direction
		is_inert = false
		return
	
	var velocity_to_add = acceleration * direction * delta
	if is_turning_around():
		velocity_to_add = turn_around_deceleration * direction * delta
		
	velocity.x += velocity_to_add
	
func air_accelerate(delta: float) -> void:
	var velocity_to_add = air_acceleration * direction * delta
	if is_turning_around():
		velocity_to_add = air_turn_around_deceleration * direction * delta
		
	velocity.x += velocity_to_add
	
func limit_horizontal_velocity(max_s: float):
	velocity.x = clamp(velocity.x, -max_s, max_s)
	
func decelerate(delta: float) -> void:
	var velocity_to_add = deceleration * sign(-velocity.x) * delta
	
	var old_velocity_direction = sign(velocity.x)
	velocity.x += velocity_to_add
	
	if (velocity.x == 0 or (old_velocity_direction + sign(velocity.x) == 0)):
		velocity.x = 0
		is_inert = true
		
func air_decelerate(delta: float) -> void:
	var velocity_to_add = air_deceleration * sign(-velocity.x) * delta
	
	var old_velocity_direction = sign(velocity.x)
	velocity.x += velocity_to_add
	
	if (velocity.x == 0 or (old_velocity_direction + sign(velocity.x) == 0)):
		velocity.x = 0
		
func wallslide_accelerate(delta: float) -> void:
	var velocity_to_add = wallslide_acceleration * Vector2.DOWN.y * delta
	velocity.y += velocity_to_add
	
func is_turning_around() -> bool:
	return sign(velocity.x) + direction == 0 and not is_inert
	
func fall(delta: float) -> void:
	if started_fast_fall:
		if sign(velocity.y) == Vector2.UP.y: low_jump_fall(delta)
		else: fast_fall(delta)
	else:
		normal_fall(delta)
		check_for_fast_fall_start()
		
func backflip_fall(delta: float):
	if started_fast_fall:
		if sign(velocity.y) == Vector2.UP.y: backflip_low_jump_fall(delta)
		else: backflip_fast_fall(delta)
	else:
		backflip_normal_fall(delta)
		check_for_fast_fall_start()
		
func walljump_fall(delta: float):
	if started_fast_fall:
		if sign(velocity.y) == Vector2.UP.y: walljump_low_jump_fall(delta)
		else: walljump_fast_fall(delta)
	else:
		walljump_normal_fall(delta)
		check_for_fast_fall_start()

func apply_gravity(delta: float, gravity_value: float):
	var gravity = gravity_value * delta * Vector2.DOWN.y
	velocity.y += gravity

func fast_fall(delta: float) -> void:
	apply_gravity(delta, fall_gravity)
	
func normal_fall(delta: float) -> void:
	apply_gravity(delta, normal_gravity)
	
func low_jump_fall(delta: float) -> void:
	apply_gravity(delta, low_jump_gravity)
	
func backflip_normal_fall(delta: float) -> void:
	apply_gravity(delta, backflip_normal_gravity)
	
func backflip_fast_fall(delta: float) -> void:
	apply_gravity(delta, backflip_fall_gravity)
	
func backflip_low_jump_fall(delta: float) -> void:
	apply_gravity(delta, low_backflip_gravity)
	
func walljump_normal_fall(delta: float) -> void:
	apply_gravity(delta, walljump_normal_gravity)
	
func walljump_fast_fall(delta: float) -> void:
	apply_gravity(delta, walljump_fall_gravity)
	
func walljump_low_jump_fall(delta: float) -> void:
	apply_gravity(delta, low_walljump_gravity)
	
func limit_fall_speed():
	limit_vertical_velocity(0, max_fall_speed)
	
func limit_wallslide_speed():
	limit_vertical_velocity(0, max_wallslide_speed)
	
func limit_vertical_velocity(min_speed: float, max_speed: float):
	velocity.y = clamp(velocity.y, min_speed, max_speed)
	
func check_for_fast_fall_start():
	if (sign(velocity.y) == Vector2.DOWN.y || not holding_jump):
		started_fast_fall = true
	
func jump_with_force(force: float):
	velocity.y = Vector2.UP.y * force
	jumpBuffer.stop()
	coyoteTime.stop()
	is_on_ground = false
	
func jump() -> void:
	jump_with_force(jump_force)
	jumpBuffer.stop()
	started_fast_fall = false
	
func backflip_jump() -> void:
	jump_with_force(backflip_jump_force)
	jumpBuffer.stop()
	started_fast_fall = false
	
func land():
	velocity.y = 0.1
	is_on_ground = true
	started_fast_fall = false
	set_sprite_direction(velocity)

func check_for_ground():
	is_on_ground = is_on_floor()

func should_flip() -> bool:
	return (facing_right && velocity.x < 0) || (not facing_right && velocity.x > 0)

func flip():
	sprite.flip_h = not sprite.flip_h
	facing_right = not facing_right
	
func set_sprite_direction(dir: Vector2):
	facing_right = dir.x >= 0
	sprite.flip_h = not facing_right

func has_buffered_jump() -> bool:
	return jumpBuffer.time_left > 0
	
func has_coyote_time() -> bool:
	return coyoteTime.time_left > 0 
	
func has_wall_coyote_time() -> bool:
	return wall_coyote_time_timer.time_left > 0

func update_jump_buffer():
	if jump: jumpBuffer.start() 
	
func should_do_a_backflip() -> bool:
	return should_flip()
	
func check_for_walljump(wall_normal: Vector2) -> bool:
	return has_buffered_jump() and wall_normal != Vector2.ZERO
	
func get_wall_normal(distance: float) -> Vector2:
	if test_move(transform, Vector2.LEFT * distance):
		return Vector2.RIGHT
			
	if test_move(transform, Vector2.RIGHT * distance):
		return Vector2.LEFT
		
	return Vector2.ZERO

func walljump(wall_normal: Vector2):
	jump_with_force(walljump_force)
	
	wall_coyote_time_timer.stop()
	jumpBuffer.stop()
	started_fast_fall = false
	
	velocity.x = walljump_max_speed * wall_normal.x
	last_wall_normal = wall_normal
	set_sprite_direction(wall_normal)
