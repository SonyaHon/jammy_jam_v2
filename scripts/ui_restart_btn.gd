extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("pressed", self, "_on");
	
	pass

func _on():
	get_tree().reload_current_scene();
	pass

