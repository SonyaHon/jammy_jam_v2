extends Node2D

onready var anim = get_node("anim");
export(bool) var is_opened = false;

signal passed;

func _ready():
	if !is_opened:
		get_parent().get_parent().get_parent().connect("cleared", self, "_open", [], CONNECT_ONESHOT)
		get_node("passed").connect("body_exit", self, "_close", [], CONNECT_ONESHOT)
		pass
	else:
		anim.play("open");
		get_node("passed").connect("body_exit", self, "_close")
	pass

func _open():
	anim.play("open");
	pass

func _close(target):
	if target.is_in_group(Utils.GR_PLAYER):
		anim.play_backwards("open");
		anim.connect("finished", self, "play_sound");
		if is_opened:
			emit_signal("passed");
	pass

func play_sound():
	get_node("sound").play("door_close");
	pass
