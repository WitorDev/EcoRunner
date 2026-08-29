extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer/SliderVolume.value_changed.connect(_on_volume_changed)
	$CenterContainer/VBoxContainer/BtnTelaCheia.toggled.connect(_on_tela_cheia_toggled)
	$CenterContainer/VBoxContainer/BtnVoltar.pressed.connect(_on_voltar_pressed)

func _on_volume_changed(valor: float):
	if valor == 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, linear_to_db(valor / 100.0))
	
func _on_tela_cheia_toggled(ativado: bool):
	if ativado:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_voltar_pressed():
	if get_parent().name == "OpcoesMenu":
		queue_free()
	else:
		get_tree().change_scene_to_file("res://tela_inicial/main_menu.tscn")
