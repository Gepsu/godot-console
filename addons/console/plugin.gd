tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("Console", "Node", preload("res://addons/console/ConsoleSetup.gd"), preload("icon.png"))
	
	if !ProjectSettings.has_setting("godot_console/size"):
		ProjectSettings.set_setting("godot_console/size", 200)
	
	if !ProjectSettings.has_setting("godot_console/error_messages_enabled"):
		ProjectSettings.set_setting("godot_console/error_messages_enabled", true)
