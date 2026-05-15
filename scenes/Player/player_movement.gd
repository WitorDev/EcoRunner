class_name CharacterMovementController
extends CharacterBody2D

# speed and acceleration variables

# variables changed only through code - careful!
var acceleration : float = 0
var direction
var jumped : bool = false

@export_category("Horizontal Movement")
@export var acceleration_speed : float = 1
@export var deceleration_speed : float = 5
@export var max_speed : float = 10

@export_category("Vertical Movement")
@export var jump_height : float = 1.5
@export var jump_buffer_time : float = 0.15
@export var cayote_time : float = 0.1

# auxiliar variables - do not touch!
var last_direction : int = 0
var jump_buffer_timer : float = 0
var cayote_timer : float = 0

func _process(delta: float) -> void:
	
	# Horizontal movement (X axis)
	direction = Input.get_axis("direction_left", "direction_right")

	if direction != 0 and last_direction == direction:
		acceleration = move_toward(acceleration, direction * max_speed * 10, acceleration_speed)
	else:
		acceleration = move_toward(acceleration, 0, deceleration_speed)

	# Vertical movement (Y axis)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or cayote_timer > 0:
			# Normal Jump or Coyote Jump
			jump()
			cayote_timer = 0
		else:
			# Not grounded and no coyote time? Buffer the jump for later.
			jump_buffer_timer = jump_buffer_time

	if is_on_floor():
		# Grounded: Reset timers and state
		cayote_timer = 0
		jumped = false
		
		# Check if we landed with a buffered jump ready to fire
		if jump_buffer_timer > 0:
			jump()
			jump_buffer_timer = 0
	else:
		var gravity_step = get_gravity() * 0.8 * delta
		velocity += gravity_step

		# 2. VARIABLE JUMP HEIGHT / FALL LOGIC
		if velocity.y < 0:
			# RISING: If player releases jump early, pull down harder (Short Hop)
			if not Input.is_action_pressed("jump"):
				velocity += gravity_step * 2
		else:
			# FALLING: Flutter effect if holding jump
			if Input.is_action_pressed("jump"):
				velocity -= gravity_step * 0.25
	
		if !jumped: # Only start coyote timer if we fell off, didn't jump
			if cayote_timer == 0: 
				cayote_timer = cayote_time
			
			if cayote_timer > 0:
				cayote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	last_direction = direction
	velocity.x = acceleration
	move_and_slide()
	
func jump():
	if !jumped:
		velocity.y = 0
		velocity.y -= jump_height * 100
	jumped = true
