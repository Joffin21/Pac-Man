# YOUR_USERNAME_HERE: jom193
# YOUR_FULL_NAME_HERE: Joffin Manjaly

.include "convenience.asm"
.include "game_settings.asm"
.include "player_struct.asm"


#	Defines the number of frames per second: 16ms -> 60fps
.eqv	GAME_TICK_MS		32

.data
# don't get rid of these, they're used by wait_for_next_frame.
showPoints: 	.asciiz "PTS: "  		# The text we use to show points at the bottom
lives:		.asciiz "LVS: " 		# The text we use to show lives at the bottom

last_frame_time:  .word 0
frame_counter:    .word 0
.globl wallMatrix
wallMatrix:	.word		# This is the Matrix of the board (1 means wall, 0 means MacGuffin is there, and 2 means empty space) The starting 2 is where characters are
		1 1 1 1 1 1 1 1 1 1 1 1
		1 2 0 0 0 0 1 2 0 0 1 1
		1 1 1 0 1 0 1 0 1 0 0 1
		1 2 0 0 0 0 0 0 1 1 0 1
		1 0 1 1 1 1 0 1 1 1 0 1
		1 0 0 0 0 0 0 0 0 0 0 1
		1 0 1 1 0 1 0 1 1 1 0 1
		1 0 1 1 0 1 0 0 0 0 0 1
		1 0 0 1 0 1 1 1 0 1 0 1
		1 1 0 0 0 0 0 0 0 0 2 1
		1 1 1 1 1 1 1 1 1 1 1 1

# wallMatrix:	.word
# 		1 1 1 1 1 1 1 1 1 1 1 1
# 		1 2 2 2 2 2 1 2 0 2 1 1
# 		1 2 1 2 1 2 1 2 1 0 0 1
# 		1 2 2 2 2 2 2 2 1 1 0 1
# 		1 2 1 1 1 1 2 1 1 1 0 1
# 		1 2 2 2 2 2 2 2 2 2 0 1
# 		1 2 1 1 2 1 2 1 1 1 0 1
# 		1 2 1 1 2 1 2 2 2 2 0 1
# 		1 2 2 1 2 1 1 1 2 1 0 1
# 		1 1 2 2 2 2 2 0 0 0 2 1
# 		1 1 1 1 1 1 1 1 1 1 1 1


wall:	.byte
	5  5  5  5  5
	5  0  1  0  5
	5  1  0  1  5
	5  0  1  0  5
	5  5  5  5  5

dot:	.byte			#MacGuffin
	0  0  0  0  0
	0  0  0  0  0
	0  0  3  0  0
	0  0  0  0  0
	0  0  0  0  0

.globl player
player:	.byte
	4  4  4  4  4
	4  4  5  4  4
	4  0  5  0  4
	4  0  5  0  4
	4  4  4  4  4

.globl enemy
enemy:	.byte
	6  6  6  6  6
	6  2  2  2  6
	6  0  2  0  6
	6  0  2  0  6
	6  6  6  6  6

.text
# --------------------------------------------------------------------------------------------------

.globl game
game:
	# set up anything you need to here,
	# and wait for the user to press a key to start.
	li	a0, 0 
	jal	pixel_get_element
	lw	t4, pixel_t(v0)			#loading counter for blinking
	move	s0, v0				
	
_game_loop:
	
	li	s1, 1
	# check for input,
	jal     handle_input

	# update everything,
	li 	s5, 0		#This is going to be my counter to show that the game is 0. This will update in createMaze

	# draw everything
	lw	a0, frame_counter
	jal	bottom_line		#this is just a horizontal red line at the bottom
	jal	createMaze		#builds the entire maze
						#displays points and lives at the bottom under the red line
	li	a0, 0 
	jal	pixel_get_element
	li	a0, 1
	li	a1, 57
	la	a2, showPoints
	jal	display_draw_text
	li	a0, 36
	li	a1, 57
	la	a2, lives
	jal	display_draw_text
	li	a0, 22
	li	a1, 57
	lw	a2, pixel_p(v0)
	jal	display_draw_int
	li	a0, 57
	li	a1, 57
	lw	a2, pixel_l(v0)
	jal	display_draw_int
	
	
	beq	s5, 0, _game_over	#s5 gets updated in create maze and reaches 0 when all the MacGuffins are gone
	jal	enemy_draw		#draw the enemies
	jal	checkState		#check if player is blinking or not
	beq	s7, 1, pre_pixel_draw	#if not blinking, then we just draw him normlaly
	li	a0, 0 			#if he is blinking
	jal	pixel_get_element
	lw	t4, pixel_t(v0)		#load the counter
	bnez	t4, changeBack		#as long as the counter is > 0, then keep flipping pixel_b between 1 and 0, so its blinking 
	jal	startCounter		#it only reaches this line if pixel_b is 0, but the counter hasn't started (used when first hitting the enemy)
	continue:
		#jal	pixel_draw
		jal	enemy_update	#update enemy location
		jal	pixel_update	#updates player location
	
		jal 	checkLives		#checks lives of the player
		beq	v0, 0, _game_over	#if lives is =0 then game is over
#	jal	startingPlayer
	#jal	startingEnemies
	#jal	createOutisdeSquare
	#jal	createInsideWalls

	# This is only called once!!
		jal	display_update_and_clear

	## This function will block waiting for the next frame!
		jal	wait_for_next_frame
		j	_game_loop

_game_over:

	#jal	display_points
	jal	display_update_and_clear
	jal	wait_for_next_frame

	exit



