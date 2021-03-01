extends Node
class_name GraphLoader

func _on_Graph_select(var node, var graph : GraphEdit):
	graph.set_selected(null);


func _on_Graph_connection_request(from, from_slot, to, to_slot):
	print(from + str(from_slot) + "/" + to + str(to_slot));
