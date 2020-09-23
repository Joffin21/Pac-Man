## This file implements the functions that control the pixels based on the keyboard input

# Include the convenience file so that we save some typing! :)
.include "convenience.asm"
# We will need to access the pixel model, include the structure offset definitions
.include "enemy_struct.asm"

.include "game_settings.asm"  ## NEED THIS FOR THE KEY STUFF

.data
old_frame: .word 0
rand:   	.word 	0

# This function needs to be called by other files, so it needs to be global
#.globl enemy_update



.text
# void pixel_update(current_frame)
#	1. This function goes through the array of pixels and finds the one that is selected (maybe you want to implement this as a different function?)
#	2. If no pixel is selected, then select pixel 0
#	3. Reads the state of the keyboard buttons and move the selected pixel accordingly
#		3.1. The pixel moves up to one pixel up/down and up to one pixel left/right according to the keyboard input.
#		3.2. The pixel must not leave the bounds of the display (check the .eqv in game.asm)
#	4. If the user pressed the action button (B) the current selected pixel is deselected and the next pixel is selected (the array loops around).
enemy_update:
	enter	s0, s1, s2, s3
	# Your code goes in here
	move 	s2, a0

#	jal 	loopEnemies 		# search for the selected pixel or get first pixel if none is selected
#	move 	s1, v0
	li	s1, 0
	loopEnemies:
		bge	s1, 3, pixel_update_return
		move 	a0, s1
		jal 	enemy_get_element
		move	s0, v0
		jal	action

	action:
		li v0, 42
		li a0, 0
		li a1, 4
		syscall
		move	t0, a0



		beq	t0, 0, pixel_update_up
		beq	t0, 1, pixel_update_down
		beq	t0, 2, pixel_update_left
		beq	t0, 3, pixel_update_right

#	jal 	input_get_keys
#	andi 	t0, v0, KEY_UP 			# UP
#	bnez 	t0, pixel_update_up
	#j	pixel_update_up
#	andi 	t0, v0, KEY_DOWN 		# DOWN
#	bnez 	t0, pixel_update_down
	#j	pixel_update_down
