extends RigidBody2D

export(int) var bullet_lifetime = 5;

var anim_fly = preload("res://sprites/bullet.png");
var anim_explode = preload("res://sprites/bullet_explode.png");

enum {
	
	STATE_FLY,
	STATE_EXPLODE
	
}

onready var current_state = StateFly.new(self);

var diying = false;

func _ready():
	add_collision_exception_with(Utils.get_world_node("player"));
	set_fixed_process(true);
	change_state(STATE_FLY);
	connect("body_enter", self, "_on_collision");
	pass

func _fixed_process(delta):
	
	
	
	if bullet_lifetime > 0:
		bullet_lifetime -= delta
	else:
		if !diying:
			change_state(STATE_EXPLODE);
			diying = true;
	pass

func _on_collision(target):
	if !target.is_in_group(Utils.GR_BULLET):
		set_linear_velocity(Vector2(0, 0));
		set_angular_velocity(0);
		change_state(STATE_EXPLODE);
		pass
	pass

func change_state(new_state):
	current_state.exit();
	
	if new_state == STATE_FLY:
		current_state = StateFly.new(self);
		pass
	else:
		current_state = StateExplode.new(self);
	pass


class StateFly:
	var me;
	func _init(me):
		self.me = me;
		me.get_node("sprite").set_texture(me.anim_fly);
		me.get_node("sprite").set_hframes(6);
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(2);
		me.get_node("anim").play("fly");
		pass
	
	func exit():
		pass

class StateExplode:
	var me;
	func _init(me):
		self.me = me;
		me.get_node("sprite").set_texture(me.anim_explode);
		me.get_node("sprite").set_hframes(8);
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(4);
		me.get_node("anim").play("explode");
		me.get_node("anim").connect("finished", self, "kill_myself");
		pass
	func kill_myself():
		me.queue_free()
		pass
	func exit():
		pass