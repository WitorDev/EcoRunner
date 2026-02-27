extends CanvasLayer

func setItem(item : Item):
	if item == null:
		$Control/ItemSprite.texture = null
		return
	var texture = item.sprite
	$Control/ItemSprite.texture = texture
