extends Node

var data : DataNode

func _ready():
	data = get_node('/root/Control/Scripts/DataNode');

func _on_AddIngredient_pressed():
	var name = data.create_ingredient();
	data.holder.ingredient_list.select(data.holder.ingredient_list.get_item_count() - 1);
	data.load_ingredient(name);
	data.r_handler.update_options(data);
	data.o_handler.update_options(data);

func _on_AddRecipe_pressed():
	if data.holder.ingredient_list.get_item_count() == 0:
		return;
	var recipe = data.create_recipe();
	data.holder.recipe_list.select(data.holder.recipe_list.get_item_count() - 1);
	data.load_recipe(recipe.NAME);

func _on_IngredientSave_pressed():
	data.i_handler.save(data);

func _on_RecipeSave_pressed():
	data.r_handler.save(data);

func _on_Calculate_pressed():
	data.o_handler.calculate(data);
