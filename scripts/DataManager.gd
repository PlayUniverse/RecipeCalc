extends Node

var data : DataNode;
var file_export : FileDialog;
var file_import : FileDialog;

var error_popup : WindowDialog;

var path : String;

func _ready():
	data = get_node('/root/Control/Scripts/DataNode');
	error_popup = get_node('/root/Control/Dialog/WindowDialog');
	file_export = get_node('/root/Control/Dialog/Export');
	file_import = get_node('/root/Control/Dialog/Import');
	file_import.window_title = "Import a recipe calculation";
	path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/";

func _on_ExportButton_pressed():
	file_export.current_path = path;
	file_export.popup_centered();

func _on_ImportButton_pressed():
	file_import.current_path = path;
	file_import.popup_centered();

func fail(var text : String):
	error_popup.get_node('Label').text = text;
	error_popup.popup_centered();

func _on_Export_file_selected(path):
	if not path.ends_with(".json"):
		fail("You can only save .json files!");
		return;
	var output : Dictionary = {};
	output["ingredients"] = save_ingredients();
	output["recipes"] = save_recipes();
	output["loaded"] = save_loaded();
	var printable = JSON.print(output, "\t", false);
	var file : File = File.new();
	file.open(path, File.WRITE);
	file.store_string(printable);
	file.close();
	
func save_ingredients() -> Array:
	var list = data.holder.ingredient_list;
	var size = list.get_item_count();
	var index = 0;
	var output = [];
	while index < size:
		output.append(list.get_item_text(index));
		index += 1;
	return output;
	
func save_recipes() -> Dictionary:
	var list = data.holder.recipe_list;
	var size = list.get_item_count();
	var index = 0;
	var output = {};
	while index < size:
		var output0 = {}
		var item = list.get_item_text(index);
		var recipe : Recipe = data.get_recipe(item);
		output0["result"] = {
			"item": recipe.result_item,
			"amount": recipe.result_amount
		}
		var size0 = recipe.ingredients.size();
		var index0 = 0;
		var ingreds = {}
		while index0 < size0:
			ingreds[recipe.ingredients[index0]] = recipe.amounts[index0];
			index0 += 1;
		output0["ingredients"] = ingreds;
		output[recipe.NAME] = output0;
		index += 1;
	return output;
	
func save_loaded() -> Dictionary:
	var output = {};
	output["ingredient"] = data.current_ingredient;
	output["recipe"] = data.current_recipe_name;
	output["output"] = {
		"item": data.o_handler.data_name.text,
		"amount": int(data.o_handler.data_amount.text)
	}
	return output;

func _on_Import_file_selected(path):
	print(path);
	if not path.ends_with(".json"):
		fail("You can only load .json files!");
		return;
	var file : File = File.new();
	file.open(path, File.READ);
	var content = file.get_as_text();
	file.close();
	var parse_result : JSONParseResult = JSON.parse(content);
	if not parse_result.error == 0:
		var parts = path.split("/");
		fail("Failed to load " + parts[parts.size() - 1]);
		return;
	data.recipes.clear();
	data.holder.ingredient_list.clear();
	data.holder.recipe_list.clear();
	data.i_handler.unload();
	data.r_handler.unload();
	data.o_handler.unload();
	var result = parse_result.result;
	if not typeof(result) == TYPE_DICTIONARY:
		fail("Invalid file format");
		return;
	if "ingredients" in result:
		var current = result["ingredients"];
		if not typeof(current) == TYPE_ARRAY:
			return;
		for child in current:
			if data.holder.has_ingredient(child):
				continue;
			data.holder.ingredient_list.add_item(child);
	if "recipes" in result:
		var current = result["recipes"];
		if typeof(current) == TYPE_DICTIONARY:
			load_recipes(current);
	data.o_handler.update_options(data);
	if "loaded" in result:
		var current = result["loaded"];
		if typeof(current) == TYPE_DICTIONARY:
			load_loaded(current);
	data.update();
			
func load_recipes(var recipes : Dictionary):
	for key in recipes.keys():
		if not typeof(key) == TYPE_STRING:
			continue;
		var value = recipes[key];
		if not typeof(value) == TYPE_DICTIONARY:
			continue;
		if data.holder.has_recipe(key):
			continue;
		var recipe = data.create_recipe();
		var created = recipe.NAME;
		recipe.NAME = key;
		data.update_recipe(created, recipe);
		data.holder.recipe_list.set_item_text(data.holder.index_of_recipe(created), key);
		if "result" in value:
			var result = value["result"];
			if typeof(result) == TYPE_DICTIONARY:
				if "item" in result:
					var item = result["item"];
					if typeof(item) == TYPE_STRING:
						recipe.result_item = item;
				if "amount" in result:
					var amount = result["amount"];
					if typeof(amount) == TYPE_REAL:
						recipe.result_amount = int(amount);
						if recipe.result_amount <= 0:
							recipe.result_amount = 1;
		if "ingredients" in value:
			var ingreds = value["ingredients"];
			if not typeof(ingreds) == TYPE_DICTIONARY:
				continue;
			if ingreds.size() == 0:
				continue;
			if not typeof(ingreds.keys()[0]) == TYPE_STRING:
				ingreds = null;
				break;
			for key0 in ingreds.keys():
				var value0 = ingreds[key0];
				if not typeof(value0) == TYPE_REAL:
					ingreds = null;
					break;
				if not data.holder.has_ingredient(key0):
					ingreds = null;
					break;
				if key0 == recipe.result_item:
					ingreds = null;
					break;
				recipe.ingredients.append(key0);
				recipe.amounts.append(int(value0));
			if ingreds == null:
				data.recipes.erase(name);

func load_loaded(var loaded : Dictionary):
	if "ingredient" in loaded:
		var ingredient = loaded["ingredient"];
		if typeof(ingredient) == TYPE_STRING:
			if data.holder.has_ingredient(ingredient):
				var index = data.holder.index_of_ingredient(ingredient);
				data.holder._on_IngredientList_item_selected(index);
				data.holder.ingredient_list.select(index);
	if "recipe" in loaded:
		var recipe = loaded["recipe"];
		if typeof(recipe) == TYPE_STRING:
			if data.holder.has_recipe(recipe):
				var index = data.holder.index_of_recipe(recipe);
				data.holder._on_RecipeList_item_selected(index);
				data.holder.recipe_list.select(index);
	if "output" in loaded:
		var output = loaded["output"];
		if typeof(output) == TYPE_DICTIONARY:
			if "item" in output:
				var item = output["item"];
				if typeof(item) == TYPE_STRING:
					if data.holder.has_ingredient(item):
						data.o_handler.data_name.select(data.holder.index_of_ingredient(item));
			if "amount" in output:
				var amount = output["amount"];
				if typeof(amount) == TYPE_REAL:
					data.o_handler.data_amount.text = str(int(amount));
