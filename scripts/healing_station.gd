extends Area2D

onready var current_state = StateIdle.new(self)

var anim_burst = preload("res://sprites/heal_burst.png");
var anim_idle = preload("res://sprites/preheal-sheet.png");

var can_heal = true;

enum {
	STATE_IDLE,
	STATE_END
}

func _ready():
	change_state(STATE_IDLE)
	connect("body_enter", self, "entered");
	pass

func entered(target):
	if target.is_in_group(Utils.GR_PLAYER) and can_heal:
		change_state(STATE_END);
		target.heal();
		pass
	pass

func change_state(new_state):
	if new_state == STATE_END:
		current_state = StateEnd.new(self)
	else:
		current_state = StateIdle.new(self)
	pass

class StateIdle:
	var me
	func _init(me):
		self.me = me
		var wt = me.get_node("water")
		wt.set_texture(me.anim_idle);
		wt.set_hframes(4);
		me.get_node("anim").set_speed(0.2);
		me.get_node("anim").play("idle");
		pass

class StateEnd:
	var me
	func _init(me):
		self.me = me
		var wt = me.get_node("water")
		wt.set_texture(me.anim_burst);
		wt.set_hframes(7);
		me.get_node("sound").play("splash");
		me.get_node("anim").set_speed(1.5);
		me.get_node("anim").play("burst");
		me.get_node("anim").connect("finished", self, "_on_finish")
		pass
	
	func _on_finish():
		me.get_node("water").queue_free();
		me.get_node("anim").queue_free();
		me.get_node("sound").queue_free();
		me.can_heal = false;
		pass