# --------------------------------------------------------------------------------------------------
# call once per main loop to keep the game running at 60FPS.
# if your code is too slow (longer than 16ms per frame), the framerate will drop.
# otherwise, this will account for different lengths of processing per frame.

wait_for_next_frame:
	enter	s0
	lw	s0, last_frame_time
_wait_next_frame_loop:
	# while (sys_time() - last_frame_time) < GAME_TICK_MS {}
	li	v0, 30
	syscall # why does this return a value in a0 instead of v0????????????
	sub	t1, a0, s0
	bltu	t1, GAME_TICK_MS, _wait_next_frame_loop

	# save the time
	sw	a0, last_frame_time

	# frame_counter++
	lw	t0, frame_counter
	inc	t0
	sw	t0, frame_counter
	leave	s0

# --------------------------------------------------------------------------------------------------

bottom_line:				# this is the method to create the red line
	enter	s0, s1, s2, s3, s4
	li	s0, 0
	li	s1, 55
	li	s2, 60
	li	s3, COLOR_RED
	li	s4, 0
	j	_draw_horizontal_line_loop


# -------------------------------------------------------------------------------------------------

createMaze:				#method to set up the maze creation
	push 	ra

	la	s0, wallMatrix
	li 	s1, 0
	li 	s2, 4



createMazeLoop:
	mul	s3, s1, s2
	add	t0, s0, s3
	beq	s1, 132, exit_CreateMaze

	lb	t1, (t0)
	beq	t1, 1, preCreateSquare # creates the walls
	beq	t1, 0, preCreateDot	# creates spaces with MacGuffins
	beq	t1, 2, doNothing 	# creates empty spaces (mainly needed for after MacGuffins are picked up)

exit_CreateMaze:
	pop	ra
	jr 	ra


preCreateSquare:
	li	s4, 12
	div	s1, s4
	mfhi	t2 #quotient
	mflo	t3 #remainder
	add	s1, s1, 1
	mul	t2, t2, 5
	mul	t3, t3, 5
	j	createSquare


createSquare:
	move	a0, t2
	move	a1, t3
	la	a2, wall # pointer to the image
	jal	display_blit_5x5
	j	createMazeLoop

preCreateDot:
	li	s4, 12
	div	s1, s4
	mfhi	t2 #quotient
	mflo	t3 #remainder
	add	s1, s1, 1
	mul	t2, t2, 5
	mul	t3, t3, 5
	j	createDot


createDot:
	inc	s5
	move	a0, t2
	move	a1, t3
	la	a2, dot # pointer to the image
	jal	display_blit_5x5_trans
	j	createMazeLoop

doNothing:
	add	s1, s1, 1
	j	createMazeLoop

# -------------------------------------------------------------------------------------------------

display_points:			#i'm not sure if I use this method anymore at all but this what I used at first to display points
	push	ra
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	lw	s5, pixel_p(s0)
	li	a0, 5
	li	a1, 56
	move	a2, s5
	jal	display_draw_int
	pop	ra
	jr	ra


checkLives:			#this is to check the lives left of the player
	push	ra
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	lw	s6, pixel_l(s0)
	move	v0, s6	
	pop	ra
	jr	ra

pre_pixel_draw:			#after checking the state of the player: if it is 1(not blinking), then it comes here before drawing the player
	li 	s7, 0
	jal	pixel_draw
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	lw	t4, pixel_t(s0)
	bnez	t4, changeBack
	j	continue

changeBack:			#this is used to flip between invisible and visible to demonstrated blinking
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0	
	lw	t5, pixel_b(s0)
	beq	t5, 1, flipto0		#if normal then next time be invisible
	beq	t5, 0, flipto1		#vice versa
	j	continue
	
checkState:
	push	ra
	li	a0, 0
	jal 	pixel_get_element
	lw 	s7, pixel_b(v0)
	pop	ra
	jr	ra
	
startCounter:				#starts the counter in pixel_t for the blinking
	push	ra
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	li	t4, 25
	sw	t4, pixel_t(s0)
	pop	ra
	jr	ra
	
flipto0:
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	li	s7, 0
	sw	s7, pixel_b(s0)
	lw	t4, pixel_t(s0)
	sub	t4, t4, 1
	sw	t4, pixel_t(s0)
	j	continue
	
flipto1:
	li	a0, 0
	jal	pixel_get_element
	move	s0, v0
	li	s7, 1
	sw	s7, pixel_b(s0)
	lw	t4, pixel_t(s0)
	sub	t4, t4, 1
	sw	t4, pixel_t(s0)
	j	continue

# -------------------------------------------------------------------------------------------------

draw_horizontal_line:
	# prologue
	enter	s0, s1, s2, s3, s4

	# Preserve all input parameters
	move	s0, a0					# s0 contains x
	move	s1, a1					# s1 contains y
	move	s2, a2					# s2 contains size
	move	s3, a3					# s3 contains colour

	li	s4, 0					# s4 contains i, initialize i=0
_draw_horizontal_line_loop:
	bge	s4, s2, _draw_horizontal_line_exit	# Check if i >= size
	# for loop implementation
	add	a0, s0, s4				# Calculate x-coordinate = x+i
	move	a1, s1					# Calculate y-coordinate is fixed
	move	a2, s3					# Colour set by user
	jal	display_set_pixel
	inc	s4					# Increment i
	j	_draw_horizontal_line_loop
_draw_horizontal_line_exit:
	# epilogue
	leave	s0, s1, s2, s3, s4

# -------------------------------------------------------------------------------------------------
