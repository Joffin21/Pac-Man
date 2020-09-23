## This file implements the functions that display the pixels based on the model

# Include the convenience file so that we save some typing! :)
.include "convenience.asm"
# We will need to access the pixel model, include the structure offset definitions
.include "enemy_struct.asm"
# Include the game settings file with the board settings! :)
.include "game_settings.asm"

.data
player:	.byte
	4  0  4  0  4
	0  4  5  4  0
	4  4  5  4  4
	0  4  5  4  0
	4  0  0  0  4

# This function needs to be called by other files, so it needs to be global
.globl enemy_draw

.text
# void pixel_update()
#	1. This function goes through the array of pixels and for each
#		1.1. Gets its (x, y) coordinates
#		1.2. Prints it in the display using function display_set_pixel (display.asm)
#			1.2.1. If the pixel is not selected, print it using some color (Not COLOR_BLACK, as this is the background color)
#			1.2.2. If the pixel is selected, print it using another color
enemy_draw:
	enter 	s0
	# Your code goes in here
	li 	s0, 0

pixel_draw_loop:
	bge 	s0, 3, pixel_draw_exit
	move 	a0, s0
	jal 	enemy_get_element

	#li	t0, 50
	#li	t1, 45
	#sw	t0, pixel_x(v0)
	#sw	t1, pixel_y(v0)

	lw 	a0, enemy_x(v0)			#Load x
	lw 	a1, enemy_y(v0)			#Load y
	#lw 	t0, pixel_selected(v0)		#Load selected

	#beq 	t0, 0, pixel_draw_not_selected

#	pixel_draw_selected:
#		li 	a2, COLOR_BLUE			# selected pixel is blue
#		j 	pixel_draw_setpixel

#	pixel_draw_not_selected:			# other two are white
#		li	a2, COLOR_WHITE

	startingEnemies:		# Draws the enemy
		la	a2, enemy 		# pointer to the image
		jal	display_blit_5x5

	addi 	s0,s0, 1
	j 	pixel_draw_loop
#	pixel_draw_setpixel:
#		jal	display_set_pixel
#		addi 	s0,s0, 1
#		j 	pixel_draw_loop
pixel_draw_exit:
	leave	s0
