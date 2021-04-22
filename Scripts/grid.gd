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

func make_2d_array() -> Array:
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
			var piece = possible_pieces[rand].instance()
			var loops = 0
			
			while match_at(y,x, piece.color) && loops < 100:
				rand = floor(rand_range(0, possible_pieces.size()))
				piece = possible_pieces[rand].instance()
				loops += 1
			
			add_child(piece)
			piece.position = grid_to_pixel(y,x)
			all_pieces[y][x] = piece

func match_at(y:int, x: int, color: String):
	if y > 1:
		if all_pieces[y - 1][x] != null && all_pieces[y - 2][x] != null:
			if all_pieces[y - 1][x].color == color && all_pieces[y - 2][x].color == color:
				return true
	if x > 1:
		if all_pieces[y][x - 1] != null && all_pieces[y][x - 2] != null:
			if all_pieces[y][x - 1].color == color && all_pieces[y][x - 2].color == color:
				return true

func grid_to_pixel(column: int, row: int) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)
