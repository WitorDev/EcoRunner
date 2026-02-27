extends Node2D

@export var item : Item

func add_item(item_to_add : Item):
	if(item != null):
		const item_scene = preload("res://scenes/item_object.tscn")
		var item_instance = item_scene.instantiate()
		item_instance.item_resource = item
		
		var player = get_parent()

		item_instance.global_position = player.global_position + Vector2(0, -20)

		var direction = 0
		while direction == 0:
			direction = randi_range(-1, 1)
		
		item_instance.apply_impulse(Vector2(direction * 60, -100))

		var tree = get_tree()
		tree.root.add_child(item_instance)
		
		item = item_to_add
		return
	
	item = item_to_add

func drop_item():
	if item == null:
		return
	else:
		const item_scene = preload("res://scenes/item_object.tscn")
		var item_instance = item_scene.instantiate()
		item_instance.item_resource = item
		
		var player = get_parent()

		item_instance.global_position = player.global_position + Vector2(0, -20)

		var direction = 0
		while direction == 0:
			direction = randi_range(-1, 1)
		
		item_instance.apply_impulse(Vector2(direction * 60, -100))

		var tree = get_tree()
		tree.root.add_child(item_instance)

		item = null
