extends Node

var iscroll : VScrollBar;
var ascroll : VScrollBar;

func _ready():
	var data : DataNode = get_node('/root/Control/Scripts/DataNode');
	iscroll = data.r_handler.data_list.get_v_scroll();
	ascroll = data.r_handler.amount_list.get_v_scroll();
	var _ignore;
	_ignore = iscroll.connect('value_changed', self, "_on_Ingredients_scroll");
	_ignore = ascroll.connect('value_changed', self, "_on_Amounts_scroll");

func _on_Ingredients_scroll(var value : float):
	ascroll.set_value(value);

func _on_Amounts_scroll(var value : float):
	iscroll.set_value(value);
	
