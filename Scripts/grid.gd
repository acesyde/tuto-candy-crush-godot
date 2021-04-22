extends Node2D

# Grid variables
export (int) var width;
export (int) var height;
export (int) var x_start;
export (int) var y_start;
export (int) var offset;

var all_pieces = [];

func _ready():
	all_pieces = make_2d_array()
	print(all_pieces)

func make_2d_array():
	var array = []
	
	for y in width:
		array.append([])
		for x in height:
			array[y].append(null)
	
	return array
