extends Node2D

@onready var cat1 = preload("res://Scenes/AlleyCat.tscn")
@onready var cat2 = preload("res://Scenes/BlackCat.tscn")
const EMPTY: int = 0
const PLAYER_X = 1
const PLAYER_O = -1
var game_depth = 50
var Player1
var Player2
var gridSize = 3
var boxSize: float = 160 / (gridSize /3.0)
var win_length = 3
var player = PLAYER_X
var board: Array = []
var click = false
var character
var PlayerPos = Vector2()
var gameReady = false
var storeX
var storeY
var validLocation = true
var spriteScale: float = 160
var INFINITY = 10000000
var moveCount = 0


#=================================================================================================
func _ready():
	Player1 = cat1.instantiate()
	Player2 = cat2.instantiate()
	#Attach it to the tree
	add_child(Player1)
	add_child(Player2)
	Player1.visible = false
	Player2.visible = false

	for i in range(gridSize * gridSize):
		board.append(EMPTY)



#=================================================================================================
func _draw():
	if gameReady == false:
		for r in range(50, boxSize*gridSize, boxSize):
			for c in range(50, boxSize*gridSize, boxSize):
				draw_rect(Rect2(10+c, 10+r, boxSize, boxSize), Color.LIGHT_SLATE_GRAY, false, 3)
		gameReady = true
	else:
		for r in range(50, boxSize*gridSize, boxSize):
			for c in range(50, boxSize*gridSize, boxSize):
				draw_rect(Rect2(10+c, 10+r, boxSize, boxSize), Color.LIGHT_SLATE_GRAY, false, 3)
		if validLocation == true:
			draw_rect(Rect2(60+PlayerPos.x, 60+PlayerPos.y, boxSize, boxSize), Color.GREEN, false, 3)
		else:
			draw_rect(Rect2(60+PlayerPos.x, 60+PlayerPos.y, boxSize, boxSize), Color.RED, false, 3)


#=================================================================================================
func _process(delta):
	if player == PLAYER_X:
		pass
	if player == PLAYER_O and check_winner(board, gridSize, win_length) == EMPTY:
		play_AI()

		
