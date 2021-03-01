extends Node
class_name ListHolder

const Helper = preload("res://scripts/Helper.gd");

var ingredient_list : ItemList;
var recipe_list : ItemList;

func _ready():
	ingredient_list = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Items/Container/View/IngredientSplit/IngredientList');
	recipe_list = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Items/Container/View/RecipeSplit/RecipeList');

func has_recipe(var name : String) -> bool:
	return Helper.ListHelper.has(recipe_list, name);
	
func has_ingredient(var name : String) -> bool:
	return Helper.ListHelper.has(ingredient_list, name);
	
func index_of_recipe(var name : String) -> int:
	return Helper.ListHelper.find(recipe_list, name);
	
func index_of_ingredient(var name : String) -> int:
	return Helper.ListHelper.find(ingredient_list, name);
	
func update(var data : DataNode):
	var index : int = 0
	var size : int = recipe_list.get_item_count()
	while index < size:
		var item : String = recipe_list.get_item_text(index);
		var recipe : Recipe = data.get_recipe(item);
		for ingredient in recipe.ingredients:
			if not has_ingredient(ingredient):
				recipe_list.remove_item(index);
				size = size - 1;
				index = index - 1;
				break;
		index = index + 1;
