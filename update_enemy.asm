## This file implements the functions that control the pixels based on the keyboard input

# Include the convenience file so that we save some typing! :)
.include "convenience.asm"
# We will need to access the pixel model, include the structure offset definitions
.include "enemy_struct.asm"
.include "player_struct.asm"
.include "game_settings.asm"  ## NEED THIS FOR THE KEY STUFF

.data
old_frame: .word 0
rand:   	.word 	0

# This function needs to be called by other files, so it needs to be global
.globl enemy_update



.text
# void pixel_update(current_frame)
#	1. This function goes through the array of pixels and finds the one that is selected (maybe you want to implement this as a different function?)
#	2. If no pixel is selected, then select pixel 0
#	3. Reads the state of the keyboard buttons and move the selected pixel accordingly
#		3.1. The pixel moves up to one pixel up/down and up to one pixel left/right according to the keyboard input.
#		3.2. The pixel must not leave the bounds of the display (check the .eqv in game.asm)
#	4. If the user pressed the action button (B) the current selected pixel is deselected and the next pixel is selected (the array loops around).
enemy_update:
	enter	s0, s1, s2, s3, s4, s5
	# Your code goes in here
	#move 	s2, a0

#	jal 	loopEnemies 		# search for the selected pixel or get first pixel if none is selected
#	move 	s1, v0
	li	s1, 0
	loopEnemies:			#so we loop through the 3 enemies
		bge	s1, 3, pixel_update_return	# if we went through all of them, then finish updating
		move 	a0, s1
		jal 	enemy_get_element		# gets the info of the enemy we are on
		move	s0, v0
		jal	action

	action:
		jal 	checkDirections			# checks which directions that the enemy can move in

		jal	setDistances		# after checking the directions, we find the distances from enemy to player if it were to move in a certain direction

		jal	minDist			# this is to figure out which direction decreases the distance
						#depending on the previous one, we load the distances that we had set earlier below
		lw	s2, distU(s0)
		lw	s3, distD(s0)
		lw	s4, distL(s0)
		lw	s5, distR(s0)
				# we compare the min distance that we found in minDist and compare it to the variable initialized above to figure out which direciton
		beq	t0, s2, moveU
		beq	t0, s3, moveD
		beq	t0, s4, moveL
		beq	t0, s5, moveR

	j 	pixel_update_return

