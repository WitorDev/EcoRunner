extends Control

func _ready():
	$CenterContainer/VBoxContainer/RichTextLabel.text = """
1º Ana - 2500
2º João - 1800
3º Maria - 1200
"""

	$CenterContainer/VBoxContainer/Button.pressed.connect(_on_voltar_pressed)

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
