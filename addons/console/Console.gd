extends CanvasLayer
class_name Console

const connections = {}
const arguments = {}
const node = []

signal on_command(cmd)
signal on_succesful_command(cmd)

export var size : float = 200
export var error_messages_enabled : bool = true

onready var control = $Control
onready var tween = $Tween
onready var input = $Control/VBoxContainer/TextEdit
onready var output = $Control/VBoxContainer/RichTextLabel

var open : bool = false
var history : Array
var history_index : int = -1 setget set_history

func _ready() -> void:
	_setup_variables()
	
	node.append(self)
	control.rect_size.y = 0
	input.hide()
	
	add_command("clear", funcref(self, "clear"))
	add_command("commands", funcref(self, "commands"))
	add_command("help", funcref(self, "help"))
	add_command("found-a-bug", funcref(self, "bug"))
	add_command("github", funcref(self, "github"))
	output("Welcome to [color=#FFA500]Godot Console v0.1[/color]", false)
	output("Type '[color=yellow]help[/color]' if you'd like more information about the addon", false)

func _setup_variables() -> void:
	size = ProjectSettings.get_setting("godot_console/size")
	error_messages_enabled = ProjectSettings.get_setting("godot_console/error_messages_enabled")

func _input(event: InputEvent) -> void:
	if !(event is InputEventKey) or !event.is_pressed() or event.is_echo():
		return
	
	if Input.is_key_pressed(KEY_F3):
		toggle()
		
	if !open: 
		return
	
	if Input.is_key_pressed(KEY_UP) and !history.empty():
		if history_index == -1:
			self.history_index = history.size() - 1
		else:
			self.history_index -= 1 if history_index > 0 else 0
	elif Input.is_key_pressed(KEY_DOWN) and !history.empty():
		if history_index != -1:
			self.history_index += 1 if history_index < history.size() - 1 else 0
	else:
		self.history_index = -1

func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		input.grab_focus()

func set_history(new_index : int) -> void:
	history_index = new_index
	if new_index != -1:
		input.text = history[new_index]

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
	input.grab_focus()

func close() -> void:
	input.hide()
	tween.stop_all()
	tween.interpolate_property(control, "rect_size:y", control.rect_size.y, 0, .5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	input.release_focus()

func command(msg : String) -> void:
	# Add message to history if its not already there
	if !(msg in history):
		history.append(msg)
	
	# Separate command and arguments
	var cmd = msg
	var args : Array = cmd.split(" ")
	if args.size() > 1:
		cmd = args.pop_front()
	
	emit_signal("on_command", cmd)
	
	if cmd in connections.keys():
		# Get rid of excess arguments
		while args.size() > arguments[cmd].size():
			args.pop_back()
		
		var function = connections[cmd] as FuncRef
		
		if !arguments[cmd].empty(): # If the command contains arguments
			# Make sure arguments are correct type
			var wrong_arg : bool = false
			for i in args.size():
				var arg = args[i] as String
				match arguments[cmd][i]:
					TYPE_INT:
						if !arg.is_valid_integer():
							wrong_arg = true
							break
						arg = int(arg)
					TYPE_REAL:
						if !arg.is_valid_float():
							wrong_arg = true
							break
						arg = float(arg)
					TYPE_BOOL:
						if arg.to_lower() != "true" and arg.to_lower() != "false":
							wrong_arg = true
							break
						arg = arg.to_lower() == "true"
					TYPE_STRING:
						pass
					_: # Not supported type
						output("[color=red]One or more argument types are not supported ('%s')[/color]" % msg, true, true)
						return
				
				# If we made it this far then we got the right type
				args[i] = arg
						
			if wrong_arg:
				output("[color=red]One or more argument are not the correct type ('%s')[/color]" % msg, true, true)
				return
			
			emit_signal("on_succesful_command", cmd)
			function.call_funcv(args)
				
		else: # If it doesn't contain arguments then just run the command
			output("[color=yellow]%s[/color]" % cmd)
			emit_signal("on_succesful_command", cmd)
			function.call_func()
	else:
		output("[color=red]Unknown command ('%s')[/color]" % cmd, true, true)

func output(msg : String, display_time : bool = true, is_error_message : bool = false) -> void:
	if is_error_message and !error_messages_enabled:
		return
	
	var time = OS.get_time()
	var time_string = "%02d:%02d - " % [time["hour"], time["minute"]]
	
	if !display_time:
		time_string = ""
	
	output.bbcode_text += "%s%s\n" % [time_string, msg]

func _on_TextEdit_text_changed() -> void:
	if input.get_line_count() > 1:
		if input.text != "\n":
			command(input.text.replace("\n", ""))
		input.text = ""

# Static Functions
static func add_command(cmd : String, function : FuncRef, args : Array = []) -> void:
	if " " in cmd:
		printerr("Console - Spaces are not allowed in commands! ('%s')" % cmd)
	elif connections.has(cmd):
		printerr("Console - Command already exists! ('%s')" % cmd)
	elif !function.is_valid():
		printerr("Console - Function is not valid! ('%s')" % cmd)
	else:
		connections[cmd] = function
		arguments[cmd] = args

static func get_console() -> Console:
	return node.front()

# Built-in Commands
func clear() -> void:
	output.bbcode_text = ""

func commands() -> void:
	output("Commands:", false)
	for cmd in connections.keys():
		output("- [color=yellow]%s[/color]" % cmd, false)

func bug() -> void:
	output("[color=#FFA500]Opening issues page in browser...[/color]", false)
	OS.shell_open("https://github.com/Gepsu/godot-console/issues")

func github() -> void:
	output("[color=#FFA500]Opening GitHub page in browser...[/color]", false)
	OS.shell_open("https://github.com/Gepsu/godot-console")

func help() -> void:
	output("To add commands to this console, you type [color=yellow]Console.add_command(\"command\", " +
			"funcref(object, \"function\"))[/color] somewhere in your script. Object being the script that " +
			"contains the function you're trying to add (typically 'self'). Once you've done that, you will " +
			"be able to type that command in here and run the function while your game is running. Additionally " +
			"you may also want to use arguments. This addon supports 4 types ([color=#44a6c6]TYPE_INT, TYPE_REAL," +
			"TYPE_STRING, TYPE_BOOL[/color]). To add arguments to your command, you add a third argument. " +
			"An array that contains the types you need in the correct order. [color=yellow]" +
			"Console.add_command(\"command\", funcref(object, \"function\"), [TYPE_INT, TYPE_BOOL])[/color] " +
			"for example.", false)
	output("", false)
	output("For a list of all the commands, type '[color=yellow]commands[/color]'", false)
