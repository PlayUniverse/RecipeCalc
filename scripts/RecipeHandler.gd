extends DataHandler

const Helper = preload("res://scripts/Helper.gd");

var data_name : LineEdit;
var menu_button : MenuButton
var data_options : PopupMenu;

var data_list : ItemList;
var amount_list : ItemList;

var result_options : OptionButton;
var result_amount : LineEdit;

func _ready():
	data_name = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/RecipeName');
	menu_button = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/ListContainer/Split/IngredientOptions');
	data_options = menu_button.get_popup();
	data_options.connect("id_pressed", get_node('/root/Control/Scripts/OptionLoader'), "_on_IngredientOptions_id_pressed");
	data_list = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/ListContainer/Split/Holder/RecipeIngredients');
	amount_list = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/ListContainer/Split/Holder/RecipeAmounts');
	result_options = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/ResultContainer/Holder/Result');
	result_amount = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Info/Container/RecipeContainer/Scroll/Holder/ResultContainer/Holder/Amount');
	
func unload():
	data_name.text = "";
	data_list.clear();
	amount_list.clear();
	result_options.select(0);
	result_amount.text = "";
	
func load_data(var recipe : Recipe, var data : DataNode):
	data_name.text = recipe.NAME;
	data_list.clear();
	amount_list.clear();
	for item in recipe.ingredients:
		data_list.add_item(item);
	for amount in recipe.amounts:
		amount_list.add_item(str(amount));
	var index = Helper.ListHelper.find(data.holder.ingredient_list, recipe.result_item);
	if not index == -1:
		result_options.select(result_options.get_item_index(index));
	result_amount.text = str(recipe.result_amount);
	update_options(data);
	
func update(var data : DataNode):
	var index : int = 0
	var size : int = data_list.get_item_count()
	while index < size:
		var item : String = data_list.get_item_text(index);
		if not data.holder.has_ingredient(item):
			data_list.remove_item(index);
			amount_list.remove_item(index);
			size = size - 1;
			continue;
		index = index + 1;
	
func handle_increase(var index : int, var data : DataNode):
	amount_list.set_item_text(index, str(int(amount_list.get_item_text(index)) + 1));
	
func handle_decrease(var index : int, var data : DataNode):
	var amount = int(amount_list.get_item_text(index)) - 1;
	if amount == 1:
		data_list.remove_item(index);
		amount_list.remove_item(index);
		update_options(data);
		return;
	amount_list.set_item_text(index, str(amount - 1));
		
func handle_ingredient(var index : int, var data : DataNode):
	var value = data_options.get_item_text(index);
	data_list.add_item(value);
	amount_list.add_item(str(1));
	update_options(data);
	
func update_result(var index : int, var data : DataNode):
	var item = result_options.get_item_text(index);
	result_options.select(index);
	if not Helper.ListHelper.has(data_list, item):
		update_options(data);
		return;
	var at = Helper.ListHelper.find(data_list, item);
	data_list.remove_item(at);
	amount_list.remove_item(at);
	update_options(data);
		
func update_options(var data : DataNode):
	var list = data.holder.ingredient_list
	var index : int = 0
	var internal : int = 0;
	var size : int = list.get_item_count();
	data_options.clear();
	while index < size:
		var item = list.get_item_text(index);
		if Helper.ListHelper.has(data_list, item) || result_options.text == item:
			index = index + 1;
			continue;
		data_options.add_item(item, internal);
		index = index + 1;
		internal = internal + 1;
	var count = result_options.get_item_count();
	index = 0;
	var selected = result_options.get_selected_id();
	var sel_value;
	if count != 0:
		sel_value = result_options.get_item_text(selected);
	if count < size:
		while index < size:
			var value
			if index < count:
				value = list.get_item_text(index);
				if not value == result_options.get_item_text(index):
					result_options.set_item_text(index, value);
			else:
				value = list.get_item_text(index);
				result_options.add_item(value);
				count = count + 1;
			if value == sel_value:
				selected = index;
			index = index + 1;
	elif count > size:
		while index < count:
			if not index + 1 >= size:
				var value = list.get_item_text(index);
				if not value == result_options.get_item_text(index):
					result_options.remove_item(index);
					count = count - 1;
					continue;
			else:
				result_options.remove_item(index);
				count = count - 1;
				continue;
			index = index + 1;
	else:
		while index < size:
			var value = list.get_item_text(index);
			if not value == result_options.get_item_text(index):
				result_options.set_item_text(index, value);
			index = index + 1;
	result_options.select(selected);

func update_names(var old : String, var new : String):
	var index : int = 0
	var size : int = data_list.get_item_count();
	while index < size:
		var item = data_list.get_item_text(index);
		if item == old:
			data_list.set_item_text(index, new);
			break;
		index = index + 1;

func save(var data : DataNode): 
	var list : ItemList = data.holder.recipe_list;
	if list.get_item_count() == 0:
		return;
	var old_name = list.get_item_text(list.get_selected_items()[0]);
	var tmp_name = data_name.text;
	if not old_name == tmp_name:
		var index : int = 0;
		while data.holder.has_recipe(tmp_name):
			tmp_name = data_name.text + str(index);
		data_name.text = tmp_name;
	list.set_item_text(list.get_selected_items()[0], data_name.text);
	data.current_recipe_name = tmp_name;
	var recipe : Recipe = data.get_recipe(old_name);
	var size : int = data_list.get_item_count();
	var index : int = 0
	recipe.ingredients.clear();
	recipe.amounts.clear();
	recipe.NAME = tmp_name;
	if data.holder.has_ingredient(result_options.text):
		recipe.result_item = result_options.text;
	recipe.result_amount = int(result_amount.text);
	if recipe.result_amount <= 0:
		recipe.result_amount = 1;
	result_amount.text = str(recipe.result_amount);
	while index < size:
		recipe.ingredients.append(data_list.get_item_text(index));
		recipe.amounts.append(int(amount_list.get_item_text(index)));
		index = index + 1;
	data.update_recipe(old_name, recipe);
