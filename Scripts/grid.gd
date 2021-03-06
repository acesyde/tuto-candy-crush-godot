extends Node2D

# Grid variables
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var y_offset

# The piece array
var possible_pieces: Array = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/light_green_piece.tscn"),
	preload("res://Scenes/orange_piece.tscn"),
	preload("res://Scenes/pink_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

# The current pieces in the scene
var all_pieces: Array = []

# Swap back variables
var piece_one: piece = null
var piece_two: piece = null
var last_place: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var move_checked: bool = false

# Touch variables
var first_touch: Vector2 = Vector2.ZERO
var final_touch: Vector2 = Vector2.ZERO
var controlling: bool = false
var state

# States
enum {
	WAIT,
	MOVE
}

func _ready():
	randomize()
	state = MOVE
	all_pieces = make_2d_array()
	spawn_pieces()

func make_2d_array() -> Array:
	var array = []
	
	for y in width:
		array.append([])
		for x in height:
			array[y].append(null)
	
	return array

func spawn_pieces() -> void:
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

func match_at(y:int, x: int, color: String) -> bool:
	if y > 1:
		if all_pieces[y - 1][x] != null && all_pieces[y - 2][x] != null:
			if all_pieces[y - 1][x].color == color && all_pieces[y - 2][x].color == color:
				return true
	if x > 1:
		if all_pieces[y][x - 1] != null && all_pieces[y][x - 2] != null:
			if all_pieces[y][x - 1].color == color && all_pieces[y][x - 2].color == color:
				return true
	
	return false

func grid_to_pixel(column: int, row: int) -> Vector2:
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(x: float, y: float) -> Vector2:
	var new_x = round((x - x_start) / offset)
	var new_y = round((y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position: Vector2) -> bool:
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false

func touch_input() -> void:
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = false
			touch_difference(first_touch, final_touch)

func swap_pieces(column:int, row:int, direction: Vector2) -> void:
	var first_piece: piece = all_pieces[column][row]
	var other_piece: piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		store_info(first_piece, other_piece,Vector2(column, row),direction)
		state = WAIT
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		if move_checked == false:
			find_matches()

func store_info(first_piece: piece, other_piece: piece, place: Vector2, direction: Vector2) -> void:
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	pass

func swap_back() -> void:
	# Move the previously swapped pieces back to the previous place
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = MOVE
	move_checked = false
	pass

func touch_difference(grid_one: Vector2, grid_two: Vector2) -> void:
	var difference: Vector2 = grid_two - grid_one
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_one.x, grid_one.y, Vector2.RIGHT)
		elif difference.x < 0:
			swap_pieces(grid_one.x, grid_one.y, Vector2.LEFT)
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_one.x, grid_one.y, Vector2.DOWN)
		elif difference.y < 0:
			swap_pieces(grid_one.x, grid_one.y, Vector2.UP)

func _process(delta: float):
	if state == MOVE:
		touch_input()

func find_matches() -> void:
	for y in width:
		for x in height:
			if all_pieces[y][x] != null:
				var current_color = all_pieces[y][x].color
				if y > 0 && y < width - 1:
					if all_pieces[y-1][x] != null && all_pieces[y+1][x] != null:
						if all_pieces[y-1][x].color == current_color && all_pieces[y+1][x].color == current_color:
							all_pieces[y-1][x].matched = true
							all_pieces[y-1][x].dim()
							all_pieces[y][x].matched = true
							all_pieces[y][x].dim()
							all_pieces[y+1][x].matched = true
							all_pieces[y+1][x].dim()
				if x > 0 && x < height - 1:
					if all_pieces[y][x-1] != null && all_pieces[y][x+1] != null:
						if all_pieces[y][x-1].color == current_color && all_pieces[y][x+1].color == current_color:
							all_pieces[y][x-1].matched = true
							all_pieces[y][x-1].dim()
							all_pieces[y][x].matched = true
							all_pieces[y][x].dim()
							all_pieces[y][x+1].matched = true
							all_pieces[y][x+1].dim()
	get_parent().get_node("destroy_timer").start()

func destroy_matched():
	var was_matched = false
	for y in width:
		for x in height:
			if all_pieces[y][x] != null:
				if all_pieces[y][x].matched == true:
					was_matched = true
					all_pieces[y][x].queue_free()
					all_pieces[y][x] = null
	
	move_checked = true
	
	if was_matched == true:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()

func collapse_columns() -> void:
	for y in width:
		for x in height:
			if all_pieces[y][x] == null:
				for k in range(x + 1, height):
					if all_pieces[y][k] != null:
						all_pieces[y][k].move(grid_to_pixel(y, x))
						all_pieces[y][x] = all_pieces[y][k]
						all_pieces[y][k] = null
						break
	get_parent().get_node("refill_timer").start()

func refill_columns() -> void:
	for y in width:
		for x in height:
			if all_pieces[y][x] == null:
				# choose a random number and store it
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0
				
				while match_at(y,x, piece.color) && loops < 100:
					rand = floor(rand_range(0, possible_pieces.size()))
					piece = possible_pieces[rand].instance()
					loops += 1
				
				add_child(piece)
				piece.position = grid_to_pixel(y,x-y_offset)
				piece.move(grid_to_pixel(y,x))
				all_pieces[y][x] = piece
	after_refill()

func after_refill() -> void:
	for y in width:
		for x in height:
			if all_pieces[y][x] != null:
				if match_at(y,x, all_pieces[y][x].color):
					find_matches()
					get_parent().get_node("destroy_timer").start()
					return
	state = MOVE
	move_checked = false

func _on_destroy_timer_timeout() -> void:
	destroy_matched()

func _on_collapse_timer_timeout() -> void:
	collapse_columns()

func _on_refill_timer_timeout() -> void:
	refill_columns()
