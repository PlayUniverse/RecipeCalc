extends Node

var add : SplitContainer;
var view : SplitContainer;

func _ready():
	add = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Items/Container/Add');
	view = get_node('/root/Control/Panel/Split/Panel/Tab/Calculator/Items/Container/View');



func _on_Add_dragged(offset):
	view.split_offset = offset;


func _on_View_dragged(offset):
	add.split_offset = offset;