#	andi 	t0, v0, KEY_LEFT 		# LEFT
#	bnez 	t0, pixel_update_left
#	andi 	t0, v0, KEY_RIGHT 		# RIGHT
#	bnez 	t0, pixel_update_right
#	andi 	t0, v0, KEY_B 			# B or ACTION
#	bnez 	t0, pixel_update_b

	j 	pixel_update_return


	pixel_update_up:
		lw 	s3, enemy_y(s0) 		# Load y
		lw 	s2, enemy_x(s0) 		# Load X

		move	a0, s2
		move	a1, s3
		sub	a1, a1, 1
		move	t2, s3

		jal	display_get_pixel
		beq	v0, 4, pixel_update_return
		beq	v0, 3, removeGoldU
		bne	v0, 0, try_again
		bne	v0, 3, check1up
		removeGoldU:
			la	t0, wallMatrix
			li	t3, 2
			li	t4, 5
			div	s3, t4
			mflo	t5
			div	s2, t4
			mflo	t6
			mul	t1, t5, 12
			add	t1, t1, t6
			mul	t1, t1, 4
			add	t0, t0, t1
			sb	t3, (t0)
		check1up:
			move	a0, s2
			move	a1, s3
			sub	a1, a1, 1
			sub	a0, a0, 2
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		check2up:
			move	a0, s2
			move	a1, s3
			sub	a1, a1, 1
			add	a0, a0, 2
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		dontcheckWallUp:
			addi 	t2,t2,-1 			# y-1
			blt 	t2, 5, pixel_update_return 	# cant be less than 0
			sw 	t2, enemy_y(s0)
			inc	s1
			j 	loopEnemies

	pixel_update_down:
		lw 	s3, enemy_y(s0) 			# Load y
		lw 	s2, enemy_x(s0) 		# Load X

		move	a0, s2
		move	a1, s3
		add	a1, a1, 5
		move	t2, s3

		jal	display_get_pixel
		beq	v0, 4, pixel_update_return
		beq	v0, 3, removeGoldD
		bne	v0, 0, try_again
		bne	v0, 3, check1down
		removeGoldD:
			la	t0, wallMatrix
			li	t3, 2
			li	t4, 5
			div	s3, t4
			mflo	t5
			add	t5, t5, 1
			div	s2, t4
			mflo	t6
			mul	t1, t5, 12
			add	t1, t1, t6
			mul	t1, t1, 4
			add	t0, t0, t1
			sb	t3, (t0)
		check1down:
			move	a0, s2
			move	a1, s3
			add	a1, a1, 5
			sub	a0, a0, 2
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		check2down:
			move	a0, s2
			move	a1, s3
			add	a1, a1, 5
			add	a0, a0, 2
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		dontcheckWallDown:
			addi 	t2,t2,1 				# y+1
			bge 	t2, 46, pixel_update_return 	# cant be greater than height of display
			sw 	t2, enemy_y(s0)
			inc 	s1
			j 	loopEnemies

	pixel_update_left:
		lw 	s3, enemy_x(s0) 		# Load X
		lw 	s2, enemy_y(s0) 			# Load y

		move	a0, s3
		move	a1, s2
		sub	a0, a0, 3
		add	a1, a1, 2
		move	t2, s3

		jal	display_get_pixel
		beq	v0, 4, pixel_update_return
		beq	v0, 3, removeGoldL
		bne	v0, 0, try_again
		bne	v0, 3, check1left
		removeGoldL:
			la	t0, wallMatrix
			li	t3, 2
			li	t4, 5
			div	s3, t4
			mflo	t6
			div	s2, t4
			mflo	t5
			mul	t1, t5, 12
			add	t1, t1, t6
			mul	t1, t1, 4
			add	t0, t0, t1
			sb	t3, (t0)
		check1left:
			move	a0, s3
			move	a1, s2
			sub	a0, a0, 3
			add	a1, a1, 4
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		check2left:
			move	a0, s3
			move	a1, s2
			sub	a0, a0, 3
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		dontcheckWallLeft:
			addi 	t2,t2,-1 			# x-1
			blt 	t2, 5, pixel_update_return 	# cant be less than 0
			sw 	t2, enemy_x(s0)
			inc	s1
			j 	loopEnemies

	pixel_update_right:
		lw 	s3, enemy_x(s0) 			# Load x
		lw 	s2, enemy_y(s0) 			# Load y

		move	a0, s3
		move	a1, s2
		add	a0, a0, 3
		add	a1, a1, 2
		move	t2, s3

		jal	display_get_pixel
		beq	v0, 4, pixel_update_return
		beq	v0, 3, removeGoldR
		bne	v0, 0, try_again
		bne	v0, 3, check1right
		removeGoldR:
			la	t0, wallMatrix
			li	t3, 2
			li	t4, 5
			div	s3, t4
			mflo	t6
			add	t6, t6, 1
			div	s2, t4
			mflo	t5
			mul	t1, t5, 12
			add	t1, t1, t6
			mul	t1, t1, 4
			add	t0, t0, t1
			sb	t3, (t0)
		check1right:
			move	a0, s3
			move	a1, s2
			add	a0, a0, 3
			add	a1, a1, 4
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		check2right:
			move	a0, s3
			move	a1, s2
			add	a0, a0, 3
			jal	display_get_pixel
			beq	v0, 4, pixel_update_return
			bne	v0, 0, try_again
		dontcheckWallRight:
			addi 	t2,t2,1 				# x+1
			bge 	t2, 51, pixel_update_return 	# cant be greater than width of display
			sw 	t2, enemy_x(s0)
			inc	s1
			j 	loopEnemies

	# pixel_update_b:
	# 	lw 	t0, old_frame 			# get last frame count
	# 	sub 	t0, s2, t0
	# 	blt 	t0, 60, pixel_update_return 	# if < 60, do nothing
	# 	sw 	s2, old_frame 			# update frame number
	#
	# 	sw 	zero, pixel_selected(s0)
	# 	addi 	s1, s1, 1 			# select next pixel
	# 	blt 	s1, 3, set_select 		# if pixel < 3, set as selected
	# 	li 	s1, 0

	# set_select:
	# 	move 	a0, s1 				# use found index
	# 	jal 	pixel_get_element
	# 	li 	t0, 1
	# 	sw	t0, pixel_selected(v0) 		# select next pixel



try_again:
	j	loopEnemies

pixel_update_return:				# used when going out of bounds
	leave 	s0, s1, s2, s3





#search for a selected pixel
# loopEnemies:
# 	enter 	s0
# 	li 	s0, 0
#
# pixel_search_loop:
# 	bge 	s0, 3, pixel_search_exit 	# if we processed the pixels, stop
# 	move 	a0, s0
# 	jal 	enemy_get_element
# 	#j	pixel_search_return
# 	#lw 	t0, pixel_selected($v0)
# 	#bne 	t0, 0,pixel_search_return 	# if is selected, return
# 	#addi 	s0,s0, 1
# 	#j 	pixel_search_loop
#
# #pixel_search_exit:
# #	li 	s0, 0 				# if no pixel is selected, return the first one
# #	move 	a0, s0
# #	jal 	pixel_get_element
# #	li 	t0, 1
# #	sw 	t0, pixel_selected(v0)
#
# pixel_search_return:				#ending
# 	move 	v0, s0
# 	leave	s0
