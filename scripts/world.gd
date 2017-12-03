extends Node

signal lvl_cleared;

var is_cleared = 0;
export(NodePath) var current_level;

func _ready():
	set_process(true);
	get_node(current_level).start();
	pass

func change_level(lvl):
	var prevAddr = current_level;
	current_level = lvl
	get_node(prevAddr).get_node(current_level).start();
	pass

func _process(delta):
	if Utils.are_all_dead():
		is_cleared += 1;
		pass
	if is_cleared >= 20:
		emit_signal("lvl_cleared");
		pass
	pass