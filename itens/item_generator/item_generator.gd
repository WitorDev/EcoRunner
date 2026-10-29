@tool
extends Node
class_name ItemGenerator

## Nome do item (vira o Display Name e a base do Item Id).
@export var item_name: String = ""

## Sprite/ícone do item.
@export var item_sprite: Texture2D

## Se o item pode empilhar no inventário.
@export var stackable: bool = true

## Pasta onde os .tres serão salvos.
@export var save_folder: String = "res://items/"

@export_tool_button("Gerar Item")
var generate_action: Callable = generate_item


func generate_item() -> void:
	if item_name.is_empty():
		push_warning("Preencha o campo 'Item Name' antes de gerar.")
		return

	if not DirAccess.dir_exists_absolute(save_folder):
		DirAccess.make_dir_recursive_absolute(save_folder)

	var new_item := ItemData.new()
	new_item.item_id = item_name.to_snake_case()
	new_item.display_name = item_name
	new_item.icon = item_sprite
	new_item.stackable = stackable

	var file_path := save_folder.path_join(new_item.item_id + ".tres")
	var result := ResourceSaver.save(new_item, file_path)

	if result == OK:
		print("Item criado com sucesso: ", file_path)
	else:
		push_error("Erro ao salvar o item (código %d)" % result)
