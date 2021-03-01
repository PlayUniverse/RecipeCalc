extends GNode
class_name INode

var name : String;
var created; # RNode

var needed : int = 0;
var overflow : int = 0;

func _init(var name : String):
	self.name = name;
	
func reset():
	graphed = false;
	needed = 0;
	if not created == null:
		created.reset();

func craft(var amount : int):
	if not created == null:
		created.craft(amount);
		return;
	needed += amount;
