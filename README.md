# match3
GD50 Match-3 clone, implemented in Lua with LÖVE engine. 

**Extra features added to the original :**
* Implemented time addition on matches, such that scoring a match extends the timer by 1 second per tile in a match.
* Ensured Level 1 starts just with simple flat blocks (the first of each color in the sprite sheet), with later levels generating the blocks with patterns on them (like the triangle, cross, etc.). These worth more points.
* Created random shiny versions of blocks that will destroy an entire row on match, granting points for each block in the row.
* Swapping is only allowed when it results in a match. If there are no matches available to perform, reset the board.

Video link : https://vimeo.com/342043508
