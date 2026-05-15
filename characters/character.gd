extends Node2D

@export var texture : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$Sprite2D.texture = texture
	$AnimationPlayer.play("idle")
