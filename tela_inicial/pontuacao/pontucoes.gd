extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer/RichTextLabel.text = """
1º Ana - 2500
2º João - 1800
3º Maria - 1200
"""

	$CenterContainer/VBoxContainer/Button.pressed.connect(_on_voltar_pressed)

func _on_voltar_pressed():
	if get_parent().name == "OpcoesMenu":
		queue_free()
	else:
		get_tree().change_scene_to_file("res://main_menu.tscn")
