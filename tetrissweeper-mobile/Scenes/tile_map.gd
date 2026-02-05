extends TileMap

# -1 = empty cell
# 0 = mine
# 1-8 = number tile

const CELL_ROWS := 30
const CELL_COLUMNS := 16
# Don't set mines too high or it will lag/crash the game
const MINE_COUNT := 99

var gameEnded := false
var offsetCoords: Vector2i
var cells: Array[int]
var surroundingCells: Array[int]
var lastMove: Array[Vector2i]

# Tile Atlas Coordinates
const ATLAS_HIDDEN := Vector2i(0, 0)
const ATLAS_FLAG := Vector2i(1, 0)
const ATLAS_MINE_OFF := Vector2i(2, 0)
const ATLAS_MINE_HIT := Vector2i(0, 3)
const ATLAS_WRONG_FLAG := Vector2i(1, 3)
const ATLAS_EMPTY := Vector2i(3, 0)

# Number Tile Atlas Coordinates
const ATLAS_NUM_1 := Vector2i(0, 1)
const ATLAS_NUM_2 := Vector2i(1, 1)
const ATLAS_NUM_3 := Vector2i(2, 1)
const ATLAS_NUM_4 := Vector2i(3, 1)
const ATLAS_NUM_5 := Vector2i(0, 2)
const ATLAS_NUM_6 := Vector2i(1, 2)
const ATLAS_NUM_7 := Vector2i(2, 2)
const ATLAS_NUM_8 := Vector2i(3, 2)

func _ready() -> void:
	newGame()


# Set up empty grid
func newGame() -> void:
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			set_cell(0, Vector2i(x, y), 0, ATLAS_HIDDEN)
			cells.append(-1)


func setUpMines(avoid: Vector2i) -> void:
	### Esto genera el tablero, hay que volarlo
	#for i in range(MINE_COUNT):
	#	cells[i] = 0
	#
	#cells.shuffle()
	## Make sure you don't have bombs too close to the starting area
	#while getSurroundingCells(avoid, 5).has(0):
	#	cells.shuffle()
	#
	cells[CELL_ROWS/2] = 0
	
	setupNumberedCells()


func setupNumberedCells() -> void:
	## Esto esta bien y va a haber que llamarlo constantemente, o algo mejor
	# Set up the numbered cells
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			# For each cell at x, y
			if not cells[getCellIndex(Vector2i(x, y))] == 0:
				var mineCount := 0
				for i in getSurroundingCells(Vector2i(x, y), 3):
					if i == 0:
						mineCount += 1
				
				if mineCount > 0:
					cells[getCellIndex(Vector2i(x, y))] = mineCount

# Detect clicks on the cells
func _input(event: InputEvent) -> void:
	if gameEnded == false:
		if event.is_action_pressed("reveal"):
			var cellAtMouse: Vector2i = local_to_map(get_local_mouse_position())
			lastMove = []
			# If not a flag
			if getAtlasCoords(cellAtMouse) != ATLAS_FLAG:
				if cells.has(0):
					lastMove.append(cellAtMouse)
					revealCell(cellAtMouse)
					
					# If clicked on a number cell
					if cells[getCellIndex(cellAtMouse)] >= 1:
						revealSurroundingCells(cellAtMouse, false)
					
					# If there was a mine revealed, end the game
					for i in lastMove:
						if cells[getCellIndex(i)] == 0:
							gameEnded = true
							revealAllMines(lastMove)
				else:
					setUpMines(cellAtMouse)
					revealCell(cellAtMouse)
		
		if event.is_action_pressed("flag"):
			var cellAtMouse: Vector2i = local_to_map(get_local_mouse_position())
			# If unrevealed cell, place flag. If flagged cell, make unrevealed
			if getAtlasCoords(cellAtMouse) == ATLAS_HIDDEN:
				set_cell(0, cellAtMouse, 0, ATLAS_FLAG)
			elif getAtlasCoords(cellAtMouse) == ATLAS_FLAG:
				set_cell(0, cellAtMouse, 0, ATLAS_HIDDEN)


