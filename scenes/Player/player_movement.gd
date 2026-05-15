extends CharacterBody2D

# --- Signals / Nodes ---
@onready var item_slot: Node = $ItemSlot
@onready var quest_manager: Node = $QuestManager
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

# --- Export Variables ---
@export_category("Environment")
@export var tilemap: TileMapLayer

@export_category("Attributes")
@export var max_health: int = 5
@export var powerups: Array[String] = []

@export_category("Horizontal Movement")
@export var acceleration_speed: float = 1.0
@export var deceleration_speed: float = 5.0
@export var max_speed: float = 10.0

@export_category("Vertical Movement")
@export var jump_height: float = 1.5
@export var jump_buffer_time: float = 0.15
@export var coyote_time: float = 0.1

# --- State Variables ---
var health: int
var can_take_damage: bool = true
var damage_cooldown := 0.0

# Movement states
var acceleration: float = 0.0
var direction: float = 0.0
var last_direction: float = 0.0
var jumped: bool = false
var was_on_floor: bool = false

# Timers
var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

# Interaction tracking (Stores the exact interactable instance)
var current_interactable: Node2D = null 


func _ready() -> void:
	health = max_health

	# Add quests (Debug only)
	quest_manager.add_quest("Ligue o painel solar", "Encontre a bateria perdida e ligue o painel solar, colocando a bateria na estação de energia")
	quest_manager.add_quest("Limpe a montanha", "Encontre a garrafa jogada no topo da montanha e coloque no lixo na planície, mantendo o local limpo e seguro")
	quest_manager.add_quest("Ligue a plataforma de transporte", "Ligue a plataforma de transporte para alcançar o painel solar")


func _physics_process(delta: float) -> void:
	check_tile_damage()
	
	# 1. HORIZONTAL INPUT & ACCELERATION
	direction = Input.get_axis("direction_left", "direction_right")

	if direction != 0 and (last_direction == direction or last_direction == 0):
		acceleration = move_toward(acceleration, direction * max_speed * 10, acceleration_speed)
	else:
		acceleration = move_toward(acceleration, 0, deceleration_speed)
	
	velocity.x = acceleration
	last_direction = direction

	# 2. ANIMATION HANDLING
	if velocity.x != 0 and is_on_floor():
		animation_player.play("leco_walking")

	# 3. VERTICAL MOVEMENT & COYOTE / BUFFER LOGIC
	if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_up"):
		if is_on_floor() or coyote_timer > 0:
			jump()
			coyote_timer = 0
		else:
			jump_buffer_timer = jump_buffer_time

	if is_on_floor():
		coyote_timer = 0
		jumped = false
		
		if jump_buffer_timer > 0:
			jump()
			jump_buffer_timer = 0
	else:
		var gravity_step = get_gravity() * 0.8 * delta
		velocity += gravity_step

		# Variable jump height / Short Hop support
		if velocity.y < 0:
			if not (Input.is_action_just_released("jump") or Input.is_action_pressed("jump") or Input.is_action_pressed("ui_up")):
				velocity += gravity_step * 2
		else:
			# Flutter effect / Slow Fall when holding jump mid-air
			if (Input.is_action_pressed("jump") or Input.is_action_pressed("ui_up")):
				# Check if player has float powerup to trigger floating velocity overrides
				if powerups.has("float"):
					velocity.y = 50
				else:
					velocity -= gravity_step * 0.25
	
		if not jumped:
			if coyote_timer == 0: 
				coyote_timer = coyote_time
			if coyote_timer > 0:
				coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# 4. AUXILIARY UTILITY ACTIONS
	if Input.is_action_just_pressed("drop_item"):
		drop_item() 

	if Input.is_action_just_pressed("interact") and current_interactable != null:
		if current_interactable.has_method("interact"):
			current_interactable.interact()

	# 5. ENGINE INTEGRATION
	move_and_slide()
	was_on_floor = is_on_floor()


func jump() -> void:
	if not jumped:
		velocity.y = 0
		velocity.y -= jump_height * 100
	jumped = true


# --- Item System ---
func remove_item() -> void:
	item_slot.remove_item()

func drop_item() -> void:
	# Add your item dropping logic implementation here if needed
	pass


# --- Health & Hazards System ---
func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		health = max_health
	print("Player healed by ", amount, " Points! Current Health: ", health)


func take_damage(damage: int) -> void:
	if can_take_damage:
		health -= damage
		damage_effect()
		print("Player damaged by ", damage, " Points!")
		
		if health <= 0:
			print("Player Died!")
			
		can_take_damage = false
		timer.start()


func _on_timer_timeout() -> void:
	modulate = Color(1, 1, 1) # Reset player color overlay back to normal
	can_take_damage = true


func check_tile_damage() -> void:
	if not is_on_floor() or tilemap == null:
		return

	# Check tile hazards at player's feet bounding box
	var feet_position = global_position + Vector2(0, 8)
	var local_pos = tilemap.to_local(feet_position)
	var tile_pos = tilemap.local_to_map(local_pos)
	var tile_data = tilemap.get_cell_tile_data(tile_pos)

	if tile_data:
		var damage = tile_data.get_custom_data("damage")
		if damage != null and damage > 0:
			take_damage(damage)


func damage_effect() -> void:
	modulate = Color(10, 2, 0) # Intense flash red

	var tween = create_tween()
	# Quick structural squash
	sprite.scale = Vector2(1.1, 0.9)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_BACK)

	# Quick structural horizontal shake
	var original_pos = sprite.position
	tween.tween_property(sprite, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(sprite, "position", original_pos + Vector2(-3, 0), 0.05)
	tween.tween_property(sprite, "position", original_pos, 0.05)
