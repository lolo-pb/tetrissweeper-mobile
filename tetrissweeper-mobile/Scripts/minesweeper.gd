extends Node2D

#tetromino shapes and their rotations

var i_tetromino: Array = [
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], # 90 degrees
	[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]  # 270 degrees
]
 
var t_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var o_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]  # All rotations are the same
]
 
var z_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]  # 270 degrees
]
 
var s_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 90 degrees
	[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var l_tetromino: Array = [
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]  # 270 degrees
]
 
var j_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]  # 270 degrees
]

var tetrominoes: Array = [i_tetromino, t_tetromino, o_tetromino, z_tetromino, s_tetromino, l_tetromino, j_tetromino]
var all_tetrominoes: Array = tetrominoes.duplicate() 

const COLS: int = 10
const ROWS: int = 20

const START_POSITION: Vector2i = Vector2i(5, 1)
var current_position: Vector2i

const movement_direction: Array[Vector2i] = [Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
var fall_timer: float = 0.0
var fall_interval: float = 1.0
const fast_fall_multiplier: float = 10.0

var score: int
const CLEAR_REWARD: int = 150
var is_game_running: bool

var current_tetromino: Array
var next_tetromino: Array
var rotation_index: int = 0
var active_tetromino: Array = []

var tile_id: int = 0
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

@onready var board: TileMapLayer = $Board
@onready var active: TileMapLayer = $Active 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()


func start_game() -> void:
	score = 0
	$GameHUD/gameOverLabel.visible = false
	is_game_running = true
	clear_tetromino()
	clear_board()
	clear_next_tetromino_preview()
	current_tetromino = choose_tetromino()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino), 0)
	next_tetromino = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
	initialize_tetromino()

func choose_tetromino() -> Array:
	var selected_tetromino: Array
	if not tetrominoes.is_empty():
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	else:
		tetrominoes = all_tetrominoes.duplicate()
		tetrominoes.shuffle()
		selected_tetromino = tetrominoes.pop_front()
	return selected_tetromino

func initialize_tetromino() -> void:
	current_position = START_POSITION
	active_tetromino = current_tetromino[rotation_index]
	render_tetromino(active_tetromino, current_position, piece_atlas)
	render_tetromino(next_tetromino[0], Vector2i(5, -20), next_piece_atlas)

func render_tetromino(tetromino: Array, pos: Vector2i, atlas: Vector2i) -> void:
	for block in tetromino:
		active.set_cell(pos + block, tile_id, atlas) 

func clear_tetromino() -> void:
	for block in active_tetromino:
		active.erase_cell(current_position + block) 


func _physics_process(delta: float) -> void:
	if is_game_running:
		var move_direction = Vector2i.ZERO

		if Input.is_action_just_pressed("ui_left"):
			move_direction = Vector2i.LEFT
		elif Input.is_action_just_pressed("ui_down"):
			move_direction = Vector2i.DOWN
		elif Input.is_action_just_pressed("ui_right"):
			move_direction = Vector2i.RIGHT

		
		if move_direction != Vector2i.ZERO:
			move_tetromino(move_direction)

		if Input.is_action_just_pressed("ui_up"):
			rotate_tetromino()

		var current_fall_interval = fall_interval
		if Input.is_action_pressed("ui_down"):
			current_fall_interval /= fast_fall_multiplier

		fall_timer += delta
		if fall_timer >= current_fall_interval:
			move_tetromino(Vector2i.DOWN)
			fall_timer = 0


func move_tetromino(dir: Vector2i) -> void:
	if is_valid_move(dir):
		clear_tetromino()# H
		current_position += dir
		render_tetromino(active_tetromino, current_position, piece_atlas)
	else:
		if dir == Vector2i.DOWN:
			land_tetromino()
			check_rows()
			current_tetromino = next_tetromino
			piece_atlas = next_piece_atlas
			next_tetromino = choose_tetromino()
			next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
			clear_next_tetromino_preview()
			initialize_tetromino()
			is_game_over()

func land_tetromino() -> void:
	for block in active_tetromino:
		active.erase_cell(current_position + block)
		board.set_cell(current_position + block, tile_id, piece_atlas)

func clear_next_tetromino_preview() -> void: #cuidado con esto, el borrado es absoluto, no relativo
	for y in range(4):
		for x in range(4):
			active.erase_cell(Vector2i(5, -20) + Vector2i(x, y))

func check_rows() -> void:
	var row: int = ROWS
	while  row > 0:
		var cells_filled: int = 0
		for x in range(COLS):
			if not is_within_bounds(Vector2i(x + 1, row)):
				cells_filled += 1  
		if cells_filled == COLS:
			shift_rows(row)
			score += CLEAR_REWARD
			$GameHUD/scoreLabel.text = "Score: " + str(score)	
		else:
			row -= 1

func clear_board() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			board.erase_cell(Vector2i(x + 1, y + 1))

func shift_rows(start_row: int) -> void:
	var atlas: Vector2i
	for y in range(start_row, 1, -1):
		for x in range(COLS):
			atlas = board.get_cell_atlas_coords(Vector2i(x + 1, y - 1))
			if atlas == Vector2i(-1, -1):
				board.erase_cell(Vector2i(x + 1, y))
			else:
				board.set_cell(Vector2i(x + 1, y), tile_id, atlas)
	# Clear the topmost playable row (don't copy border tiles from row 0)
	for x in range(COLS):
		board.erase_cell(Vector2i(x + 1, 1))

func is_valid_move(dir: Vector2i) -> bool:
	for block in active_tetromino:
		if not is_within_bounds(current_position + block + dir):
			return false
	return true

func is_within_bounds(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= COLS + 1 or pos.y < 0 or pos.y >= ROWS + 1:	
		return false

	var tile_id = board.get_cell_source_id(pos)
	return tile_id == -1

func is_game_over() -> void:
	for x in active_tetromino:
		if not is_within_bounds(current_position + x):
			land_tetromino()
			$GameHUD/gameOverLabel.visible = true
			is_game_running = false

func rotate_tetromino() -> void:
	if is_valid_rotation():
		clear_tetromino()
		rotation_index = (rotation_index - 1) % 4
		active_tetromino = current_tetromino[rotation_index]
		render_tetromino(active_tetromino, current_position, piece_atlas)

func is_valid_rotation() -> bool:
	var next_rotation_index = (rotation_index + 1) % 4
	var next_rotation = current_tetromino[next_rotation_index]

	for block in next_rotation:
		if not is_within_bounds(current_position + block):
			return false
	return true