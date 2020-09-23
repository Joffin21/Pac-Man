Joffin Manjaly
jom193

So according to the rubric, I think I have satisfied everything except making the MacGuffins shiny. I know it is pretty easy, I'm just scared that with the time I have left I am bound to mess something up that I cannot fix rather than be able to properly earn the one point. 

Game flow: 
For as much as I have played I haven't really noticed any crashes, I think it is fine. The game does not start when the player hits a key. The game starts as soon as you hit run, so that gives the enemies a slight head start on picking up the MacGuffins. 

Arena is properly set up.
Lives and Score is kept track of at the bottom. One thing to not, however, is that after losing the last life, The bottom continues to display "LVS: 1" Instead of actually decreasing it to 0. 

Player: 
Everything in the rubric under player should be properly satisfied. I don't think there is anything to note there. I mention this later in these notes, but am going to write it under player as well. In the rubric, it says "Player loses life when it crashes into an enemy," which is exactly what happens. But if an enemy crashes into the player, then no life is lost. For example, if the player is going up and an enemy is going to hit the player from the right, the enemy will bounce back and no damage will be taken to the player. The only way the player loses damage is if he hits the enemy. 

Enemies: 
Here are when things get a little funky. There are 3 enemies that do work in the beginning. They can all move and change directions. They do only walk in empty spaces.
--CHASING:: 
I have attached two files. The default file is update_enemy.asm. If you run the code normally, it should use this asm. This is the one where the enemies chase the player for the most part. There are some odd decisions they take at times, and they may get stuck unless the player moves somewhere else, but they are actively chasing the player. The other file I have put in folder is update_enemy2.asm. This was the file with the code before the enemies chase the player. So here, you can see the enemy move randomly. If you want to test between the two files, just set the file you want to use as update_enemy.asm and then move the other file out of the folder. I have ".globl enemy_update" commented out on the one that isn't being used, so if you want to switch files make sure to swap the comment as there will be an error. 
--DAMAGE FROM ENEMIES:!!:
The enemies can't hurt you if they touch you. This is probably one of the biggest flaws of the game. The way I coded the game, if you run into an enemy you will take damage, but if an enemy runs into you, no damage will be taken. Honestly, this game should seem very hard as the enemies run to you before you can do much, but the most they can do is trap you unless you try to go through them and lose a life on purpose.

MacGuffins: 
MacGuffins are placed on the board using a matrix. Both players and enemies pick them up as they should. The MacGuffins sadly are not shiny/animated. This is the one thing I did not attempt to do. 

Game Ending:
There are two ways to end the game. (1) Either all the MacGuffins are picked up or (2) all 3 lives have been lost. 
(1) With the chasing enemies, this is really difficult to test. Honestly, I feel like its impossible to win with chasing enemies because they get to you to quickly. You would either have to adjust the code so that you prevent the enemies from updating in "thegame.asm" or you could switch the update_enemy.asm file so that you have the random enemies and can go around picking up the MacGuffins with ease. 
(2) I believe this works properly. I set it to 3 lives. My interpretation of that was that: if you hit the enemy 3 times, the 3rd time you hit the enemy the game would end. I don't know if you would consider that 2 or 3 lives, but I considered it 3. Basically you can hit the enemy 2 times and keep playing, but the 3rd time, it would be game over. I also already mentioned how the "lives" at the bottom will say 3, 2, 1, but won't decrease to 0 after that. 

Other notable things:
When the game ends after collecting the MacGuffins, you can tell by the characters all disappearing from the screen.
When the game ends after dying 3 times, you can tell because the game stops but nothing on the display changes. There isn't a formal "Game Over" or "Congrats! You Won!" but the game does end and the points will be displayed on the bottom of the screen.  

When the player becomes invincible, he blinks as he is supposed to. I have the enemy look for an open space so he can move there. The frame that the player is invisible, the enemy can technically move into him. This seems a little problematic, but I haven't had the game crash or my player get stuck when this is happening. Its just a little odd. 