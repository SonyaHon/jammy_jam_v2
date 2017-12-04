extends RigidBody2D

export(float) var player_speed = 1.5;
export(float) var player_initial_mass = 1;
onready var pl_body = self;

var player_mass;
var current_velocity;
var current_acceleration;



var attack_anim = preload("res://sprites/player_attack.png");
var idle_anim = preload("res://sprites/player_idle.png");
var run_anim = preload("res://sprites/player_run.png");
var death_anim = preload("res://sprites/player_death.png");

var bullet = preload("res://prefabs/bullet.tscn");

var current_state;
var prev_state = STATE_IDLE;

enum {
	
	STATE_IDLE,
	STATE_RUN,
	STATE_ATTACK,
	STATE_DEATH
	
}

var slow_padle_coef = 1;
var speed_padle_coef = 1;

var canAttack = true;
var score = 0;

signal died

var started = false;

func _ready():
	add_to_group(Utils.GR_PLAYER);
	set_process_input(true);
	set_fixed_process(true);
	set_process(true);
	player_mass = player_initial_mass;
	current_velocity = Vector2(0, 0);
	current_acceleration = Vector2(0, 0);
	current_state = StateIdle.new(self);
	connect("body_enter", self, "_on_collide");
	pass

func entered_slow_padle():
	slow_padle_coef = 0.9;
	pass

func exited_slow_padle():
	slow_padle_coef = 1;
	pass

func entered_speed_padle():
	speed_padle_coef = 1.1;
	pass

func exited_speed_padle():
	speed_padle_coef = 1;
	pass

func heal():
	player_mass = player_initial_mass;
	current_velocity = Vector2(0, 0);
	current_acceleration = Vector2(0 ,0);
	pass

func _on_collide(target):
	if target.is_in_group(Utils.GR_BOUNCE_COLUMN):
		current_acceleration *= -1.2;
		current_velocity *= -1; 
		pass
	elif target.is_in_group(Utils.GR_ENEMY_BULLET):
		player_mass += 1;
		if player_mass >= 100:
			player_mass = 99.99
			pass
		current_acceleration += target.get_linear_velocity() * 0.03;
		pass
	elif target.is_in_group(Utils.GR_WALL):
		change_state(STATE_DEATH);
		pass
	pass

func _process(delta):
	var nv = get_pos() - Utils.get_world_node("camera").get_global_mouse_pos();
	pl_body.get_node("sprite").set_rot(atan2(nv.x, nv.y));
	
	Utils.get_world().get_node("camera").get_node("GUI").get_node("mass").get_node("lbl_mass").set_text(String(player_mass));
	Utils.get_world().get_node("camera").get_node("GUI").get_node("score").get_node("lbl_src").set_text(String(score));
	
	pass

func addScore():
	score += 1;
	pass

func _fixed_process(delta):
	
	current_velocity += current_acceleration;
	current_velocity *= (player_mass / 100) * slow_padle_coef * speed_padle_coef;
	
	if abs(current_velocity.x) < 10:
		current_velocity.x = 0;
	if abs(current_velocity.y) < 10:
		current_velocity.y = 0;
	
	if String(current_state.get_type()) == String(STATE_RUN) and current_velocity.x == 0 and current_velocity.y == 0:
		change_state(STATE_IDLE);
		pass
	elif String(current_state.get_type()) == String(STATE_IDLE) and (current_velocity.x != 0 or current_velocity.y != 0):
		change_state(STATE_RUN);
		pass
	
	if String(current_state.get_type()) == String(STATE_RUN) and player_mass > 90.0001:
		player_mass -= 0.001
		pass
	
	pl_body.set_linear_velocity(current_velocity)
	pass

