extends RigidBody2D

export(float) var player_speed = 1.5;
export(float) var player_initial_mass = 1;

onready var pl_body = self;

var player_mass;
var current_velocity;
var current_acceleration;

var current_state;
var prev_state;

var inRadius = false;

enum {
	
	STATE_IDLE,
	STATE_RUN,
	STATE_ATTACK,
	STATE_DEATH
	
}

var slow_padle_coef = 1;
var speed_padle_coef = 1;

var anim_idle = preload("res://sprites/slime_idle.png");
var anim_move = preload("res://sprites/slime_move .png");
var anim_attack = preload("res://sprites/slime_atck.png");
var anim_death = preload("res://sprites/slime_death .png");

var bullet = preload("res://prefabs/slime_bullet.tscn");

var started = false;

func _ready():
	add_to_group(Utils.GR_ENEMY);
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

func _on_collide(target):
	if target.is_in_group(Utils.GR_BOUNCE_COLUMN):
		current_acceleration *= -1.5;
		current_velocity *= -1; 
		pass
	elif target.is_in_group(Utils.GR_WALL):
		change_state(STATE_DEATH);
		pass
	elif target.is_in_group(Utils.GR_BULLET):
		current_velocity = target.get_linear_velocity()  * 3;
		pass
	elif target.is_in_group(Utils.GR_ENEMY):
		if target.get_index() > get_index():
			target.change_state(STATE_DEATH);
			target.set_linear_velocity(Vector2(0,0));
			target.current_velocity = Vector2(0,0);
		
		pass
	pass

func _process(delta):
	if started:
		var nv = get_pos() - Utils.get_world_node("player").get_pos();
		pl_body.get_node("sprite").set_rot(atan2(nv.x, nv.y));
		ai_update();
		pass
	
	pass

func start():
	started = true;
	pass

func ai_update():
	
	# get the closest wall point
	# get the closest path to player
	# count wich is nastier
	# go to it
	# if in radius
	# try to go around 
	var pl = Utils.get_world_node("player");
	var diff = get_pos() - pl.get_pos();
	var nacc  = sqrt(diff.x * diff.x  +  diff.y * diff.y);
	if abs(nacc) < 100:
		nacc = -50;
		inRadius = true;
		pass
	else:
		inRadius = false;
	
	if !inRadius:
		diff = diff.normalized() * (-nacc * 0.05);
		current_acceleration = diff;
		if  current_acceleration.x > 50:
			current_acceleration.x = 50;
		elif current_acceleration.y > 50:
			current_acceleration.y = 50;
		pass
	elif int(current_state.get_type()) != int(STATE_ATTACK):
		change_state(STATE_ATTACK);
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
	pl_body.set_linear_velocity(current_velocity)
	pass


func fire():
	var b_instance = bullet.instance();
	var direct = get_pos() - Utils.get_world_node("player").get_pos();
	b_instance.set_pos(get_global_pos() - direct.normalized() * 30);
	b_instance.add_to_group(Utils.GR_BULLET);
	b_instance.set_linear_velocity(direct.normalized() * -600);
	b_instance.set_rot(atan2(direct.x, direct.y))
	Utils.get_world().add_child(b_instance);
	pass

func getCurrentMass():
	return player_mass;
	pass

func change_state(new_state):
	new_state = int(new_state);
	prev_state = current_state.get_type();
	if int(current_state.get_type()) != STATE_ATTACK: 
		current_state.exit();
		
	
		if new_state == STATE_IDLE:
			current_state = StateIdle.new(self);
		elif new_state  == STATE_RUN:
			current_state = StateRun.new(self);
		elif new_state == STATE_ATTACK:
			current_state = StateAttack.new(self);
		elif new_state == STATE_DEATH:
			current_state = StateDeath.new(self);
		pass




class StateIdle:
	
	var me;
	
	func _init(me):
		self.me = me
		me.get_node("sprite").set_texture(me.anim_idle);
		me.get_node("sprite").set_hframes(8); # TODO Change to real value
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
		me.get_node("sprite").set_texture(me.anim_move);
		me.get_node("sprite").set_hframes(8); # TODO Change to real value
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(1.2);
		me.get_node("anim").play("move");
		pass
	
	func get_type():
		return STATE_RUN
		pass
	
	func exit():
		me.get_node("anim").stop();
		pass

class StateAttack:
	var me;
	var prev_state;
	
	func _init(me):
		self.me = me
		self.prev_state = me.prev_state;
		me.get_node("sprite").set_texture(me.anim_attack);
		me.get_node("sprite").set_hframes(8); # TODO Change to real value
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(4);
		me.get_node("anim").play("attack");
		me.get_node("anim").connect("finished", self, "attack_finished");
		pass
	
	func attack_finished():
		me.fire();
		me.change_state(self.prev_state);
		pass
	
	func exit():
		
		pass

class StateDeath:
	var me;
	var prev_state;
	
	func _init(me):
		self.me = me
		self.prev_state = me.prev_state;
		me.get_node("sprite").set_texture(me.anim_death);
		me.get_node("sprite").set_hframes(8); # TODO Change to real value
		me.get_node("sprite").set_frame(0);
		me.get_node("anim").set_speed(2);
		me.get_node("anim").play("death");
		me.get_node("anim").connect("finished", self, "attack_finished");
		pass
	
	func attack_finished():
		me.get_node("../../").reduceEnemies();
		me.queue_free();
		pass
	
	func exit():
		
		pass




