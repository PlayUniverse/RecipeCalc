extends Node
class_name TabManager

var data : DataNode
var container : TabContainer;
var template : VSplitContainer;
var handler : GraphLoader;

var names : Dictionary = {}

func _ready():
	data = get_node('/root/Control/Scripts/DataNode');
	container = get_node('/root/Control/Panel/Split/Panel/Tab');
	template = get_node('/root/Control/Templates/Result');
	handler = get_node('/root/Control/Scripts/GraphLoader');

func create(var name : String, var amount : int) -> GraphEdit:
	if names.has(name):
		return null;
	var gen_name = name + " (x" + str(amount) + ")";
	names[name] = gen_name;
	var tab : VSplitContainer = template.duplicate();
	tab.name = gen_name;
	var _ignore;
	var button : Button = tab.get_node('Controls/Button');
	_ignore = button.connect("pressed", self, "delete_tab", [gen_name]);
	var graph : GraphEdit = tab.get_node('View/Graph');
	_ignore = graph.connect("node_selected", handler, '_on_Graph_select', [graph]);
	container.add_child(tab);
	return graph;
	
func get_ingredient(var name : String) -> String:
	if names.size() == 0:
		return "";
	for key in names.keys():
		var value = names.get(key);
		if value == name:
			return key;
	return "";
	
func delete_tab(var name : String):
	var tab : VSplitContainer = container.get_current_tab_control();
	container.current_tab = container.current_tab - 1;
	container.remove_child(tab);
	var _ignore = names.erase(get_ingredient(name));
	tab.queue_free();

