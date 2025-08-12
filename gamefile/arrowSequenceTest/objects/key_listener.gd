extends Sprite2D

@onready var falling_key = preload("res://arrowSequenceTest/objects/falling_key.tscn")
@export var key_name: String = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(key_name):
		CreateFallingKey()

func CreateFallingKey():
	var fk_instance = falling_key.instantiate()
	get_tree().get_root().call_deferred("add_child", fk_instance)
	fk_instance.Setup(position.x, frame + 2)
