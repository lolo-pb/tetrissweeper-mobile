extends Node2D

#tetromino shapes and their rotations

var i_tetromino: Array = [
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], # 90 degrees
	[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)] # 270 degrees
]

var t_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)] # 270 degrees
]

var o_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # All rotations are the same
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)] # All rotations are the same
]

var z_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)] # 270 degrees
]

var s_tetromino: Array = [
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 90 degrees
	[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)] # 270 degrees
]

var l_tetromino: Array = [
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)], # 180 degrees
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)] # 270 degrees
]

var j_tetromino: Array = [
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # 0 degrees
	[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)], # 90 degrees
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)], # 180 degrees
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)] # 270 degrees
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

# Holding controls
var move_timer: float = 0.0
var move_interval: float = 0.15 # Speed of movement while holding (seconds)
var active_dir: Vector2i = Vector2i.ZERO

var score: int
const CLEAR_REWARD: int = 150
var is_game_running: bool
var first_tetromino_landed: bool = false

var current_tetromino: Array
var next_tetromino: Array
var rotation_index: int = 0
var active_tetromino: Array = []

var tile_id: int = 0
var piece_atlas: Vector2i
var next_piece_atlas: Vector2i

var rng = RandomNumberGenerator.new()

# Hold queue
var held_tetromino: Array = []
var held_piece_atlas: Vector2i
var can_hold: bool = true
const HOLD_PREVIEW_POS: Vector2i = Vector2i(-5, -20)
const NEXT_PREVIEW_POS: Vector2i = Vector2i(5, -20)

# Pause
var is_paused: bool = false

# Highscore
var highscore: int = 0
const SAVE_PATH: String = "user://highscore.cfg"

# Flag mode for touch
var flag_mode: bool = false

# Touch soft drop
var touch_down_held: bool = false

@onready var board: TileMapLayer = $Board
@onready var active: TileMapLayer = $Active
@onready var mines: TileMapLayer = $Mines
@onready var hud: CanvasLayer = $GameHUD
@onready var score_label: Label = $GameHUD/scoreLabel
@onready var main_menu: Control = $GameHUD/MainMenu
@onready var game_over_menu: Control = $GameHUD/GameOverMenu
@onready var final_score_label: Label = $GameHUD/GameOverMenu/Card/FinalScoreLabel
@onready var pause_menu: Control = $GameHUD/PauseMenu
@onready var highscore_label: Label = $GameHUD/HighScoreLabel
@onready var highscore_gameover_label: Label = $GameHUD/GameOverMenu/Card/HighScoreGameOver
@onready var btn_flag: Button = $GameHUD/TouchControls/BtnFlag
@onready var menu_highscore_label: Label = $GameHUD/MainMenu/Card/MenuHighScore

# --- Minesweeper state ---
enum CellState {COVERED, REVEALED, FLAGGED}

# Minesweeper tile atlas coordinates for the Mines TileMapLayer
const MS_COVERED_ATLAS: Vector2i = Vector2i(0, 0)
const MS_FLAG_ATLAS: Vector2i = Vector2i(1, 0)
const MS_BOMB_ATLAS: Vector2i = Vector2i(2, 0)
const MS_BLANK_ATLAS: Vector2i = Vector2i(3, 0)
const MS_BOMB_RED_ATLAS: Vector2i = Vector2i(0, 3)
const MS_BOMB_CROSSED_ATLAS: Vector2i = Vector2i(1, 3)
# Adjacent bomb numbers 1-8:
const MS_NUMBER_ATLAS: Array[Vector2i] = [
	Vector2i(0, 0), # unused index 0
	Vector2i(0, 1), # 1
	Vector2i(1, 1), # 2
	Vector2i(2, 1), # 3
	Vector2i(3, 1), # 4
	Vector2i(0, 2), # 5
	Vector2i(1, 2), # 6
	Vector2i(2, 2), # 7
	Vector2i(3, 2), # 8
]

const BOMBS_PER_PIECE: int = 1

