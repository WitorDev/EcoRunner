extends Node2D

var pause_menu = preload("res://opcoes_menu.tscn")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		abrir_pause()


func abrir_pause():
	if get_tree().paused:
		return

	var menu = pause_menu.instantiate()

	$PauseLayer.add_child(menu)

	menu.position = Vector2.ZERO
	menu.size = get_viewport_rect().size

	get_tree().paused = true
