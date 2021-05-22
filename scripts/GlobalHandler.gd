extends Node

export var min_size : Vector2;
export var node_path : String;

var root_node : Control;

var window_size : Vector2;
var window_position : Vector2;

var mesh2d : MeshInstance2D;

func _ready():
	root_node = get_node('/root/Control/' + node_path);
	window_size = OS.get_window_size();
	window_position = OS.get_window_position();
	update_root(min_size);

func _physics_process(_delta):
	if OS.get_window_size() != window_size:
		window_size = OS.get_window_size();
		if window_size.x < min_size.x || window_size.y < min_size.y:
			if window_size.x < min_size.x:
				window_size.x = min_size.x;
			if window_size.y < min_size.y:
				window_size.y = min_size.y;
			OS.set_window_size(window_size);
			OS.set_window_position(window_position);
		update_root(window_size);
	if OS.get_window_position() != window_position:
		window_position = OS.get_window_position();

func update_root(size : Vector2):
	if not root_node:
		return;
	root_node.set_size(size);
	root_node.update();
