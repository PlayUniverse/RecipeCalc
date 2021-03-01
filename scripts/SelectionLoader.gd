extends ListHolder

var data : DataNode

func _ready():
	data = get_node('/root/Control/Scripts/DataNode');
	data.set_list_holder(self);

func _on_IngredientList_item_selected(index):
	data.unload_ingredient();
	data.load_ingredient(ingredient_list.get_item_text(index));


func _on_IngredientList_item_rmb_selected(index, _at_position):
	var value : String = ingredient_list.get_item_text(index);
	ingredient_list.remove_item(index);
	if data.current_ingredient == value:
		data.unload_ingredient();
	data.update();
	data.r_handler.update_options(data);
	data.o_handler.update_options(data);


func _on_RecipeList_item_selected(index):
	data.unload_recipe();
	data.load_recipe(recipe_list.get_item_text(index));


func _on_RecipeList_item_rmb_selected(index, _at_position):
	var value : String = recipe_list.get_item_text(index);
	recipe_list.remove_item(index);
	if(data.current_recipe_name == value):
		data.unload_recipe();
	data.update();

func _on_RecipeIngredients_item_selected(index):
	data.r_handler.handle_increase(index, data);
	data.r_handler.data_list.unselect_all();

func _on_RecipeIngredients_item_rmb_selected(index, _at_position):
	data.r_handler.handle_decrease(index, data);
	data.r_handler.data_list.unselect_all();

func _on_RecipeAmounts_item_selected(index):
	data.r_handler.amount_list.unselect_all();

func _on_RecipeAmounts_item_rmb_selected(index, _at_position):
	data.r_handler.amount_list.unselect_all();
