extends Area2D

@onready var level = get_node("/root/").get_child(0)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	##If left click on area:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():		##if clicked
			returnPosition()
		
		## future proofing for if we want held down inputs
		elif event.button_index == 1 and event.is_released():	##if released
			pass


func returnPosition():
	## get child position of node
	var i = 0
	for child in get_parent().get_children():
		if child.name == name:
			level.animalPetCheck(i)
		else:
			i+=1

## COULD use multiple collisionShape2Ds in one Area2D and seperate using _shape_idx...
## ...but how to add dynamically? and also this works soooo 🤷‍♂️
