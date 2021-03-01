class_name GraphSorting

static func sort_graph(var graph : GraphEdit):
	var map = {}
	var children = graph.get_children();
	for child in children:
		var degree : int = find_degree(child, graph, children);
		if not map.has(degree):
			 map[degree] = [];
		map[degree].append(child);
		
static func find_degree(var node : GraphNode, var graph : GraphEdit, var children : Array) -> int:
	var degree : int = 0;
	for child in children:
		if graph.is_node_connected(node.name, 0, child.name, 0):
			degree += 1;
	return degree;
