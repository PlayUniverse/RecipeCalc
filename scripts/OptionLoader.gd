extends Node

var data : DataNode

func _ready():
	data = get_node('/root/Control/Scripts/DataNode');

func _on_IngredientOptions_id_pressed(var id):
	data.r_handler.handle_ingredient(id, data);

func _on_Result_item_selected(index):
	data.r_handler.update_result(index, data);
