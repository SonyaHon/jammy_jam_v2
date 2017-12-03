extends Node


enum SIDES {
	
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
	
}

var GR_PLAYER = "PLAYER"
var GR_WALL = "WALL"
var GR_BOUNCE_COLUMN = "BC"
var GR_ENEMY = "ENEMY"
var GR_BULLET = "BULLET"
var GR_ENEMY_BULLET = "EN_BULLET"
var GR_SLOW_PADLE = "SL_PDL";
var GR_SPEED_PADLE = "SP_PDL";

var allDead = false;
var timer = 3;


func get_world():
	var root = get_tree().get_root();
	set_process(true)
	return root.get_child(root.get_child_count() - 1);
	pass

func _process(delta):
	if timer > 0:
		timer -= delta;
	else:
		timer = 1;
		
		var enems = get_enemys_count();
		if enems == 0:
			allDead = true
			pass
		else:
			allDead = false
			pass
		pass
	pass

func are_all_dead():
	return allDead;
	pass

func get_enemys_count():
	var root = get_world();
	var cnt = 0;
	for i in range(0, root.get_child_count()):
		if root.get_child(i).is_in_group(GR_ENEMY):
			cnt += 1;
		pass
	return cnt;
	pass

func get_world_node(node_name):
	var world = get_world();
	return world.get_node(node_name);
	pass