# Key: Vector2i cell position, Value: { "is_bomb": bool, "state": CellState, "adjacent_bombs": int }
var minesweeper_cells: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Menu buttons
	var start_button: Button = hud.get_node("MainMenu/Card/StartButton")
	var retry_button: Button = hud.get_node("GameOverMenu/Card/RetryButton")
	var main_menu_button: Button = hud.get_node("GameOverMenu/Card/MainMenuButton")
	start_button.pressed.connect(_on_start_button_pressed)
	retry_button.pressed.connect(_on_retry_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

	# Pause menu buttons
	var resume_button: Button = hud.get_node("PauseMenu/Card/ResumeButton")
	var pause_mm_button: Button = hud.get_node("PauseMenu/Card/PauseMainMenuButton")
	resume_button.pressed.connect(_on_resume_button_pressed)
	pause_mm_button.pressed.connect(_on_pause_main_menu_pressed)

	# Touch controls
	var tc = hud.get_node("TouchControls")
	tc.get_node("BtnLeft").button_down.connect(_on_btn_left_down)
	tc.get_node("BtnLeft").button_up.connect(_on_btn_left_up)
	tc.get_node("BtnRight").button_down.connect(_on_btn_right_down)
	tc.get_node("BtnRight").button_up.connect(_on_btn_right_up)
	tc.get_node("BtnDown").button_down.connect(_on_btn_down_down)
	tc.get_node("BtnDown").button_up.connect(_on_btn_down_up)
	tc.get_node("BtnRotate").pressed.connect(_on_btn_rotate_pressed)
	tc.get_node("BtnHardDrop").pressed.connect(_on_btn_hard_drop_pressed)
	tc.get_node("BtnHold").pressed.connect(_on_btn_hold_pressed)
	tc.get_node("BtnFlag").pressed.connect(_on_btn_flag_pressed)
	tc.get_node("BtnPause").pressed.connect(_on_btn_pause_pressed)

	load_highscore()
	show_main_menu()


func start_game() -> void:
	rng.randomize()
	score = 0
	is_game_running = true
	is_paused = false
	first_tetromino_landed = false
	tetrominoes = all_tetrominoes.duplicate()
	rotation_index = 0
	fall_timer = 0.0
	fall_interval = 1.0
	move_timer = 0.0
	active_dir = Vector2i.ZERO
	held_tetromino = []
	can_hold = true
	flag_mode = false
	touch_down_held = false
	btn_flag.text = "Reveal"
	minesweeper_cells.clear()
	clear_tetromino()
	clear_board()
	clear_next_tetromino_preview()
	clear_hold_preview()
	score_label.text = "Score: 0"
	highscore_label.text = "Best: " + str(highscore)
	main_menu.visible = false
	game_over_menu.visible = false
	pause_menu.visible = false
	current_tetromino = choose_tetromino()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino), 0)
	next_tetromino = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
	initialize_tetromino()


func show_main_menu() -> void:
	is_game_running = false
	is_paused = false
	first_tetromino_landed = false
	rotation_index = 0
	touch_down_held = false
	clear_tetromino()
	clear_board()
	clear_next_tetromino_preview()
	clear_hold_preview()
	score = 0
	score_label.text = "Score: 0"
	highscore_label.text = "Best: " + str(highscore)
	main_menu.visible = true
	game_over_menu.visible = false
	pause_menu.visible = false
	menu_highscore_label.text = "Best: " + str(highscore)


func show_game_over_menu() -> void:
	is_game_running = false
	touch_down_held = false
	save_highscore()
	final_score_label.text = "Score: " + str(score)
	highscore_gameover_label.text = "Best: " + str(highscore)
	game_over_menu.visible = true


func _on_start_button_pressed() -> void:
	start_game()


func _on_retry_button_pressed() -> void:
	start_game()


func _on_main_menu_button_pressed() -> void:
	show_main_menu()


# --- Pause ---

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	is_paused = true
	touch_down_held = false
	pause_menu.visible = true


func resume_game() -> void:
	is_paused = false
	pause_menu.visible = false


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_pause_main_menu_pressed() -> void:
	resume_game()
	show_main_menu()


# --- Highscore ---

func load_highscore() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		highscore = config.get_value("game", "highscore", 0)


func save_highscore() -> void:
	if score > highscore:
		highscore = score
	var config = ConfigFile.new()
	config.set_value("game", "highscore", highscore)
	config.save(SAVE_PATH)


