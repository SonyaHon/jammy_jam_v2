extends StaticBody2D

onready var spawn_point = get_node("spawn_pos").get_global_pos();
var slime = preload("res://scenes/enemy.tscn");

export(int) var slime_number = 4;
export(int) var slime_spawn_delay = 3;

var slime_num;
var current_timer;
var started = false;

func start():
	started = true;
	pass

func _ready():
	set_process(true);
	
	slime_num = slime_number;
	current_timer = slime_spawn_delay;
	
	pass

func _process(delta):
	if started:
		if current_timer > 0:
			current_timer -= delta;
			pass
		else:
			current_timer = slime_spawn_delay;
			if slime_num  > 0:
				var sl = slime.instance();
				sl.set_pos(spawn_point);
				slime_num -= 1;
				get_node("../../enemies/").add_child(sl);
				get_node("../../").addEnemies();
				pass
			else:
				get_node("../../").reduceSpawners();
		pass
	pass