checkDirections:
	push	ra
	pixel_update_up:		#each direction has 3 checks. For up, it checks the top left corner, the top right corner, and center pixel as well
					#we look at the pixel above all three, and based on what the pixel above is, we take action
		lw 	s3, enemy_y(s0) 		# Load y
		lw 	s2, enemy_x(s0) 		# Load X

		move	a0, s2
		move	a1, s3
		sub	a1, a1, 1
		move	t2, s3

		jal	display_get_pixel
		#beq	v0, 4, pixel_update_return
		beq	v0, 3, check1up		#if the pixel is 3 that means its a MacGuffin, but technically we can still move in that direction
		bne	v0, 0, setnoU		#if we cant move up, then we go to setnoU, which will set that variable canU in the enemy_struct to a 0
		check1up:			#check1 and check2 are the other 2 checks that we need to do
			move	a0, s2
			move	a1, s3
			sub	a1, a1, 1
			sub	a0, a0, 2
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoU
		check2up:
			move	a0, s2
			move	a1, s3
			sub	a1, a1, 1
			add	a0, a0, 2
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoU
			#j	endCheckU
		li	t0, 1			
		sw	t0, canU(s0)			#setting canU to 1 because we CAN move up
		j	pixel_update_down		#go on to the next direction
		setnoU:
			li	t0, 0
			sw	t0, canU(s0)		#setting canU to 0 because we can't move up

		#endCheckU:


	pixel_update_down:
		lw 	s3, enemy_y(s0) 			# Load y
		lw 	s2, enemy_x(s0) 		# Load X

		move	a0, s2
		move	a1, s3
		add	a1, a1, 5
		move	t2, s3

		jal	display_get_pixel
		#beq	v0, 4, pixel_update_return
		beq	v0, 3, check1down
		bne	v0, 0, setnoD
		check1down:
			move	a0, s2
			move	a1, s3
			add	a1, a1, 5
			sub	a0, a0, 2
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoD
		check2down:
			move	a0, s2
			move	a1, s3
			add	a1, a1, 5
			add	a0, a0, 2
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoD
		#	j	endCheckD
		li	t0, 1
		sw	t0, canD(s0)
		j	pixel_update_left
		setnoD:
			li	t0, 0
			sw	t0, canD(s0)

		#endCheckD:


	pixel_update_left:
		lw 	s3, enemy_x(s0) 		# Load X
		lw 	s2, enemy_y(s0) 			# Load y

		move	a0, s3
		move	a1, s2
		sub	a0, a0, 3
		add	a1, a1, 2
		move	t2, s3

		jal	display_get_pixel
		#beq	v0, 4, pixel_update_return
		bne	v0, 0, setnoL
		check1left:
			move	a0, s3
			move	a1, s2
			sub	a0, a0, 3
			add	a1, a1, 4
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoL
		check2left:
			move	a0, s3
			move	a1, s2
			sub	a0, a0, 3
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoL
			#j	endCheckL
		li	t0, 1
		sw	t0, canL(s0)
		j	pixel_update_right
		setnoL:
			li	t0, 0
			sw	t0, canL(s0)

		#endCheckL:


	pixel_update_right:
		lw 	s3, enemy_x(s0) 			# Load x
		lw 	s2, enemy_y(s0) 			# Load y

		move	a0, s3
		move	a1, s2
		add	a0, a0, 3
		add	a1, a1, 2
		move	t2, s3

		jal	display_get_pixel
		#beq	v0, 4, pixel_update_return
		bne	v0, 0, setnoR
		check1right:
			move	a0, s3
			move	a1, s2
			add	a0, a0, 3
			add	a1, a1, 4
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoR
		check2right:
			move	a0, s3
			move	a1, s2
			add	a0, a0, 3
			jal	display_get_pixel
			#beq	v0, 4, pixel_update_return
			bne	v0, 0, setnoR
			#j	endCheckR
		li	t0, 1
		sw	t0, canR(s0)
		pop	ra
		jr	ra
		setnoR:
			li	t0, 0
			sw	t0, canR(s0)
			pop	ra
			jr	ra
		#endCheckR:


setDistances:				# this is to calculate the distances between the player and enemy via manhattan distances
	push	ra

	up:
		lw	t0, canU(s0)
		beq	t0, 0, forceU
		lw 	s2, enemy_x(s0) 		# Load X of enemy
		lw 	s3, enemy_y(s0) 		# Load y of enemy
		sub	s3, s3, 1
		li	a0, 0
		jal	pixel_get_element		
		lw	t2, pixel_x(v0)			#player x
		lw	t3, pixel_y(v0)			#player y
		sub	t4, t3, s3			# subtract the x's
		sub	t5, t2, s2			# subract the y's
		add	t4, t4, t5			# add the x distance and y distance
		mul	t4, t4, t4			#squaring my distance just in case there are negatives
		sw	t4, distU(s0)			# store that
		j	down
		forceU:					# if you can't move in a direction then set the distance to an absurdly high value so it cant be our min distance
			li	t1, 100000
			sw	t1, distU(s0)
	down:
		lw	t0, canD(s0)
		beq	t0, 0, forceD
		lw 	s2, enemy_x(s0) 		# Load X
		lw 	s3, enemy_y(s0) 		# Load y
		add	s3, s3, 1
		li	a0, 0
		jal	pixel_get_element
		lw	t2, pixel_x(v0)
		lw	t3, pixel_y(v0)
		sub	t4, t3, s3
		sub	t5, t2, s2
		add	t4, t4, t5
		mul	t4, t4, t4			#squaring my distance just in case there are negatives
		sw	t4, distD(s0)
		j	left
		forceD:
			li	t1, 100000
			sw	t1, distD(s0)
	left:
		lw	t0, canL(s0)
		beq	t0, 0, forceL
		lw 	s2, enemy_x(s0) 		# Load X
		lw 	s3, enemy_y(s0) 		# Load y
		sub	s2, s2, 1
		li	a0, 0
		jal	pixel_get_element
		lw	t2, pixel_x(v0)
		lw	t3, pixel_y(v0)
		sub	t4, t3, s3
		sub	t5, t2, s2
		add	t4, t4, t5
		mul	t4, t4, t4			#squaring my distance just in case there are negatives
		sw	t4, distL(s0)
		j	right
		forceL:
			li	t1, 100000
			sw	t1, distL(s0)
	right:
		lw	t0, canR(s0)
		beq	t0, 0, forceR
		lw 	s2, enemy_x(s0) 		# Load X
		lw 	s3, enemy_y(s0) 		# Load y
		add	s2, s2, 1
		li	a0, 0
		jal	pixel_get_element
		lw	t2, pixel_x(v0)
		lw	t3, pixel_y(v0)
		sub	t4, t3, s3
		sub	t5, t2, s2
		add	t4, t4, t5
		mul	t4, t4, t4			#squaring my distance just in case there are negatives
		sw	t4, distR(s0)
		j	doneDist
		forceR:
			li	t1, 100000
			sw	t1, distR(s0)
	doneDist:
		pop	ra
		jr	ra

