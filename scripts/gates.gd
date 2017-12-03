extends Node2D

onready var anim = get_node("anim");

func _ready():
	Utils.get_world().connect("lvl_cleared", self, "_open")
	get_node("passed").connect("body_exit", self, "_close")
	pass

func _open():
	anim.play("open");
	pass

func _close():
	anim.play("close");
	pass