# --- Hold queue ---

func hold_tetromino() -> void:
	if not can_hold:
		return
	can_hold = false
	clear_tetromino()
	rotation_index = 0
	if held_tetromino.is_empty():
		held_tetromino = current_tetromino
		held_piece_atlas = piece_atlas
		current_tetromino = next_tetromino
		piece_atlas = next_piece_atlas
		next_tetromino = choose_tetromino()
		next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
		clear_next_tetromino_preview()
	else:
		var temp_tetromino = current_tetromino
		var temp_atlas = piece_atlas
		current_tetromino = held_tetromino
		piece_atlas = held_piece_atlas
		held_tetromino = temp_tetromino
		held_piece_atlas = temp_atlas
	initialize_tetromino()
	render_hold_preview()


func render_hold_preview() -> void:
	clear_hold_preview()
	if held_tetromino.is_empty():
		return
	render_tetromino(held_tetromino[0], HOLD_PREVIEW_POS, held_piece_atlas)


func clear_hold_preview() -> void:
	for y in range(4):
		for x in range(4):
			active.erase_cell(HOLD_PREVIEW_POS + Vector2i(x, y))


# --- Hard drop ---

func hard_drop() -> void:
	clear_tetromino()
	while is_valid_move(Vector2i.DOWN):
		current_position += Vector2i.DOWN
	render_tetromino(active_tetromino, current_position, piece_atlas)
	land_tetromino()
	spawn_next_piece()


# --- Speed scaling by score ---

func get_current_fall_interval() -> float:
	var level: int = score / 500
	return max(0.15, 1.0 - level * 0.1)


# --- Tetromino logic ---

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
	render_tetromino(next_tetromino[0], NEXT_PREVIEW_POS, next_piece_atlas)

func render_tetromino(tetromino: Array, pos: Vector2i, atlas: Vector2i) -> void:
	for block in tetromino:
		active.set_cell(pos + block, tile_id, atlas)

func clear_tetromino() -> void:
	for block in active_tetromino:
		active.erase_cell(current_position + block)

func spawn_next_piece() -> void:
	current_tetromino = next_tetromino
	piece_atlas = next_piece_atlas
	next_tetromino = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
	clear_next_tetromino_preview()
	rotation_index = 0
	can_hold = true
	fall_timer = 0.0
	initialize_tetromino()
	is_game_over()
	active_dir = Vector2i.ZERO
	move_timer = 0.0


func _physics_process(delta: float) -> void:
	if is_game_running:
		if Input.is_action_just_pressed("pause"):
			toggle_pause()
			return

		if is_paused:
			return

		if Input.is_action_just_pressed("ui_left"):
			move_tetromino(Vector2i.LEFT)
			active_dir = Vector2i.LEFT
			move_timer = 0.0
		elif Input.is_action_just_pressed("ui_right"):
			move_tetromino(Vector2i.RIGHT)
			active_dir = Vector2i.RIGHT
			move_timer = 0.0

		if Input.is_action_just_released("ui_left") and active_dir == Vector2i.LEFT:
			active_dir = Vector2i.ZERO
		if Input.is_action_just_released("ui_right") and active_dir == Vector2i.RIGHT:
			active_dir = Vector2i.ZERO

		if active_dir != Vector2i.ZERO:
			move_timer += delta
			if move_timer >= move_interval:
				move_tetromino(active_dir)
				move_timer = 0.0

		if Input.is_action_just_pressed("ui_up"):
			rotate_tetromino()

		if Input.is_action_just_pressed("hard_drop"):
			hard_drop()
			return

		if Input.is_action_just_pressed("hold_piece"):
			hold_tetromino()
			return

		var current_fall_interval = get_current_fall_interval()
		if Input.is_action_pressed("ui_down") or touch_down_held:
			current_fall_interval /= fast_fall_multiplier

		fall_timer += delta
		if fall_timer >= current_fall_interval:
			move_tetromino(Vector2i.DOWN)
			fall_timer = 0

		check_rows()


func move_tetromino(dir: Vector2i) -> void:
	if is_valid_move(dir):
		clear_tetromino()
		current_position += dir
		render_tetromino(active_tetromino, current_position, piece_atlas)
	else:
		if dir == Vector2i.DOWN:
			land_tetromino()
			spawn_next_piece()

