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
const fast_fall_multiplier: float = 10.0

# Holding controls
var move_timer: float = 0.0
var move_interval: float = 0.15 # Speed of movement while holding (seconds)
var active_dir: Vector2i = Vector2i.ZERO

var score: int
var lines_cleared: int = 0
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
const HOLD_PREVIEW_POS: Vector2i = Vector2i(-6, -8)
const NEXT_PREVIEW_POS: Vector2i = Vector2i(3, -8)

# Pause
var is_paused: bool = false

# Highscore
var highscore: int = 0
const SAVE_PATH: String = "user://highscore.cfg"

# D-pad textures
var dpad_tex_unpressed: Texture2D = preload("res://res/dpad_button_unpressed.png")
var dpad_tex_pressed: Texture2D = preload("res://res/dpad_button_pressed.png")

# Touch soft drop
var touch_down_held: bool = false
const TOUCH_HOLD_THRESHOLD_MS: int = 350
const TOUCH_MOVE_TOLERANCE: float = 18.0
var active_board_touch_id: int = -1
var active_board_touch_pos: Vector2 = Vector2.ZERO
var active_board_touch_cell: Vector2i = Vector2i.ZERO
var active_board_touch_start_ms: int = 0
var board_touch_hold_triggered: bool = false

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
@onready var menu_highscore_label: Label = $GameHUD/MainMenu/Card/MenuHighScore
@onready var touch_controls: Control = $GameHUD/TouchControls

# --- Minesweeper state ---
enum CellState {COVERED, REVEALED, FLAGGED}

# Minesweeper tile atlas coordinates for the Mines TileMapLayer
# space_tiles_spritesheet.png layout: 8 cols (tetromino type 0-6, col 7 unused) × 12 rows
# col = tetromino type index (I=0, T=1, O=2, Z=3, S=4, L=5, J=6)
# row 0: covered(dark bg/gray), row 1: blank(light bg), row 2: bomb, row 3: flag, rows 4-11: numbers 1-8
const MS_ROW_BLANK: int = 1
const MS_ROW_COVERED: int = 0
const MS_ROW_BOMB: int = 2
const MS_ROW_FLAG: int = 3
# Number n (1-8) is at row: 3 + n
const MS_COL_GRAY: int = 7  # gray column, used exclusively for the covered state

const BOMBS_PER_PIECE: int = 1

# Key: Vector2i cell position, Value: { "is_bomb": bool, "state": CellState, "adjacent_bombs": int, "tetromino_type": int }
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
	tc.get_node("BtnRotate").button_down.connect(_on_btn_rotate_down)
	tc.get_node("BtnRotate").button_up.connect(_on_btn_rotate_up)
	tc.get_node("BtnHardDrop").pressed.connect(_on_btn_hard_drop_pressed)
	tc.get_node("BtnHold").pressed.connect(_on_btn_hold_pressed)
	tc.get_node("BtnPause").pressed.connect(_on_btn_pause_pressed)

	load_highscore()
	
	# Wwise Initialization
	Wwise.register_game_obj(self, "MinesweeperGame")
	Wwise.load_bank("Init")
	Wwise.load_bank("New_SoundBank")
	
	show_main_menu()


func start_game() -> void:
	rng.randomize()
	score = 0
	lines_cleared = 0
	is_game_running = true
	is_paused = false
	first_tetromino_landed = false
	tetrominoes = all_tetrominoes.duplicate()
	rotation_index = 0
	fall_timer = 0.0
	move_timer = 0.0
	active_dir = Vector2i.ZERO
	held_tetromino = []
	can_hold = true
	touch_down_held = false
	reset_board_touch_state()
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
	touch_controls.visible = true
	current_tetromino = choose_tetromino()
	piece_atlas = Vector2i(all_tetrominoes.find(current_tetromino), 0)
	next_tetromino = choose_tetromino()
	next_piece_atlas = Vector2i(all_tetrominoes.find(next_tetromino), 0)
	initialize_tetromino()

	Wwise.set_state("Intensity", "Lowint")



func show_main_menu() -> void:
	Wwise.set_state("Intensity", "None")
	Wwise.post_event("Start", self)
	
	is_game_running = false
	is_paused = false
	first_tetromino_landed = false
	rotation_index = 0
	touch_down_held = false
	reset_board_touch_state()
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
	touch_controls.visible = false
	menu_highscore_label.text = "Best: " + str(highscore)


func show_game_over_menu() -> void:
	Wwise.post_event("Perder", self)
	Wwise.set_state("Intensity", "None")
	
	is_game_running = false

	touch_down_held = false
	reset_board_touch_state()
	save_highscore()
	final_score_label.text = "Score: " + str(score)
	highscore_gameover_label.text = "Best: " + str(highscore)
	game_over_menu.visible = true
	touch_controls.visible = true


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
	reset_board_touch_state()
	pause_menu.visible = true
	touch_controls.visible = false


