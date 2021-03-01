class ListHelper:
	
	static func has(var list : ItemList, var item : String) -> bool:
		var size : int = list.get_item_count()
		var index : int = 0
		while index < size:
			if list.get_item_text(index) == item:
				return true;
			index = index + 1;
		return false;
		
	static func find(var list : ItemList, var item : String) -> int:
		var size : int = list.get_item_count()
		var index : int = 0
		while index < size:
			if list.get_item_text(index) == item:
				return index;
			index = index + 1;
		return -1;

class PopupHelper:
	
	static func create(var template : WindowDialog) -> WindowDialog:
		var output : WindowDialog = WindowDialog.new();
		output.name = template.name;
		clone_children(output, template);
		return output;
		
	static func clone_children(var root : Node, var node : Node):
		for child in node.get_children():
			var current : Node = ClassDB.instance(child.get_class());
			current.name = child.name;
			clone_children(current, child);
			root.add_child(current);
			
class NodeHelper:

	static func create(var name : String, var ingredient_dict : Dictionary) -> GNode:
		var item_node : Dictionary = {} # {name:node}
		var output : Array = create_cache(name, item_node, ingredient_dict, 0);
		item_node.clear();
		output[1].clear();
		return output[0];
		
	static func create_cache(var name : String, var items : Dictionary, var dict : Dictionary, var id : int) -> Array:
		if items.has(name):
			return [items.get(name), items];
		var node = INode.new(name);
		node.id = id;
		items[name] = node;
		if not dict.has(name):
			return [node, items];
		var recipe : Recipe = dict[name];
		var rnode = RNode.new(recipe.NAME, node, recipe.result_amount);
		rnode.id = id + 1;
		var size : int = recipe.ingredients.size();
		var index : int = 0;
		var rid : int = rnode.id + 1;
		while index < size:
			var iname = recipe.ingredients[index];
			var inode = create_cache(iname, items, dict, rid);
			rnode.iadd(inode[0], recipe.amounts[index]);
			items = inode[1];
			index += 1;
		return [node, items];
