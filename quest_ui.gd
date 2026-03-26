extends Panel

@onready var title_label = $MarginContainer/HBoxContainer/TextLabels/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/HBoxContainer/TextLabels/VBoxContainer/DescriptionLabel
@onready var status_checkbox = $MarginContainer/HBoxContainer/StatusCheckbox

var quest : Quest
var is_showing := false

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("show_quests") and not is_showing:
		show_temporarily()

func show_temporarily():
	is_showing = true
	show()
	await get_tree().create_timer(5.0).timeout
	hide()
	is_showing = false

func setup(_quest : Quest):
	quest = _quest
	title_label.text = quest.title
	desc_label.text = quest.description
	update_status()

func update_status():
	if quest.completed:
		status_checkbox.button_pressed = true
		show_temporarily()
		status_checkbox.modulate = Color(0.6, 1, 0.6)
	else:
		status_checkbox.button_pressed = false
		status_checkbox.modulate = Color(1, 1, 1)