func resume_game() -> void:
	is_paused = false
	pause_menu.visible = false
	touch_controls.visible = true


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


# --- Speed scaling by cleared lines (linear) ---
const FALL_INTERVAL_START: float = 1.0
const FALL_INTERVAL_MIN: float = 0.1
const FALL_SPEED_PER_LINE: float = 0.03  # each cleared line subtracts 0.03s (max speed at 30 lines)

func get_current_fall_interval() -> float:
	return maxf(FALL_INTERVAL_MIN, FALL_INTERVAL_START - lines_cleared * FALL_SPEED_PER_LINE)


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

		if active_board_touch_id != -1 and not board_touch_hold_triggered:
			if Time.get_ticks_msec() - active_board_touch_start_ms >= TOUCH_HOLD_THRESHOLD_MS:
				flag_cell(active_board_touch_cell)
				board_touch_hold_triggered = true

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
	update_music_state()


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
			lines_cleared += 1
			score_label.text = "Score: " + str(score)
		else:
			row -= 1
	update_music_state()

func update_music_state() -> void:
	var count = minesweeper_cells.size()
	if count < 20:
		Wwise.set_state("Intensity", "Lowint")
	elif count < 50:
		Wwise.set_state("Intensity", "Medint")
	else:
		Wwise.set_state("Intensity", "Highint")



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
		# Wwise.post_event("Play_Rotate", self) # Uncomment when you add this event to Wwise
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

func set_dpad_texture(btn_name: String, pressed: bool) -> void:
	var tex_rect: TextureRect = touch_controls.get_node(btn_name + "/DpadTexture")
	tex_rect.texture = dpad_tex_pressed if pressed else dpad_tex_unpressed

func _on_btn_left_down() -> void:
	set_dpad_texture("BtnLeft", true)
	if not is_game_running or is_paused:
		return
	move_tetromino(Vector2i.LEFT)
	active_dir = Vector2i.LEFT
	move_timer = 0.0


func _on_btn_left_up() -> void:
	set_dpad_texture("BtnLeft", false)
	if active_dir == Vector2i.LEFT:
		active_dir = Vector2i.ZERO


func _on_btn_right_down() -> void:
	set_dpad_texture("BtnRight", true)
	if not is_game_running or is_paused:
		return
	move_tetromino(Vector2i.RIGHT)
	active_dir = Vector2i.RIGHT
	move_timer = 0.0


func _on_btn_right_up() -> void:
	set_dpad_texture("BtnRight", false)
	if active_dir == Vector2i.RIGHT:
		active_dir = Vector2i.ZERO


func _on_btn_down_down() -> void:
	set_dpad_texture("BtnDown", true)
	touch_down_held = true


func _on_btn_down_up() -> void:
	set_dpad_texture("BtnDown", false)
	touch_down_held = false


func _on_btn_rotate_down() -> void:
	set_dpad_texture("BtnRotate", true)
	if not is_game_running or is_paused:
		return
	rotate_tetromino()


func _on_btn_rotate_up() -> void:
	set_dpad_texture("BtnRotate", false)


func _on_btn_hard_drop_pressed() -> void:
	if not is_game_running or is_paused:
		return
	hard_drop()


func _on_btn_hold_pressed() -> void:
	if not is_game_running or is_paused:
		return
	hold_tetromino()


func _on_btn_pause_pressed() -> void:
	if is_game_running:
		toggle_pause()


# --- Minesweeper functions ---

func transform_to_minesweeper(tetromino_blocks: Array, pos: Vector2i) -> void:
	var absolute_cells: Array[Vector2i] = []
	for block in tetromino_blocks:
		absolute_cells.append(pos + block)

	place_bombs(absolute_cells, piece_atlas.x)
	update_adjacent_bombs(absolute_cells)

	for cell in absolute_cells:
		mines.set_cell(cell, tile_id, Vector2i(piece_atlas.x, MS_ROW_COVERED))


