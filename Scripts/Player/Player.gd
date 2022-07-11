class_name Player
extends KinematicBody2D

var velocity = Vector2.ZERO

# Inputs
var direction = 1
var jump = false

# Horizontal movoment
export var horizontal_distance_per_second = 10 * 128
export var start_speed_percent = 0.2
var max_speed = 400
var start_speed = 100
export var time_to_max_speed = 0.24
export var time_to_stop = 0.16
export var time_to_turn_around = 0.06
var acceleration = max_speed / time_to_max_speed
var deceleration = max_speed / time_to_stop
var turn_around_acceleration = max_speed / time_to_turn_around
var is_inert = true

# Jump
export var jump_heigth = 300
export var horizontal_distance_going_up = 4 * 128
export var horizontal_distance_going_down = 3 * 128
export var max_fall_speed = 750
var jump_force = 0
var normal_gravity = 0
var fall_gravity = 0
var low_jump_gravity = 0
var is_on_ground = false
var started_fast_fall = false

func _ready():
	max_speed = horizontal_distance_per_second
	start_speed = max_speed * start_speed_percent
	
	acceleration = max_speed / time_to_max_speed
	deceleration = max_speed / time_to_stop
	turn_around_acceleration = max_speed / time_to_turn_around
	
	jump_force = (2 * jump_heigth * max_speed) / horizontal_distance_going_up
	normal_gravity = (jump_force * max_speed) / horizontal_distance_going_up
	fall_gravity = (jump_force * max_speed) / horizontal_distance_going_down
	low_jump_gravity = fall_gravity

func update_input():
	direction = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	jump = Input.is_action_pressed("jump")

func move(delta):
	if direction != 0 or is_turning_around():
		accelerate(delta)
	else:
		decelerate(delta)

func accelerate(delta: float) -> void:
	if is_inert:
		velocity.x = start_speed * direction
		is_inert = false
	
	var velocity_to_add = acceleration * direction * delta
	if is_turning_around():
		velocity_to_add = turn_around_acceleration * direction * delta
		
	velocity.x += velocity_to_add
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
func decelerate(delta: float) -> void:
	var velocity_to_add = deceleration * sign(-velocity.x) * delta
	
	var old_velocity_direction = sign(velocity.x)
	velocity.x += velocity_to_add
	
	if (velocity.x == 0 or (old_velocity_direction + sign(velocity.x) == 0)):
		velocity.x = 0
		is_inert = true
	
func is_turning_around() -> bool:
	return sign(velocity.x) + direction == 0 and not is_inert
	
func fall(delta: float) -> void:
	if started_fast_fall:
		if sign(velocity.y) == Vector2.UP.y: low_jump_fall(delta)
		else: fast_fall(delta)
	else:
		normal_fall(delta)
		check_for_fast_fall_start()

func fast_fall(delta: float) -> void:
	var gravity = fall_gravity * delta * Vector2.DOWN.y
	velocity.y += gravity
	
func normal_fall(delta: float) -> void:
	var gravity = normal_gravity * delta * Vector2.DOWN.y
	velocity.y += gravity
	
func low_jump_fall(delta: float) -> void:
	var gravity = low_jump_gravity * delta * Vector2.DOWN.y
	velocity.y += gravity
	
func limit_fall_speed():
	velocity.y = clamp(velocity.y, 0, max_fall_speed)
	
func check_for_fast_fall_start():
	if (sign(velocity.y) == Vector2.DOWN.y || not jump):
		started_fast_fall = true
	
func jump(delta: float) -> void:
	velocity.y = Vector2.UP.y * jump_force
	is_on_ground = false
	
func land():
	velocity.y = 0.1
	is_on_ground = true
	started_fast_fall = false

func check_for_ground():
	is_on_ground = is_on_floor()