func _input(evt):
	if started:
		if evt.type == 1:
			# W
			if evt.scancode == 87 and evt.pressed == true:
				current_acceleration.y = -player_speed;
				pass
			elif evt.scancode == 87 and evt.pressed == false:
				current_acceleration.y = 0;
				pass
			# D
			if evt.scancode == 68 and evt.pressed == true:
				current_acceleration.x = player_speed;
				pass
			elif evt.scancode == 68 and evt.pressed == false:
				current_acceleration.x = 0;
				pass
			# S
			if evt.scancode == 83 and evt.pressed == true:
				current_acceleration.y = player_speed;
				pass
			elif evt.scancode == 83 and evt.pressed == false:
				current_acceleration.y = 0;
				pass
			# A
			if evt.scancode == 65 and evt.pressed == true:
				current_acceleration.x = -player_speed;
				pass
			elif evt.scancode == 65 and evt.pressed == false:
				current_acceleration.x = 0;
				pass
			pass
		elif evt.type == 3 and evt.button_index == 1 and evt.pressed == 1:
			if String(current_state.get_type()) != String(STATE_ATTACK) and canAttack:
				canAttack = false;
				change_state(STATE_ATTACK);
	pass

func start():
	started = true;
	get_node("sound").play("music");
	pass

func fire():
	var b_instance = bullet.instance();
	var direct = get_pos() - Utils.get_world_node("camera").get_global_mouse_pos();
	b_instance.set_pos(get_global_pos() - direct.normalized() * 30);
	b_instance.add_to_group(Utils.GR_BULLET);
	b_instance.set_linear_velocity(direct.normalized() * -300);
	b_instance.set_rot(atan2(direct.x, direct.y))
	Utils.get_world().add_child(b_instance);
	canAttack = true;
	pass

func getCurrentMass():
	return player_mass;
	pass

func change_state(new_state):
	new_state = int(new_state);
	current_state.exit();
	prev_state = current_state.get_type();
	
	if new_state == STATE_IDLE:
		current_state = StateIdle.new(self);
	elif new_state  == STATE_RUN:
		current_state = StateRun.new(self);
	elif new_state == STATE_ATTACK:
		current_state = StateAttack.new(self);
	elif new_state  == STATE_DEATH:
		current_state = StateDeath.new(self);
	pass




class StateIdle:
	
	var me;
	
	func _init(me):
		self.me = me
		me.get_node("sprite").set_texture(me.idle_anim);
		me.get_node("sprite").set_hframes(4); # TODO Change to real value
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(0.5);
		me.get_node("anim").play("idle");
		pass
	
	func _fixed_update():
		pass
	
	func get_type():
		return STATE_IDLE
		pass
	
	func _update():
		pass
	
	func exit():
		pass

class StateRun:
	
	var me;
	
	func _init(me):
		self.me = me
		me.get_node("sprite").set_texture(me.run_anim);
		me.get_node("sprite").set_hframes(8); # TODO Change to real value
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(1.2);
		me.get_node("anim").play("run");
		pass
	
	func get_type():
		return STATE_RUN
		pass
	
	func exit():
		me.get_node("anim").stop();
		pass


class StateDeath:
	var me;
	func  _init(me):
		self.me = me;
		me.get_node("sprite").set_texture(me.death_anim);
		me.get_node("sprite").set_hframes(6);
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(2.2);
		me.get_node("anim").play("death");
		me.get_node("sound").play("death");
		me.get_node("anim").connect("finished", self, "fins");
		me.set_linear_velocity(Vector2(0,0))
		me.current_velocity = Vector2(0, 0)
		me.current_acceleration = Vector2(0, 0);
		pass
	func fins():
		me.emit_signal("died");
		pass
	func exit():
		pass

class StateAttack:
	var me;
	var prev_state;
	
	func _init(me):
		self.me = me
		self.prev_state = me.prev_state;
		me.get_node("sprite").set_texture(me.attack_anim);
		me.get_node("sprite").set_hframes(6); 
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(1.5);
		me.get_node("anim").play("attack");
		me.get_node("anim").connect("finished", self, "attack_finished");
		pass
	
	func attack_finished():
		me.fire();
		me.change_state(self.prev_state);
		pass
	
	func exit():
		
		pass