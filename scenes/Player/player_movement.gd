extends CharacterBody2D

var was_on_floor : bool = false
@export var speed = 120.0
@export var jump_velocity = -300.0
@export var interactable_in_range : bool
@onready var item = $ItemSlot.item
@onready var item_slot = $ItemSlot
@onready var quest_manager = $QuestManager
@export var powerups : Array[String] = []
@export var health : int
@export var max_health : int = 5
var can_take_damage : bool = true

# tilemap
@export var tilemap: TileMapLayer

var damage_cooldown := 0.0


func _ready() -> void:
	health = max_health

	# add quest (debug only)
	quest_manager.add_quest("Ligue o painel solar", "Encontre a bateria perdida e ligue o painel solar, colocando a bateria na estação de energia")
	quest_manager.add_quest("Limpe a montanha", "Encontre a garrafa jogada no topo da montanha e coloque no lixo na planície, mantendo o local limpo e seguro")
	quest_manager.add_quest("Ligue a plataforma de transporte", "Ligue a plataforma de transporte para alcançar o painel solar")

func _physics_process(delta: float) -> void:
	check_tile_damage()

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

		# $AudioStreamPlayer2D.stream = preload("res://sounds/jump.wav")
		# $AudioStreamPlayer2D.play() # jumping sound

	# Handle floating.
	if Input.is_action_pressed("ui_up") and !is_on_floor() and velocity.y > 0 and powerups.find("float") != -1:
		velocity = Vector2(0,50)

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

	# landing detection
	# if is_on_floor() and !was_on_floor:
		# $AudioStreamPlayer2D.stream = preload("res://sounds/landing.wav")
		# $AudioStreamPlayer2D.play()

	was_on_floor = is_on_floor()

func add_item(chosen_item : Item):
	var HUD = get_tree().get_first_node_in_group("hud")
	$ItemSlot.add_item(chosen_item)
	HUD.set_item(chosen_item)

func drop_item():
	var HUD = get_tree().get_first_node_in_group("hud")
	$ItemSlot.drop_item()
	HUD.set_item(null)

func remove_item():
	$ItemSlot.remove_item()

# health 
func heal(amount: int):
	health += amount
	if(health > max_health):
		health = max_health
		
	print("Player healed by ", amount, " Points!")

func take_damage(damage : int):
	if(can_take_damage):
		health -= damage
		damage_effect()
		print("Player damaged by ", damage, " Points!")
		if(health <= 0):
			print("Player Died!")
		# can_take_damage = false
		$Timer.start()

func _on_timer_timeout() -> void:
	modulate = Color(1, 1, 1)
	# can_take_damage = true

func check_tile_damage():
	if not is_on_floor():
		return

	# Check at player's feet (important!)
	var feet_position = global_position + Vector2(0, 8)

	# Convert to tile coordinates
	var local_pos = tilemap.to_local(feet_position)
	var tile_pos = tilemap.local_to_map(local_pos)

	var tile_data = tilemap.get_cell_tile_data(tile_pos)

	if tile_data:
		var damage = tile_data.get_custom_data("damage")

		if damage != null and damage > 0:
			take_damage(damage)

func damage_effect():
	modulate = Color(10, 2, 0)

	var sprite = $Sprite2D

	# Hit effect
	var tween = create_tween()

	# Quick squash (only sprite)
	sprite.scale = Vector2(1.1, 0.9)
	tween.tween_property(sprite, "scale", Vector2(1,1), 0.15).set_trans(Tween.TRANS_BACK)

	# Small shake (only sprite)
	var original_pos = sprite.position

	tween.tween_property(sprite, "position", original_pos + Vector2(3,0), 0.05)
	tween.tween_property(sprite, "position", original_pos + Vector2(-3,0), 0.05)
	tween.tween_property(sprite, "position", original_pos, 0.05)
