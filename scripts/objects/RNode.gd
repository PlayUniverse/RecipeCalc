extends GNode
class_name RNode

var name : String;
var result : INode;
var amount : int;

var ingredients : Dictionary = {};
var crafted : int = 0;

func _init(var iname : String, var iresult : INode, var iamount : int):
	name = iname;
	amount = iamount;
	result = iresult;
	result.created = self;

func iadd(var node : INode, var amount : int):
	ingredients[node.name] = {"node": node, "amount": amount};

func iget(var node : INode) -> int:
	return ingredients[node.name]["amount"];
	
func ihas(var node : INode) -> bool:
	return ingredients.has(node.name);

func reset():
	graphed = false;
	crafted = 0;
	for node in ingredients.keys():
		node.reset();

func craft(var amount : int):
	var requested = amount - result.overflow;
	result.needed += result.overflow;
	result.overflow = 0;
	if requested == 0:
		return;
	var add = self.amount;
	while requested > 0:
		for node in ingredients.keys():
			var data = ingredients[node];
			data["node"].craft(data["amount"]);
		crafted += 1;
		result.needed += add;
		requested -= add;
	if requested < 0:
		requested *= -1;
		result.needed -= requested;
		result.overflow = requested;