func land_tetromino() -> void:
	for block in active_tetromino:
		active.erase_cell(current_position + block)
		board.set_cell(current_position + block, tile_id, piece_atlas)
	transform_to_minesweeper(active_tetromino, current_position)
	if not first_tetromino_landed:
		first_tetromino_landed = true
		reveal_all_bottom_edge_hints()


func clear_next_tetromino_preview() -> void:
	for y in range(4):
		for x in range(4):
			active.erase_cell(NEXT_PREVIEW_POS + Vector2i(x, y))

func check_rows() -> void:
	var row: int = ROWS
	while row > 0:
		var cells_filled: int = 0
		for x in range(COLS):
			if not is_within_bounds(Vector2i(x + 1, row)):
				cells_filled += 1
		if cells_filled == COLS and is_minesweeper_row_cleared(row):
			shift_rows(row)
			score += CLEAR_REWARD
			score_label.text = "Score: " + str(score)
		else:
			row -= 1


func is_minesweeper_row_cleared(row: int) -> bool:
	for x in range(1, COLS + 1):
		var cell := Vector2i(x, row)
		if minesweeper_cells.has(cell) and minesweeper_cells[cell]["state"] == CellState.COVERED:
			return false
	return true

func clear_board() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			board.erase_cell(Vector2i(x + 1, y + 1))
			mines.erase_cell(Vector2i(x + 1, y + 1))
	# Clear the hint row below the board
	for x in range(COLS):
		mines.erase_cell(Vector2i(x + 1, ROWS + 1))
	minesweeper_cells.clear()

func shift_rows(start_row: int) -> void:
	var atlas: Vector2i
	var mines_atlas: Vector2i
	for y in range(start_row, 1, -1):
		for x in range(COLS):
			var cell = Vector2i(x + 1, y)
			var above = Vector2i(x + 1, y - 1)
			# Shift board layer
			atlas = board.get_cell_atlas_coords(above)
			if atlas == Vector2i(-1, -1):
				board.erase_cell(cell)
			else:
				board.set_cell(cell, tile_id, atlas)
			# Shift mines layer
			mines_atlas = mines.get_cell_atlas_coords(above)
			if mines_atlas == Vector2i(-1, -1):
				mines.erase_cell(cell)
			else:
				mines.set_cell(cell, tile_id, mines_atlas)
	# Clear the topmost playable row
	for x in range(COLS):
		board.erase_cell(Vector2i(x + 1, 1))
		mines.erase_cell(Vector2i(x + 1, 1))
	# Rebuild minesweeper_cells dictionary after shift
	shift_minesweeper_data(start_row)
	for x in range(1, COLS + 1): # re calcla los numeros de abajo
		render_minesweeper_cell(Vector2i(x, ROWS + 1))

func is_valid_move(dir: Vector2i) -> bool:
	for block in active_tetromino:
		if not is_within_bounds(current_position + block + dir):
			return false
	return true

func is_within_bounds(pos: Vector2i) -> bool:
	if pos.x < 1 or pos.x > COLS or pos.y < 1 or pos.y > ROWS:
		return false

	var title_id_ = board.get_cell_source_id(pos)
	return title_id_ == -1

func is_game_over() -> void:
	for x in active_tetromino:
		if not is_within_bounds(current_position + x):
			land_tetromino()
			show_game_over_menu()
			return

func rotate_tetromino() -> void:
	if is_valid_rotation():
		clear_tetromino()
		rotation_index = (rotation_index + 1) % 4
		active_tetromino = current_tetromino[rotation_index]
		render_tetromino(active_tetromino, current_position, piece_atlas)

func is_valid_rotation() -> bool:
	var next_rotation_index = (rotation_index + 1) % 4
	var next_rotation = current_tetromino[next_rotation_index]

	for block in next_rotation:
		if not is_within_bounds(current_position + block):
			return false
	return true


# --- Touch control handlers ---

func _on_btn_left_down() -> void:
	if not is_game_running or is_paused:
		return
	move_tetromino(Vector2i.LEFT)
	active_dir = Vector2i.LEFT
	move_timer = 0.0


