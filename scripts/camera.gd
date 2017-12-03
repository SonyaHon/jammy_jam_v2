extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process(true);
	pass

func _process(delta):
	var pl = Utils.get_world_node("player");
	set_pos(pl.get_pos());
	pass
