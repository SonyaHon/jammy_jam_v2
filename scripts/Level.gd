extends Node

var spwners;
var enemies;

signal cleared;

export(NodePath) var next_level;

func _ready():
	set_fixed_process(true);
	
	spwners = get_node("spawners").get_child_count();
	enemies = get_node("enemies").get_child_count();
	
	var cntr = get_node("connector");
	if cntr.get_child_count() == 1:
		cntr.get_child(0).connect("passed", self, "ended");
	pass

func ended():
	Utils.get_world().change_level(next_level);
	pass

func reduceEnemies():
	enemies -= 1;
	pass

func addEnemies():
	enemies += 1;
	pass

func reduceSpawners():
	spwners -= 1;
	pass

func _fixed_process(delta):
	if(spwners < 0):
		spwners = 0;
		pass
	if spwners == 0 and enemies == 0:
		emit_signal("cleared");
		pass
	
	pass

func start():
	
	for i in range(0, get_node("enemies").get_child_count()):
		get_node("enemies").get_child(i).start();
		pass
	
	for i in range(0, get_node("spawners").get_child_count()):
		get_node("spawners").get_child(i).start();
		pass
	
	pass