func reveal_all_bottom_edge_hints() -> void:
	for i in range(1, COLS + 1):
		var hint_cell := Vector2i(i, ROWS + 1)
		if not minesweeper_cells.has(hint_cell):
			minesweeper_cells[hint_cell] = {
				"is_bomb": false,
				"state": CellState.COVERED,
				"adjacent_bombs": 0,
				"tetromino_type": MS_COL_GRAY
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
			mines.set_cell(hint_cell, tile_id, Vector2i(MS_COL_GRAY, 3 + count))
		else:
			mines.set_cell(hint_cell, tile_id, Vector2i(MS_COL_GRAY, MS_ROW_BLANK))

func place_bombs(cells: Array[Vector2i], tetromino_type: int) -> void:
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
			"adjacent_bombs": 0,
			"tetromino_type": tetromino_type
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


func recalculate_adjacent_bombs_for_rows(rows: Array[int]) -> void:
	var rows_to_update: Dictionary = {}
	for row in rows:
		rows_to_update[row] = true

	for cell in minesweeper_cells:
		if not rows_to_update.has(cell.y):
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

	Wwise.post_event("Click", self)
	minesweeper_cells[cell]["state"] = CellState.REVEALED

	var tcol: int = minesweeper_cells[cell]["tetromino_type"]
	if minesweeper_cells[cell]["is_bomb"]:
		mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_BOMB))
		show_game_over_menu()

	else:
		var adj: int = minesweeper_cells[cell]["adjacent_bombs"]
		if adj > 0:
			mines.set_cell(cell, tile_id, Vector2i(tcol, 3 + adj))
		else:
			mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_BLANK))
			# Flood-fill reveal neighboring cells with 0 adjacent bombs
			for neighbor in get_neighbors(cell):
				reveal_cell(neighbor)


func flag_cell(cell: Vector2i) -> void:
	if not minesweeper_cells.has(cell):
		return

	var tcol: int = minesweeper_cells[cell]["tetromino_type"]
	if minesweeper_cells[cell]["state"] == CellState.COVERED:
		minesweeper_cells[cell]["state"] = CellState.FLAGGED
		mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_FLAG))
	elif minesweeper_cells[cell]["state"] == CellState.FLAGGED:
		minesweeper_cells[cell]["state"] = CellState.COVERED
		mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_COVERED))


func render_minesweeper_cell(cell: Vector2i) -> void:
	if not minesweeper_cells.has(cell):
		mines.erase_cell(cell)
		return
	var data: Dictionary = minesweeper_cells[cell]
	var tcol: int = data.get("tetromino_type", 0)
	match data["state"]:
		CellState.COVERED:
			mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_COVERED))
		CellState.FLAGGED:
			mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_FLAG))
		CellState.REVEALED:
			if data["is_bomb"]:
				mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_BOMB))
			elif data["adjacent_bombs"] > 0:
				mines.set_cell(cell, tile_id, Vector2i(tcol, 3 + data["adjacent_bombs"]))
			else:
				mines.set_cell(cell, tile_id, Vector2i(tcol, MS_ROW_BLANK))


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
	recalculate_adjacent_bombs_for_rows([
		cleared_row,
		mini(cleared_row + 1, ROWS + 1),
		ROWS + 1
	])


func get_cell_from_mouse() -> Vector2i:
	var local_pos: Vector2 = mines.get_local_mouse_position()
	return mines.local_to_map(local_pos)


func get_cell_from_global_position(global_pos: Vector2) -> Vector2i:
	return mines.local_to_map(mines.to_local(global_pos))


func is_point_in_mines(global_pos: Vector2) -> bool:
	var local_pos: Vector2 = mines.to_local(global_pos)
	return mines.get_used_rect().has_point(mines.local_to_map(local_pos))


func reset_board_touch_state() -> void:
	active_board_touch_id = -1
	active_board_touch_pos = Vector2.ZERO
	active_board_touch_cell = Vector2i.ZERO
	active_board_touch_start_ms = 0
	board_touch_hold_triggered = false


func _input(event: InputEvent) -> void:
	if not is_game_running or is_paused:
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton and event.pressed and is_point_in_mines(event.position):
		if event.button_index == MOUSE_BUTTON_LEFT:
			reveal_cell(get_cell_from_global_position(event.position))
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			flag_cell(get_cell_from_global_position(event.position))


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if active_board_touch_id != -1 or not is_point_in_mines(event.position):
			return
		active_board_touch_id = event.index
		active_board_touch_pos = event.position
		active_board_touch_cell = get_cell_from_global_position(event.position)
		active_board_touch_start_ms = Time.get_ticks_msec()
		board_touch_hold_triggered = false
		return

	if event.index != active_board_touch_id:
		return

	var moved_too_far: bool = active_board_touch_pos.distance_to(event.position) > TOUCH_MOVE_TOLERANCE
	if not board_touch_hold_triggered and not moved_too_far and is_point_in_mines(event.position):
		reveal_cell(active_board_touch_cell)
	reset_board_touch_state()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index != active_board_touch_id:
		return
	if active_board_touch_pos.distance_to(event.position) > TOUCH_MOVE_TOLERANCE:
		reset_board_touch_state()
