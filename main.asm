.include "convenience.asm"
.include "game_settings.asm"
.include "player_struct.asm"
.include "enemy_struct.asm"

.globl main
main:
	# set up anything you need to here,
	# and wait for the user to press a key to start.
	
	
	enter 	s0
	li 	s0, 0
	
	move 	a0, s0				
	jal 	pixel_get_element		#get player
	li	t0, 50				#starting x
	li	t1, 45				#starting y
	li	t2, 3				#starting lives
	sw	t0, pixel_x(v0)			#store these values
	sw	t1, pixel_y(v0)
	sw	t2, pixel_l(v0)
	li	t2, 1				# this is the binary, so 1 means its not blinking 0 means it is, so we start with 1
	sw	t2, pixel_b(v0)
	li 	t2, 0				# this is the counter if we start blinking, we set it to 0, because we don't need to start the counter until we need it
	sw	t2, pixel_t(v0)
	
	
	move 	a0, s0
	jal 	enemy_get_element
	li	t0, 5				#starting x				
	li 	t1, 5				#starting y
	sw	t0, enemy_x(v0)
	sw	t1, enemy_y(v0)
	
	li	s0, 1
	move 	a0, s0
	jal 	enemy_get_element
	li	t0, 35				#starting x
	li 	t1, 5				#starting y
	sw	t0, enemy_x(v0)
	sw	t1, enemy_y(v0)
	
	li	s0, 2
	move 	a0, s0
	jal 	enemy_get_element
	li	t0, 5				#starting x
	li 	t1, 15				#starting y
	sw	t0, enemy_x(v0)
	sw	t1, enemy_y(v0)
	
	

        jal     game				# first set up is done now to the game. 
	exit
