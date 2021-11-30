extends CanvasLayer
class_name Console

const connections = {}

export var size : float = 200

onready var control = $Control
onready var tween = $Tween
onready var input = $Control/VBoxContainer/TextEdit
onready var output = $Control/VBoxContainer/RichTextLabel

var open : bool = false

func _ready() -> void:
	control.rect_size.y = 0
	input.hide()
	
	add_command("clear", funcref(self, "clear"))
	add_command("commands", funcref(self, "commands"))
	add_command("help", funcref(self, "help"))
	output("Welcome to [color=#FFA500]Geppy's Console v0.1[/color]", false)
	output("Type '[color=yellow]help[/color]' if you'd like more information about the addon", false)

func _input(event: InputEvent) -> void:
	if !(event is InputEventKey) or !event.is_pressed() or event.is_echo():
		return
	
	if Input.is_key_pressed(KEY_F3):
		toggle()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		input.grab_focus()

func toggle() -> void:
	open = !open
	if open:
		open()
	else:
		close()

func open() -> void:
	input.show()
	tween.stop_all()
	tween.interpolate_property(control, "rect_size:y", control.rect_size.y, size, .5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

func close() -> void:
	input.hide()
	tween.stop_all()
	tween.interpolate_property(control, "rect_size:y", control.rect_size.y, 0, .5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	input.release_focus()

func command(cmd : String) -> void:
	if cmd in connections.keys():
		var function = connections[cmd] as FuncRef
		output("[color=yellow]%s[/color]" % cmd)
		function.call_func()
	else:
		output("[color=red]Unknown command ('%s')[/color]" % cmd)

func output(msg : String, display_time : bool = true) -> void:
	var time = OS.get_time()
	var time_string = "%02d:%02d - " % [time["hour"], time["minute"]]
	
	if !display_time:
		time_string = ""
	
	output.bbcode_text += "%s%s\n" % [time_string, msg]

func _on_Tween_tween_all_completed() -> void:
	if open:
		input.grab_focus()
	else:
		input.release_focus()

func _on_TextEdit_text_changed() -> void:
	if input.get_line_count() > 1:
		if input.text != "\n":
			command(input.text.replace("\n", ""))
		input.text = ""

static func add_command(cmd : String, function : FuncRef) -> void:
	if connections.has(cmd):
		print("Console - Command already exists ('%s') !!" % cmd)
	else:
		connections[cmd] = function

# Built-in Commands
func clear() -> void:
	output.bbcode_text = ""

func commands() -> void:
	output("Commands:", false)
	for cmd in connections.keys():
		output("- [color=yellow]%s[/color]" % cmd, false)

func help() -> void:
	output("To add commands to this console, you type [color=yellow]Console.add_command(\"command\", " +
			"funcref(object, \"function\"))[/color] somewhere in your script. Object being the script that " +
			"contains the function you're trying to add (typically 'self'). Once you've done that, you will " +
			"be able to type that command in here and run the function while your game is running.", false)
	output("", false)
	output("For a list of all the commands, type '[color=yellow]commands[/color]'", false)
