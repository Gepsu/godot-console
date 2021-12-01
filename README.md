# Godot Console
A very simple addon to run functions in game. Might turn this into a more feature complete dev tool in the future, but for now this is all you get.

## How to use?
You add a Console node in your scene tree and press F3 to open and close the console.  
To add new commands, use ```Console.add_command("command", funcref(object, "function"))```  
You can also add arguments to your commands by adding an array of types as a third argument.  
For example ```Console.add_command("command", funcref(object, "function"), [TYPE_REAL, TYPE_BOOL])```  
  
Only 4 types are supported:
- Integer (TYPE_INT)
- Float (TYPE_REAL)
- Boolean (TYPE_BOOL)
- String (TYPE_STRING)
  
You also have an option to use signals ```on_command(String)``` and ```on_successful_command(String)```. Former is called even if the addon throws an error at you, latter only when the command passed and the connected function was called. You get access to these signals with ```Console.get_console()```.

## Planned Features
- Auto completion
- Customization options
- More later...

## Pictures
![](https://github.com/Gepsu/godot-console/blob/master/72889b9c05890e9d483f7b424bd1811f.png)
![](https://github.com/Gepsu/godot-console/blob/master/19715eed8943f5ac8d3173806d14920b.png)

## Known Bugs
- 
