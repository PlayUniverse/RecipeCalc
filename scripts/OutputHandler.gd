extends DataHandler

const Helper = preload("res://scripts/Helper.gd");

var data_name : OptionButton;
var data_amount : LineEdit;

var container : TabManager;

var recipe_temp : GraphNode;
var ingredient_temp : GraphNode;

func _ready():
	data_name = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/OutputContainer/Holder/OutputName');
	data_amount = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/OutputContainer/Holder/OutputAmount');
	container = get_node('/root/Control/Scripts/TabManager');
	recipe_temp = get_node('/root/Control/Templates/Graph/RecipeNode');
	ingredient_temp = get_node('/root/Control/Templates/Graph/IngredientNode');
	
func unload():
	data_name.select(0);
	data_amount.text = "";
	
func update_options(var data : DataNode):
	var list = data.holder.ingredient_list
	var index : int = 0
	var size : int = list.get_item_count();
	data_name.clear();
	while index < size:
		data_name.add_item(list.get_item_text(index));
		index = index + 1;

func validate(var data : DataNode) -> bool:
	if not data.holder.has_ingredient(data_name.text):
		return false;
	if data_amount.text == "":
		return true;
	return int(data_amount.text) > 0;
	
func calculate(var data : DataNode):
	if not validate(data):
		return;
	var name : String = data_name.text;
	var amount : int;
	if data_amount.text == "":
		amount = 1;
	else:
		amount = int(data_amount.text);
	var graph : GraphEdit = container.create(name, amount);
	if graph == null:
		return;
	var ingredient_dict : Dictionary = {};
	for recipe in data.recipes.values():
		if recipe.result_item == "" || recipe.result_item == null:
			continue;
		ingredient_dict[recipe.result_item] = recipe;
	var node : INode = Helper.NodeHelper.create(name, ingredient_dict);
	ingredient_dict.clear();
	node.craft(amount);
	add_ingredient_node(node, graph, true, {});
	
func add_ingredient_node(var node : INode, var graph : GraphEdit, var root : bool, var offset : Dictionary):
	if node.graphed:
		return;
	var gnode : GraphNode = ingredient_temp.duplicate();
	gnode.title = node.name;
	gnode.name = "i_" + node.name;
	graph.add_child(gnode);
	repose(gnode, graph, node, offset);
	gnode.visible = true;
	node.graphed = true;
	var label : Label = gnode.get_node('Container/Box/Amount');
	label.text += str(node.needed);
	if not node.overflow == 0:
		var parent = label.get_parent();
		label = Label.new();
		label.name = "Overflow";
		label.text = "Overflow: " + str(node.overflow)
		parent.add_child(label);
	if root:
		gnode.set_slot(0, false, 0, gnode.get_slot_color_left(0), true, 0, gnode.get_slot_color_right(0));
	if node.created == null:
		gnode.set_slot(0, true, 0, gnode.get_slot_color_left(0), false, 0, gnode.get_slot_color_right(0));
		return;
	add_recipe_node(node.created, graph, offset);
	graph.connect_node(gnode.name, 0, "r_" + node.created.name, 0);
	
func add_recipe_node(var node : RNode, var graph : GraphEdit, var offset : Dictionary):
	if node.graphed:
		return;
	var gnode : GraphNode = recipe_temp.duplicate();
	gnode.title = node.name;
	gnode.name = "r_" + node.name;
	graph.add_child(gnode);
	repose(gnode, graph, node, offset);
	gnode.visible = true;
	node.graphed = true;
	var label : Label = gnode.get_node('Container/Result/Box/Item');
	label.text += str(node.result.name);
	label = gnode.get_node('Container/Result/Box/Amount');
	label.text += str(node.amount);
	label = gnode.get_node('Container/Result/Box/Craft');
	label.text += str(node.crafted);
	var list0 : ItemList = gnode.get_node('Container/Recipe/Box/Split/Info/Ingredients');
	var list1 : ItemList = gnode.get_node('Container/Recipe/Box/Split/Info/Amounts');
	var list2 : ItemList = gnode.get_node('Container/Recipe/Box/Split/Info/Crafted');
	for ingredient_name in node.ingredients:
		var ingredient_data = node.ingredients[ingredient_name];
		list0.add_item(ingredient_name);
		var count : int = ingredient_data["amount"]
		list1.add_item(str(count));
		list2.add_item(str(count * node.crafted));
		add_ingredient_node(ingredient_data["node"], graph, false, offset);
		graph.connect_node(gnode.name, 0, "i_" + ingredient_name, 0);

func get_graph_node(var graph : GraphEdit, var name : String) -> GraphNode:
	for node in graph.get_children():
		if node.name == name:
			return node;
	return null;

func repose(var node : GraphNode, var graph : GraphEdit, var gnode : GNode, var offset : Dictionary):
	if not gnode.id in offset:
		offset[gnode.id] = [{"x": 0, "y": 0, "id": gnode.id - 1, "idx": -1}];
	var array : Array = offset[gnode.id]
	var index = array.size() - 1;
	var data = array[index];
	var size = node.rect_size;
	node.offset.x = data["x"];
	node.offset.y = data["y"];
	if data["idx"] != index:
		data["idx"] = index;
		data["y"] += (size.y + 40);
	if data["id"] != gnode.id:
		data["id"] = gnode.id;
		offset[gnode.id + 1] = [{"x": (data["x"] + size.x + 50), "y": 0, "id": gnode.id, "idx": -1}]
	offset[gnode.id].append(data);
