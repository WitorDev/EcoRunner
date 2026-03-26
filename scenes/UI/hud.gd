extends CanvasLayer

const QuestUI = preload("res://scenes/UI/quest_ui.tscn")

var quest_ui : Dictionary = {}

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
