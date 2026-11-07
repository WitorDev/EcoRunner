extends CanvasLayer

const QuestUI = preload("res://scenes/UI/quest_ui.tscn")

var quest_ui : Dictionary = {}

func _ready() -> void:
	$Control/DeathMenu/CenterContainer/PanelContainer/VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$Control/DeathMenu/CenterContainer/PanelContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func set_health(current: int, maximum: int) -> void:
	$Control/HealthDisplay.text = "[color=#ef476f]" + "♥".repeat(current) \
		+ "[/color][color=#555555]" + "♥".repeat(maximum - current) + "[/color]"


func show_game_over() -> void:
	$Control/GameOverLabel.show()

func add_quest(quest : Quest):
	var quest_panel = QuestUI.instantiate()
	$Control/VSplitContainer.add_child(quest_panel)
	await quest_panel.ready
	quest_panel.setup(quest)
	
		
	quest_ui[quest.title] = quest_panel

func update_quest_ui(quest : Quest):
	if quest_ui.has(quest.title):
		var quest_panel = quest_ui[quest.title]
		quest_panel.update_status()

func set_item(item : Item):
	if item == null:
		$Control/ItemSprite.texture = null
		return
	var texture = item.sprite
	$Control/ItemSprite.texture = texture
