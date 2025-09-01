extends Area2D


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	## COULD use multiple collisionShape2Ds in one Area2D and seperate using _shape_idx, but how to add dynamically?
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			var node = get_parent().get_children()
			print(_shape_idx)
			print(node)