func _on_btn_left_up() -> void:
	if active_dir == Vector2i.LEFT:
		active_dir = Vector2i.ZERO


func _on_btn_right_down() -> void:
	if not is_game_running or is_paused:
		return
	move_tetromino(Vector2i.RIGHT)
	active_dir = Vector2i.RIGHT
	move_timer = 0.0


func _on_btn_right_up() -> void:
	if active_dir == Vector2i.RIGHT:
		active_dir = Vector2i.ZERO


func _on_btn_down_down() -> void:
	touch_down_held = true


func _on_btn_down_up() -> void:
	touch_down_held = false


func _on_btn_rotate_pressed() -> void:
	if not is_game_running or is_paused:
		return
	rotate_tetromino()


func _on_btn_hard_drop_pressed() -> void:
	if not is_game_running or is_paused:
		return
	hard_drop()


func _on_btn_hold_pressed() -> void:
	if not is_game_running or is_paused:
		return
	hold_tetromino()


func _on_btn_flag_pressed() -> void:
	flag_mode = !flag_mode
	btn_flag.text = "Flag" if flag_mode else "Reveal"


func _on_btn_pause_pressed() -> void:
	if is_game_running:
		toggle_pause()


# --- Minesweeper functions ---

func transform_to_minesweeper(tetromino_blocks: Array, pos: Vector2i) -> void:
	var absolute_cells: Array[Vector2i] = []
	for block in tetromino_blocks:
		absolute_cells.append(pos + block)

	place_bombs(absolute_cells)
	update_adjacent_bombs(absolute_cells)

	for cell in absolute_cells:
		mines.set_cell(cell, tile_id, MS_COVERED_ATLAS)


func reveal_all_bottom_edge_hints() -> void:
	for i in range(1, COLS + 1):
		var hint_cell := Vector2i(i, ROWS + 1)
		if not minesweeper_cells.has(hint_cell):
			minesweeper_cells[hint_cell] = {
				"is_bomb": false,
				"state": CellState.COVERED,
				"adjacent_bombs": 0
			}
		# Count bombs among this hint cell's neighbors
		var count: int = 0
		for neighbor in get_neighbors(hint_cell):
			if minesweeper_cells.has(neighbor) and minesweeper_cells[neighbor]["is_bomb"]:
				count += 1
		minesweeper_cells[hint_cell]["adjacent_bombs"] = count
		# Directly reveal without flood-fill (avoids cascading into covered board cells)
		minesweeper_cells[hint_cell]["state"] = CellState.REVEALED
		if count > 0:
			mines.set_cell(hint_cell, tile_id, MS_NUMBER_ATLAS[count])
		else:
			mines.set_cell(hint_cell, tile_id, MS_BLANK_ATLAS)

func place_bombs(cells: Array[Vector2i]) -> void:
	var bomb_count: int = mini(BOMBS_PER_PIECE, cells.size())
	var indices: Array = range(cells.size())
	# Fisher-Yates partial shuffle for bomb selection
	for i in range(bomb_count):
		var j: int = rng.randi_range(i, indices.size() - 1)
		var tmp = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp

	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		minesweeper_cells[cell] = {
			"is_bomb": i < bomb_count,
			"state": CellState.COVERED,
			"adjacent_bombs": 0
		}


func update_adjacent_bombs(new_cells: Array[Vector2i]) -> void:
	# Collect all cells needing an adjacency recount: the new cells + existing neighbors
	var cells_to_update: Dictionary = {}
	for cell in new_cells:
		cells_to_update[cell] = true
		for neighbor in get_neighbors(cell):
			if minesweeper_cells.has(neighbor):
				cells_to_update[neighbor] = true

	for cell in cells_to_update:
		if not minesweeper_cells.has(cell):
			continue
		if minesweeper_cells[cell]["is_bomb"]:
			continue
		var count: int = 0
		for neighbor in get_neighbors(cell):
			if minesweeper_cells.has(neighbor) and minesweeper_cells[neighbor]["is_bomb"]:
				count += 1
		minesweeper_cells[cell]["adjacent_bombs"] = count
		if minesweeper_cells[cell]["state"] == CellState.REVEALED:
			render_minesweeper_cell(cell)


