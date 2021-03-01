class_name Recipe

var NAME : String;
var ingredients : Array = [];
var amounts : Array = [];

var result_item : String = "";
var result_amount : int;

func _init(name : String):
	NAME = name;
	
func update(var old : String, var new : String):
	if result_item == old:
		result_item = new;
	if not ingredients.has(old):
		return;
	ingredients[ingredients.find(old)] = new;
	
func increase(name : String) -> bool:
	if not contains(name):
		return false;
	var index = ingredients.find(name);
	amounts[index] = amounts[index] + 1;
	return true;
	
func decrease(name : String) -> int:
	if not contains(name):
		return -1;
	var index = ingredients.find(name);
	if(amounts[index] == 0):
		amounts.remove(index);
		remove(name);
		return 1;
	amounts[index] = amounts[index] - 1;
	return 0;
	
func contains(name : String) -> bool:
	return ingredients.has(name);
	
func add(name : String) -> bool:
	if ingredients.has(name):
		return false;
	ingredients[-1] = name;
	return true;
	
func remove(name : String) -> bool:
	if not ingredients.has(name):
		return false;
	ingredients.erase(name);
	return true;
	
func amount() -> int:
	if result_amount == null || result_amount <= 0:
		return 1;
	return result_amount;
