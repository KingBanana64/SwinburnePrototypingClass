extends Area2D

##FIX BUG REPLACE TEST1 WITH FINAL NAME
@onready var level = get_node("/root/Test1")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	## COULD use multiple collisionShape2Ds in one Area2D and seperate using _shape_idx, but how to add dynamically?
	
	##If left click on area:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			## get child position of node
			var i = 0
			for node in get_parent().get_children():
				if node.name == name:
					level.animalPetCheck(i)
				else:
					i+=1
