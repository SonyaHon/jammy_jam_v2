extends Node2D

signal passed;

func _ready():
	
	get_node("exit").connect("passed", self, "psd");
	
	pass

func psd():
	emit_signal("passed");
	pass