## This file only defines .eqv so that it can be included by other files

.eqv	enemy_x		0 # This is the offset of variable pixel_x
.eqv	enemy_y		4 # This is the offset of variable pixel_y
.eqv	canU		8 # These next 4 will let me know if the enemy CAN move either up, down, left or right
.eqv	canD		12 
.eqv	canL		16
.eqv	canR		20
.eqv	distU		24 # These next 4 tell me the updated distace (if the enemy moves UP 1, this stores the new manhattan distance between enemy and player)
.eqv	distD		28
.eqv	distL		32
.eqv	distR		36

#.eqv	pixel_design	8 # This is the offset of variable pixel selected
