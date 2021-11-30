extends Node

func _ready() -> void:
	add_child(load("res://addons/console/Console.tscn").instance())
