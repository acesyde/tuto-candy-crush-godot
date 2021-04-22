extends Node2D

# Grid variables
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset

var possible_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/light_green_piece.tscn"),
	preload("res://Scenes/orange_piece.tscn"),
	preload("res://Scenes/pink_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

var all_pieces = []

func _ready():
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()

func make_2d_array():
	var array = []
	
	for y in width:
		array.append([])
		for x in height:
			array[y].append(null)
	
	return array

func spawn_pieces():
	for y in width:
		for x in height:
			# choose a random number and store it
			var rand = floor(rand_range(0, possible_pieces.size()))
			# Instance that piece from the array
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(y,x)
			
func grid_to_pixel(column: int, row: int):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)
