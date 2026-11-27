extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var lines: Array[String] = []
	if Global.completion_times.is_empty():
		lines.append("Nenhuma vitória registrada.")
	else:
		for index in Global.completion_times.size():
			lines.append("%dº lugar - %s" % [index + 1, Global.format_time(Global.completion_times[index])])

	$CenterContainer/VBoxContainer/RichTextLabel.text = "\n".join(lines)
	$CenterContainer/VBoxContainer/Button.pressed.connect(_on_voltar_pressed)


func _on_voltar_pressed() -> void:
	if get_parent().name == "OpcoesMenu":
		get_parent().get_node("Background").show()
		get_parent().get_node("CenterContainer").show()
		queue_free()
	else:
		get_tree().change_scene_to_file("res://tela_inicial/main_menu.tscn")
