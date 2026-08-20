extends Resource
class_name ItemData

@export var item_id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""
@export var stackable: bool = true
@export var max_stack: int = 99
@export var category: String = ""
