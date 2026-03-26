extends Node2D

var quests : Array[Quest] = []

func add_quest(title: String, description: String):
	var new_quest = Quest.new(title, description)
	var HUD = get_tree().get_first_node_in_group("hud")
	HUD.add_quest(new_quest)
	quests.append(new_quest)
	print("New Quest Added to Quest Book!")

func has_quest(title: String) -> bool:
	for quest in quests:
		if quest.title == title:
			return true
	return false

func complete_quest(quest_title : String):
	for quest in quests:
		if quest.title == quest_title:
			quest.completed = true
			print("Quest " + quest.title + " completed!")
			
			var HUD = get_tree().get_first_node_in_group("hud")
			HUD.update_quest_ui(quest)
			return
	print("Quest not yet started")