func recalculate_all_adjacent_bombs() -> void:
	for cell in minesweeper_cells:
		if minesweeper_cells[cell]["is_bomb"]:
			continue
		var count: int = 0
		for neighbor in get_neighbors(cell):
			if minesweeper_cells.has(neighbor) and minesweeper_cells[neighbor]["is_bomb"]:
				count += 1
		minesweeper_cells[cell]["adjacent_bombs"] = count


func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [
		cell + Vector2i(-1, -1), cell + Vector2i(0, -1), cell + Vector2i(1, -1),
		cell + Vector2i(-1, 0), cell + Vector2i(1, 0),
		cell + Vector2i(-1, 1), cell + Vector2i(0, 1), cell + Vector2i(1, 1)
	]


func reveal_cell(cell: Vector2i) -> void:
	if not minesweeper_cells.has(cell):
		return
	if minesweeper_cells[cell]["state"] != CellState.COVERED:
		return

	minesweeper_cells[cell]["state"] = CellState.REVEALED

	if minesweeper_cells[cell]["is_bomb"]:
		mines.set_cell(cell, tile_id, MS_BOMB_RED_ATLAS)
		show_game_over_menu()

	else:
		var adj: int = minesweeper_cells[cell]["adjacent_bombs"]
		if adj > 0:
			mines.set_cell(cell, tile_id, MS_NUMBER_ATLAS[adj])
		else:
			mines.set_cell(cell, tile_id, MS_BLANK_ATLAS)
			# Flood-fill reveal neighboring cells with 0 adjacent bombs
			for neighbor in get_neighbors(cell):
				reveal_cell(neighbor)


func flag_cell(cell: Vector2i) -> void:
	if not minesweeper_cells.has(cell):
		return

	if minesweeper_cells[cell]["state"] == CellState.COVERED:
		minesweeper_cells[cell]["state"] = CellState.FLAGGED
		mines.set_cell(cell, tile_id, MS_FLAG_ATLAS)
	elif minesweeper_cells[cell]["state"] == CellState.FLAGGED:
		minesweeper_cells[cell]["state"] = CellState.COVERED
		mines.set_cell(cell, tile_id, MS_COVERED_ATLAS)


func render_minesweeper_cell(cell: Vector2i) -> void:
	if not minesweeper_cells.has(cell):
		mines.erase_cell(cell)
		return
	var data: Dictionary = minesweeper_cells[cell]
	match data["state"]:
		CellState.COVERED:
			mines.set_cell(cell, tile_id, MS_COVERED_ATLAS)
		CellState.FLAGGED:
			mines.set_cell(cell, tile_id, MS_FLAG_ATLAS)
		CellState.REVEALED:
			if data["is_bomb"]:
				mines.set_cell(cell, tile_id, MS_BOMB_RED_ATLAS)
			elif data["adjacent_bombs"] > 0:
				mines.set_cell(cell, tile_id, MS_NUMBER_ATLAS[data["adjacent_bombs"]])
			else:
				mines.set_cell(cell, tile_id, MS_BLANK_ATLAS)


func shift_minesweeper_data(cleared_row: int) -> void:
	var new_cells: Dictionary = {}
	for cell in minesweeper_cells:
		if cell.y == cleared_row:
			continue # row was cleared, discard
		elif cell.y < cleared_row:
			new_cells[Vector2i(cell.x, cell.y + 1)] = minesweeper_cells[cell]
		else:
			new_cells[cell] = minesweeper_cells[cell]
	minesweeper_cells = new_cells
	recalculate_all_adjacent_bombs()


func get_cell_from_mouse() -> Vector2i:
	var local_pos: Vector2 = mines.get_local_mouse_position()
	return mines.local_to_map(local_pos)


func _input(event: InputEvent) -> void:
	if not is_game_running or is_paused:
		return
	if event.is_action_pressed("reveal"):
		var cell: Vector2i = get_cell_from_mouse()
		if flag_mode:
			flag_cell(cell)
		else:
			reveal_cell(cell)
	elif event.is_action_pressed("flag"):
		var cell: Vector2i = get_cell_from_mouse()
		flag_cell(cell)
