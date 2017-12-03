extends Area2D

func _ready():
	add_to_group(Utils.GR_SLOW_PADLE);
	get_node("anim").play("idel");
	connect("body_enter", self, "_b_enter");
	connect("body_exit", self, "_b_exit");
	pass

func _b_enter(target):
	if target.is_in_group(Utils.GR_PLAYER) or target.is_in_group(Utils.GR_ENEMY):
		target.entered_slow_padle();
	pass

func _b_exit(target):
	if target.is_in_group(Utils.GR_PLAYER) or target.is_in_group(Utils.GR_ENEMY):
		target.exited_slow_padle();
	pass