# Determine what to do with the cell just clicked
func revealCell(cellCoords: Vector2i) -> void:
	var cellIndex: int
	cellIndex = getCellIndex(cellCoords)
	
	var atlasCoords: Vector2i
	match cells[cellIndex]:
		-1: atlasCoords = ATLAS_EMPTY
		0: atlasCoords = ATLAS_MINE_HIT
		1: atlasCoords = ATLAS_NUM_1
		2: atlasCoords = ATLAS_NUM_2
		3: atlasCoords = ATLAS_NUM_3
		4: atlasCoords = ATLAS_NUM_4
		5: atlasCoords = ATLAS_NUM_5
		6: atlasCoords = ATLAS_NUM_6
		7: atlasCoords = ATLAS_NUM_7
		8: atlasCoords = ATLAS_NUM_8
	
	set_cell(0, cellCoords, 0, atlasCoords)
	
	# Only empty cells will reveal all of the cells around it
	if cells[cellIndex] == -1:
		revealSurroundingCells(cellCoords, false)


# Converts cell coordinates to index in cells array
func getCellIndex(cellCoords: Vector2i) -> int:
	if cellCoords.x < CELL_ROWS and cellCoords.y < CELL_COLUMNS:
		if cellCoords.x >= 0 and cellCoords.y >= 0:
			return cellCoords.y * CELL_ROWS + cellCoords.x
		else:
			return -1
	else:
		return -1


# Don't set size too high or it will lag/crash the game
func getSurroundingCells(cellCoords: Vector2i, size: int) -> Array[int]:
	surroundingCells = []
	for y in range(-1, size - 1):
		for x in range(-1, size - 1):
			offsetCoords = cellCoords + Vector2i(x, y)
			if getCellIndex(offsetCoords) > -1:
				surroundingCells.append(cells[getCellIndex(offsetCoords)])
			else:
				surroundingCells.append(-1)
	return surroundingCells


func revealSurroundingCells(cellCoords: Vector2i, numberCanReveal: bool) -> void:
	var numberFlags := 0
	for y in range(-1, 2):
		for x in range(-1, 2):
			offsetCoords = cellCoords + Vector2i(x, y)
			
			if getCellIndex(offsetCoords) > -1:
				if cells[getCellIndex(cellCoords)] >= 1:
					# If a number cell was clicked
					# If the cell is a flag
					if getAtlasCoords(offsetCoords) == ATLAS_FLAG:
						if numberCanReveal == false:
							numberFlags += 1
					else:
						if numberCanReveal == true:
							# If the cell isn't revealed yet
							if getAtlasCoords(offsetCoords) == ATLAS_HIDDEN:
								lastMove.append(offsetCoords)
								revealCell(offsetCoords)
				else:
					# If empty cell
					# If the cell isn't revealed yet or a flag
					if getAtlasCoords(offsetCoords) == ATLAS_HIDDEN or getAtlasCoords(offsetCoords) == ATLAS_FLAG:
						revealCell(offsetCoords)
	
	if cells[getCellIndex(cellCoords)] >= 1:
		# If a number cell was clicked
		if numberFlags == cells[getCellIndex(cellCoords)]:
			revealSurroundingCells(cellCoords, true)


func revealAllMines(avoid: Array[Vector2i]) -> void:
	var cellCoords: Vector2i
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			cellCoords = Vector2i(x, y)
			if cells[getCellIndex(cellCoords)] == 0:
				# If it was a bomb
				if not avoid.has(cellCoords) && getAtlasCoords(cellCoords) != ATLAS_FLAG:
					set_cell(0, cellCoords, 0, ATLAS_MINE_OFF)
			else:
				# If it wasn't a bomb and flag is on the cell
				if getAtlasCoords(cellCoords) == ATLAS_FLAG:
					set_cell(0, cellCoords, 0, ATLAS_WRONG_FLAG)


func getAtlasCoords(cellCoords: Vector2i) -> Vector2i:
	return get_cell_atlas_coords(0, cellCoords)


#### tetrisweeper attempt
