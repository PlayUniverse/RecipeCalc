extends Node
class_name DataNode

const BASE : String = "New Recipe ";

var current_ingredient : String;
var current_recipe_name : String;

var recipes : Dictionary = {};

var holder;

var i_handler;
var r_handler;
var o_handler;

func _ready():
	i_handler = get_node('/root/Control/Scripts/IngredientHandler');
	r_handler = get_node('/root/Control/Scripts/RecipeHandler');
	o_handler = get_node('/root/Control/Scripts/OutputHandler');

func set_list_holder(var list_holder):
	holder = list_holder;
	
func unload_ingredient():
	current_ingredient = "";
	i_handler.unload();
	
func load_ingredient(var name : String):
	current_ingredient = name;
	i_handler.load_data(name);

func unload_recipe():
	current_recipe_name = "";
	r_handler.unload()
	
func load_recipe(var name : String):
	current_recipe_name = name;
	r_handler.load_data(get_recipe(name), self);
	
func get_recipe(var name : String) -> Recipe:
	return recipes.get(name);

func update_recipe(var name : String, var recipe : Recipe):
	if not recipes.erase(name):
		return;
	recipes[recipe.NAME] = recipe;
	
func update_recipes(var old : String, var new : String):
	var size : int = recipes.size();
	var index : int = 0;
	var keys : Array = recipes.keys();
	while index < size:
		var recipe = recipes.get(keys[index]);
		recipe.update(old, new);
		recipes[keys[index]] = recipe;
		index = index + 1;

func create_recipe() -> Recipe:
	var recipe = Recipe.new(generate_recipe_name());
	recipes[recipe.NAME] = recipe;
	holder.recipe_list.add_item(recipe.NAME);
	return recipe;

func create_ingredient() -> String:
	var name = generate_ingredient_name();
	holder.ingredient_list.add_item(name);
	return name;
	
func generate_recipe_name() -> String:
	var name = "New Recipe";
	var index = 0;
	while holder.has_recipe(name):
		name = "New Recipe " + str(index);
		index = index + 1;
	return name;
	
func generate_ingredient_name() -> String:
	var name = "New Ingredient";
	var index = 0;
	while holder.has_ingredient(name):
		name = "New Ingredient " + str(index);
		index = index + 1;
	return name;
	
func update():
	holder.update(self);
	i_handler.update(self);
	r_handler.update(self);
	o_handler.update(self);
	internal_update();
	
func internal_update():
	var remove = [];
	for key in recipes.keys():
		var recipe = recipes.get(key);
		if recipe.ingredients.size() == 0:
			continue;
		for ingredient in recipe.ingredients:
			if not holder.has_ingredient(ingredient):
				remove.append(key);
				break;
	var _ignore;
	for item in remove:
		_ignore = recipes.erase(item);
