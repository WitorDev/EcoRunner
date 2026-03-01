extends StaticBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		set_collision_layer_value(2, false)
		set_collision_layer_value(1, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_layer_value(2, true)
		set_collision_layer_value(1, true)
