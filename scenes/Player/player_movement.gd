extends CharacterBody2D


@export var speed = 120.0
@export var jump_velocity = -300.0
@export var interactable_in_range : bool

func _physics_process(delta: float) -> void:
	# handle animation
	if velocity.x != 0 and is_on_floor():
		$AnimationPlayer.play("leco_walking")
	elif velocity.x == 0 and is_on_floor():
		$AnimationPlayer.play("leco_idle")
	else:
		$AnimationPlayer.play("leco_jumping")

	# face toward the direction it is walking
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0:
		$Sprite2D.flip_h = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity

	# drop item
	if Input.is_action_just_pressed("drop_item"):
		drop_item() 

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func add_item(chosen_item : Item):
	var HUD = get_tree().get_first_node_in_group("hud")
	$ItemSlot.add_item(chosen_item)
	HUD.setItem(chosen_item)

func drop_item():
	var HUD = get_tree().get_first_node_in_group("hud")
	$ItemSlot.drop_item()
	HUD.setItem(null)
