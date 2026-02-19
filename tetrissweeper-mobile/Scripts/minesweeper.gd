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

var current_tetromino: Array
var next_tetromino: Array
var rotation_index: int = 0
var active_tetromino: Array = []

var title_id: int = 0
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

@onready var board: TileMapLayer  = $Board
@onready var active: TileMapLayer = $Active 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()


func start_game() -> void:
	current_tetromino = choose_tetronimo()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino), 0)
	initialize_tetronimo()

func choose_tetronimo() -> Array:
	var selected_tetronimo: Array
	if not tetrominoes.is_empty():
		tetrominoes.shuffle()
		selected_tetronimo = tetrominoes.pop_front()
	else:
		tetrominoes = all_tetrominoes.duplicate()
		tetrominoes.shuffle()
		selected_tetronimo = tetrominoes.pop_front()
	return selected_tetronimo

func initialize_tetronimo() -> void:
	current_position = START_POSITION
	active_tetromino = current_tetromino[rotation_index]
	render_tetromino(active_tetromino, current_position, piece_atlas)

func render_tetromino(tetronimo: Array, position: Vector2i, atlas: Vector2i) -> void:
	for block in tetronimo:
		board.set_cell(position + block, title_id, atlas) 

func unrender_tetromino(tetronimo: Array, position: Vector2i) -> void:
	for block in tetronimo:
		board.set_cell(position + block, -1) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
var fall_time: float = 0.5 # Piece falls every 0.5 seconds
var fall_timer: float = 0

func _process(delta: float) -> void:
	fall_timer += delta
	if fall_timer >= fall_time:
		unrender_tetromino(active_tetromino, current_position)
		
		current_position += Vector2i(0,1) # this is the falling
		
		render_tetromino(active_tetromino, current_position, piece_atlas)
		fall_timer = 0 # Reset the timer