minDist:				# this just checks what the min distance is by comparing all the distances we have
	push	ra
	minU:
		li	t0, 10000
		lw	t1, distU(s0)
		bgt	t1, t0, minD
		move	t0, t1
	minD:
		lw	t1, distD(s0)
		bgt	t1, t0, minL
		move	t0, t1
	minL:
		lw	t1, distL(s0)
		bgt	t1, t0, minR
		move	t0, t1
	minR:
		lw	t1, distR(s0)
		bgt	t1, t0, doneMin
		move	t0, t1
	doneMin:
		pop	ra
		jr	ra


moveU:
	lw 	s3, enemy_y(s0) 		# Load y
	lw 	s2, enemy_x(s0) 		# Load X

	move	a0, s2
	move	a1, s3
	sub	a1, a1, 1
	move	t2, s3

	jal	display_get_pixel
	beq	v0, 4, pixel_update_return
	bne	v0, 3, dontcheckWallUp
	removeGoldU:			# if there is gold then we want to remove the gold and add points
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
	dontcheckWallUp:
		addi 	t2,t2,-1 			# y-1
		blt 	t2, 5, pixel_update_return 	# cant be less than 0
		sw 	t2, enemy_y(s0)			#store new position
		inc	s1
		j 	loopEnemies


moveD:
	lw 	s3, enemy_y(s0) 			# Load y
	lw 	s2, enemy_x(s0) 		# Load X

	move	a0, s2
	move	a1, s3
	add	a1, a1, 5
	move	t2, s3

	jal	display_get_pixel
	beq	v0, 4, pixel_update_return
	bne	v0, 3, dontcheckWallDown
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
	dontcheckWallDown:
	 	addi 	t2,t2,1 				# y+1
	 	bge 	t2, 46, pixel_update_return 	# cant be greater than height of display
	 	sw 	t2, enemy_y(s0)
	 	inc 	s1
	 	j 	loopEnemies

moveL:
	lw 	s3, enemy_x(s0) 		# Load X
	lw 	s2, enemy_y(s0) 			# Load y

	move	a0, s3
	move	a1, s2
	sub	a0, a0, 3
	add	a1, a1, 2
	move	t2, s3

	jal	display_get_pixel
	beq	v0, 4, pixel_update_return
	bne	v0, 3, dontcheckWallLeft
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
	dontcheckWallLeft:
		addi 	t2,t2,-1 			# x-1
		blt 	t2, 5, pixel_update_return 	# cant be less than 0
		sw 	t2, enemy_x(s0)
		inc	s1
		j 	loopEnemies


moveR:
	lw 	s3, enemy_x(s0) 			# Load x
	lw 	s2, enemy_y(s0) 			# Load y

	move	a0, s3
	move	a1, s2
	add	a0, a0, 3
	add	a1, a1, 2
	move	t2, s3

	jal	display_get_pixel
	beq	v0, 4, pixel_update_return
	beq	v0, 3, dontcheckWallRight
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
	dontcheckWallRight:
		addi 	t2,t2,1 				# x+1
		bge 	t2, 51, pixel_update_return 	# cant be greater than width of display
		sw 	t2, enemy_x(s0)
		inc	s1
		j 	loopEnemies



pixel_update_return:				# used when going out of bounds
	leave 	s0, s1, s2, s3, s4, s4





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
