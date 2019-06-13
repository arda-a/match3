--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]
Board = Class {}

MAX_COLOR_NUMBER = 16

local counter = 0
function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level
    
    counter = 0
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            if level == nil then
                level = 1
            end
            -- create a new tile at X,Y with a random color and variety
            -- Ensure Level 1 starts just with simple flat blocks
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(MAX_COLOR_NUMBER), math.random(math.min(level, 6))))
        end
    end

    --There shouldn't be any matches right now, but there should be possible matches.
    while self:calculateMatches() or self:CalculateMatchesForEntireBoard() == false do
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
        counter = counter + 1
        print ( "Initialized again " .. counter .. " times." )
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1

        local hasShinyTile = false

        -- every horizontal tile
        for x = 2, 8 do
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    --check first by going back if any tile is shiny
                    for x2 = x - 1, x - matchNum, -1 do
                        if self.tiles[y][x2].shiny then
                            hasShinyTile = true
                            break
                        end
                    end

                    if hasShinyTile then
                        for i = 1, 8 do
                            --add entire row to matches
                            table.insert(match, self.tiles[y][i])
                        end
                    else
                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    hasShinyTile = false
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            --check if there is a shiny tile in the match
            for x = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then
                    hasShinyTile = true
                    break
                end
            end

            --if any tile is shiny, match all the row
            if hasShinyTile then
                for i = 1, 8 do
                    table.insert(match, self.tiles[y][i])
                end
            else
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end
            table.insert(matches, match)
        end
    end

    --reinitialize
    hasShinyTile = false

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    --check match has a shiny tile
                    for y2 = y - 1, y - matchNum, -1 do
                        if self.tiles[y2][x].shiny then
                            hasShinyTile = true
                        end
                    end
                    --if any tile is shiny, match all the column
                    if hasShinyTile then
                        for i = 1, 8 do
                            table.insert(match, self.tiles[i][x])
                        end
                    else
                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    hasShinyTile = false
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            --check if there is a shiny tile in the match
            for y = 8, 8 - matchNum + 1, -1 do
                if self.tiles[y][x].shiny then
                    hasShinyTile = true
                    break
                end
            end

            --if any tile is shiny, match all the column
            if hasShinyTile then
                for i = 1, 8 do
                    table.insert(match, self.tiles[i][x])
                end
            else
                -- go backwards from end of last row by matchNum
                for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end
            hasShinyTile = false
            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Check the entire board for matches. If there isn't any matches, reset the board.
    Move up,down,left and right to validate.
    Returns true if there is a match, otherwise false.
]]
function Board:CalculateMatchesForEntireBoard()
    for y = 1, 7 do
        for x = 1, 7 do
            if self:trySwapTilesAndCheckMatches(y, x, y, x + 1) or self:trySwapTilesAndCheckMatches(y, x, y + 1, x) then
                return true
            end
        end
    end

    --last row
    for x = 1, 7 do
        if self:trySwapTilesAndCheckMatches(8, x, 8, x + 1) then
            return true
        end
    end

    --last column
    for y = 1, 7 do
        if self:trySwapTilesAndCheckMatches(y, 8, y + 1, 8) then
            return true
        end
    end

    return false
end

--[[
    Try swapping tiles and return true if there is a match, otherwise false.
]]
function Board:trySwapTilesAndCheckMatches(t1_y, t1_x, t2_y, t2_x)
    local tempTile = self.tiles[t1_y][t1_x]
    local tempTile2 = self.tiles[t2_y][t2_x]
    local tempX1 = self.tiles[t1_y][t1_x].gridX
    local tempY1 = self.tiles[t1_y][t1_x].gridY
    local tempX2 = self.tiles[t2_y][t2_x].gridX
    local tempY2 = self.tiles[t2_y][t2_x].gridY

    tempTile.gridX = tempX2
    tempTile.gridY = tempY2
    tempTile2.gridX = tempX1
    tempTile2.gridY = tempY1

    self.tiles[tempTile.gridY][tempTile.gridX] = tempTile
    self.tiles[tempTile2.gridY][tempTile2.gridX] = tempTile2

    local possibleResult = false
    if self:calculateMatches() ~= false then
        possibleResult = true
    end

    --revert temporary swap
    tempTile.gridX = tempX1
    tempTile.gridY = tempY1
    tempTile2.gridX = tempX2
    tempTile2.gridY = tempY2

    self.tiles[tempTile.gridY][tempTile.gridX] = tempTile
    self.tiles[tempTile2.gridY][tempTile2.gridX] = tempTile2

    return possibleResult
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(MAX_COLOR_NUMBER), math.random(math.min(level, 6)))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