#=================================================================================================		
func play_AI():
	var best_move = find_best_move(board, gridSize, win_length)
	print("Best move is: col ", best_move.x, ", row ", best_move.y)
	Player2.visible = true
	Player1.visible = false
	Player1.z_index = 0
	Player2.z_index = 1
	Player2.position.x = 140 + (best_move.x * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
	Player2.position.y = 150 + (best_move.y * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
	Player2.scale.x = boxSize / spriteScale
	Player2.scale.y = boxSize / spriteScale
	character = cat2.instantiate()
	#$Cat2.play()
	character.position.x = 140 + (best_move.x * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
	character.position.y = 150 + (best_move.y * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
	character.scale.x = boxSize / spriteScale
	character.scale.y = boxSize / spriteScale
	board[best_move.y * gridSize + best_move.x] = PLAYER_O

	add_child(character)
	
	var winner = check_winner(board, gridSize, win_length)
	if winner == PLAYER_O:
		win(PLAYER_O)
	player = PLAYER_X
	printMatrix()
	moveCount+=1
	print ("Move #: " + str(moveCount))
	queue_redraw()

#=================================================================================================
func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.pressed:
		click = true
		findBoundingBox(click)
		#click = false
	elif event is InputEventMouseMotion:
		click = false
		findBoundingBox(click)


#=================================================================================================
func findBoundingBox(is_clicked):
	#In this script, we first define the size of each bounding box in the grid using the box_size variable, and the top-left corner of the grid using the grid_origin variable. We then use a nested loop to iterate over each bounding box in the grid.
	#For each bounding box, we calculate the position and size of the bounding box based on its x and y indices in the grid, and create a new Rect2 instance using these values. We then use the has_point() method of the Rect2 class to check if the mouse
	#position is within the current bounding box. If the mouse position is within the current bounding box, we print a message to
	#the console indicating the x and y indices of the bounding box.
	#You can modify the values of box_size and grid_origin to match the size and position of your own bounding boxes, and the script should work correctly for your use case.

	#define the size of each bounding box in the grid
	var bbox_size = Vector2(boxSize, boxSize)

	# define the top-left corner of the grid
	var grid_origin = Vector2(50, 50)

	# iterate over each bounding box in the grid
	for r in range(gridSize):
		for c in range(gridSize):

			# define the position and size of the current bounding box
			var bbox_pos = grid_origin + Vector2(c, r) * bbox_size
			var bbox = Rect2(bbox_pos, bbox_size)

			# check if the mouse position is within the current bounding box
			var mouse_pos = get_global_mouse_position()
			if bbox.has_point(mouse_pos):
				if board[r * gridSize + c]== 0:
					validLocation = true
				else:
					validLocation = false

				PlayerPos.x = (c * boxSize)
				PlayerPos.y = (r * boxSize)
				Player1.visible = true
				Player2.visible = false
				Player1.z_index = 1
				Player2.z_index = 0
				Player1.position.x = 140 + (c * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
				Player1.position.y = 150 + (r * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
				Player1.scale.x = boxSize / spriteScale
				Player1.scale.y = boxSize / spriteScale


				if is_clicked:
					if board[r * gridSize + c]== 0:
						board[r * gridSize + c] = PLAYER_X
						storeX = c
						storeY = r
						Player1.visible = false
						Player2.visible = false
						character = cat1.instantiate()
						#$Cat1.play()
						character.position.x = 140 + (c * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
						character.position.y = 150 + (r * boxSize) + (boxSize * 0.5) - (spriteScale * 0.5)
						character.scale.x = boxSize / spriteScale
						character.scale.y = boxSize / spriteScale

						#character.position = Vector2(mouse_pos)
						add_child(character)
						player = PLAYER_O
						printMatrix()
						moveCount+=1
						print ("Move #: " + str(moveCount))
					var winner = check_winner(board, gridSize, win_length)
					if winner == PLAYER_X:
						win(PLAYER_X)

				queue_redraw()

			
#=================================================================================================
func printMatrix():  # print to debug output only
	var rowString = ""
	for row in range (gridSize):
		for col in range (gridSize):
			rowString += String("X" if board[row * gridSize + col]==1 else "O" if board[row * gridSize + col]==-1 else ".")
		print(rowString)
		rowString = ""
	print()

				
#=================================================================================================
func win(winningPlayer):
	queue_redraw()
	print("Player " + str(winningPlayer) + " Wins!")
#	await $CatPurr.play()
#	get_tree().paused = true
	#$CatPurr.play()


#=================================================================================================
func is_continuous_line(grid: Array, size, length: int, row: int, col: int, row_dir: int, col_dir: int, playerNum: int) -> bool:
	for i in range(length):
		if grid[row * size + col] != playerNum:
			return false
		row += row_dir
		col += col_dir
	return true

#=================================================================================================
func check_winner(grid: Array, size: int, length: int) -> int:
	for r in range(size):
		for c in range(size):
			if grid[r * size + c] != EMPTY:
				if c <= size - length and is_continuous_line(grid, size, length, r, c, 0, 1, grid[r * size + c]):
					return grid[r * size + c]
				if r <= size - length and is_continuous_line(grid, size, length, r, c, 1, 0, grid[r * size + c]):
					return grid[r * size + c]
				if r <= size - length and c <= size - length and is_continuous_line(grid, size, length, r, c, 1, 1, grid[r * size + c]):
					return grid[r * size + c]
				if r <= size - length and c >= length - 1 and is_continuous_line(grid, size, length, r, c, 1, -1, grid[r * size + c]):
					return grid[r * size + c]
	return EMPTY

#=================================================================================================
func score_line(ai_count: int, human_count: int) -> int:
	if ai_count == 0 and human_count > 0:
		return -int(pow(10, human_count - 1))
	elif human_count == 0 and ai_count > 0:
		return int(pow(10, ai_count - 1))
	else:
		return 0

#=================================================================================================
func evaluate_line(grid: Array, size: int, length: int, row: int, col: int, row_dir: int, col_dir: int) -> int:
	var ai_count = 0
	var human_count = 0

	for i in range(length):
		if grid[row * size + col] == PLAYER_O:
			ai_count += 1
		elif grid[row * size + col] == PLAYER_X:
			human_count += 1
		row += row_dir
		col += col_dir

	return score_line(ai_count, human_count)

#=================================================================================================
func evaluate_board(grid: Array, size: int, length: int) -> int:
	var score = 0
	for r in range(size):
		for c in range(size):
			if c <= size - length:
				score += evaluate_line(grid, size, length, r, c, 0, 1)

			if r <= size - length:
				score += evaluate_line(grid, size, length, r, c, 1, 0)

			if r <= size - length and c <= size - length:
				score += evaluate_line(grid, size, length, r, c, 1, 1)

			if r <= size - length and c >= length - 1:
				score += evaluate_line(grid, size, length, r, c, 1, -1)

	return score

#=================================================================================================
func minimax(grid: Array, size: int, length: int, depth: int, alpha: int, beta: int, is_maximizing: bool) -> int:
	var winner = check_winner(grid, size, length)
	if winner != EMPTY:
		return (winner * (size - depth)) * (1 if depth % 2 == 0 else -1)

	if depth >= game_depth:
		return 0

	if is_maximizing:
		var best_value = -INFINITY
		for r in range(size):
			for c in range(size):
				if grid[r * size + c] == EMPTY:
					grid[r * size + c] = PLAYER_O
					var value = minimax(grid, size, length, depth + 1, alpha, beta, false)
					grid[r * size + c] = EMPTY
					best_value = max(value, best_value)
					alpha = max(alpha, best_value)
					if beta <= alpha:
						break
		return best_value
	else:
		var best_value = INFINITY
		for r in range(size):
			for c in range(size):
				if grid[r * size + c] == EMPTY:
					grid[r * size + c] = PLAYER_X
					var value = minimax(grid, size, length, depth + 1, alpha, beta, true)
					grid[r * size + c] = EMPTY
					best_value = min(value, best_value)
					beta = min(beta, best_value)
					if beta <= alpha:
						break
		return best_value

#=================================================================================================
func find_best_move(grid: Array, size: int, length: int) -> Vector2:
	var best_value = -INFINITY
	var best_move = Vector2(-1, -1)

	for r in range(size):
		for c in range(size):
			if grid[r * size + c] == EMPTY:
				grid[r * size + c] = PLAYER_O
				var move_value = minimax(grid, size, length, 0, -INFINITY, INFINITY, true)
				grid[r * size + c] = EMPTY

				if move_value > best_value or (move_value == best_value and randf() > 0.5):
					best_value = move_value
					best_move = Vector2(c, r)

			if best_value == INFINITY:  # Early exit when we found the best possible move
				break
		if best_value == INFINITY:  # This break is for the outer loop
			break

	return best_move

#=================================================================================================
func evaluate(grid: Array, size: int, length: int) -> int:
	var score = 0

	for r in range(size):
		for c in range(size):
			if grid[r * size + c] == EMPTY:
				grid[r * size + c] = PLAYER_X
				if check_winner(grid, size, length) == PLAYER_O:
					score += 1
				grid[r * size + c] = PLAYER_O
				if check_winner(grid, size, length) == PLAYER_X:
					score += 10  # Increase the score significantly when blocking the opponent's winning move
				grid[r * size + c] = EMPTY

	return score


