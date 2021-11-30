tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Console", "Node", preload("res://addons/console/ConsoleSetup.gd"), preload("icon.png"))
