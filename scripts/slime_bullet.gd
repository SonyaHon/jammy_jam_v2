extends RigidBody2D

export(int) var bullet_lifetime = 5;

func _ready():
	set_fixed_process(true);
	add_to_group(Utils.GR_ENEMY_BULLET);
	connect("body_enter", self, "_on_collision");
	pass

func _fixed_process(delta):
	if bullet_lifetime > 0:
		bullet_lifetime -= delta
	else:
		queue_free();
	pass

func _on_collision(target):
	if !target.is_in_group(Utils.GR_BULLET):
		queue_free();
		pass
	pass
