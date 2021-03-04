extends DataHandler

const Helper = preload("res://scripts/Helper.gd");
var Validation = Helper.Validation.new();

var data_name : LineEdit;

func _ready():
	data_name = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/IngredientContainer/Holder/IngredientName');

func unload():
	data_name.text = "";

func load_data(var name : String):
	data_name.text = name;

func save(var data : DataNode): 
	var list : ItemList = data.holder.ingredient_list;
	if list.get_item_count() == 0:
		return;
	var old = list.get_item_text(list.get_selected_items()[0]);
	var tmp_name = Validation.fix_name(data_name.text);
	if not data_name.text == tmp_name:
		data_name.text = tmp_name;
	if not old == tmp_name:
		var index : int = 0;
		while data.holder.has_ingredient(tmp_name):
			tmp_name = data_name.text + str(index);
		data_name.text = tmp_name;
	if tmp_name.length() > 48:
		data_name.text = old;
		return;
	list.set_item_text(list.get_selected_items()[0], tmp_name);
	data.current_ingredient = tmp_name;
	data.update_recipes(old, tmp_name);
	data.r_handler.update_names(old, tmp_name);
	data.r_handler.update_options(data);
	data.o_handler.update_options(data);
