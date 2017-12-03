extends Button

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("pressed", self, "_on");
	pass

func _on():
	Utils.get_world().change_state(1);
	pass
