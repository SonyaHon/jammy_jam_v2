extends Node

signal lvl_cleared;

var is_cleared = 0;
export(NodePath) var current_level;



var start_scene = preload("res://scenes/StartScreen.tscn");
var start_scene_inst;
var end_scene = preload("res://scenes/GameOverScreen.tscn");
var end_scene_inst;
var current_state;


enum {
	STATE_START,
	STATE_RUN,
	STATE_END
}

func _ready():
	set_process(true);
	current_state = StateStart.new(self);
	get_node("player").connect("died", self, "end_game");
	pass

func change_level(lvl):
	var prevAddr = current_level;
	current_level = lvl
	get_node("camera").get_node("GUI").get_node("LvlComplete").set_text("Level Completed!");
	get_node(current_level).start();
	pass

func end_game():
	change_state(STATE_END);
	end_scene_inst.get_node("Your Score").set_text(String('Your score: ' + String(get_node("player").score)));
	pass

func change_state(new_state):
	new_state = int(new_state)
	current_state.exit();
	
	if new_state == STATE_START:
		current_state = StateStart.new(self);
		pass
	elif new_state == STATE_RUN:
		current_state = StateRun.new(self);
		pass
	elif new_state == STATE_END:
		current_state = StateEnd.new(self);
		pass
	pass

class StateStart:
	var me
	func _init(me):
		self.me = me
		var inst = me.start_scene.instance();
		me.start_scene_inst = inst;
		me.add_child(inst);
		pass
	func exit():
		me.start_scene_inst.queue_free();
		pass

class StateRun:
	var me
	func _init(me):
		self.me = me;
		me.get_node(me.current_level).start();
		me.get_node("player").start();
		pass
	func exit():
		pass

class StateEnd:
	var me
	func _init(me):
		self.me = me
		var inst = me.end_scene.instance();
		me.end_scene_inst = inst;
		me.add_child(inst);
		pass
	func exit():
		me.end_scene_inst.queue_free();
		pass