local board_width = 640 -- in pixels
local board_size = 16 -- in cells

local cell_size = board_width/board_size
local cell_padding = 2

local mine_count = 40

local board = {}
local hints = {}
local revealed = {}
local flagged = {}

local total_revealed = 0
local flagged_count = 0

local lost = false

local font

local palette = {}
local palettes = {
	normal_palette = {
		unrevealed = {0.11, 0.11, 0.11},
		revealed = {0.2, 0.2, 0.2},
		hint = {1, 1, 1, 0.87},
		mine = {0.69, 0, 0.13},
		flag = {0.38, 0, 0.93},
		background = {0.07, 0.07, 0.07}
	},
	win_palette = {
		unrevealed = {0.11, 0.19, 0.11},
		revealed = {0.2, 0.33, 0.2},
		hint = {1, 1, 1, 0.87},
		mine = {0.69, 0, 0.13},
		flag = {0.38, 0.22, 0.93},
		background = {0.07, 0.07, 0.07}
	},
	lose_palette = {
		unrevealed = {0.16, 0.11, 0.11},
		revealed = {0.3, 0.2, 0.2},
		hint = {1, 1, 1, 0.87},
		mine = {0.69, 0, 0.13},
		flag = {0.69, 0, 0.93},
		background = {0.07, 0.07, 0.07}
	}
}


function updateHints(i, j)
	if i+1 <= board_size then
		hints[i+1][j] = hints[i+1][j] + 1
		if j+1 <= board_size then
			hints[i+1][j+1] = hints[i+1][j+1] + 1
		end
		if j-1 >= 1 then
			hints[i+1][j-1] = hints[i+1][j-1] + 1
		end
	end
	if j+1 <= board_size then
		hints[i][j+1] = hints[i][j+1] + 1
	end
	if j-1 >= 1 then
		hints[i][j-1] = hints[i][j-1] + 1
	end
	if i-1 >= 1 then
		hints[i-1][j] = hints[i-1][j] + 1
		if j+1 <= board_size then
			hints[i-1][j+1] = hints[i-1][j+1] + 1
		end
		if j-1 >= 1 then
			hints[i-1][j-1] = hints[i-1][j-1] + 1
		end
	end
end


function updateTitle()
	if lost then
		love.window.setTitle('Mine Sweeper - GAME OVER - Press R to restart')
	elseif won() then
		love.window.setTitle('Mine Sweeper - YOU WIN - Press R to restart')	
	else
		love.window.setTitle(string.format('Mine Sweeper - LEFT: %d - REVEALED: %d', mine_count - flagged_count, total_revealed))
	end
end


function updatePalette()
	if lost then 
		palette = palettes.lose_palette
	elseif won() then
		palette = palettes.win_palette
	end
end


function init()

	total_revealed = 0
	flagged_count = 0

	lost = false

	for i = 1, board_size do
		board[i] = {}
		revealed[i] = {}
		hints[i] = {}
		flagged[i] = {}
		for j = 1, board_size do
			board[i][j] = false
			revealed[i][j] = false
			hints[i][j] = 0
			flagged[i][j] = false
		end
	end

	local random_x
	local random_y
	local mines_left = mine_count
	while mines_left > 0 do
		random_x = love.math.random(board_size)
		random_y = love.math.random(board_size)
		if not board[random_x][random_y] then
			board[random_x][random_y] = true
			mines_left = mines_left - 1
			updateHints(random_x, random_y)
		end
	end

	palette = palettes.normal_palette

	updateTitle()
end


function love.load()
	love.window.setMode(board_size*cell_size, board_size*cell_size, {resizable=false})

	font = love.graphics.newFont(cell_size - cell_padding*2)
	love.graphics.setFont(font)

	init()
end


function love.update(dt)

end


function love.draw()
	-- background
	love.graphics.setColor(palette.background)
	love.graphics.rectangle('fill', 0, 0, board_width, board_width)

	-- unrevealed cells
	love.graphics.setColor(palette.unrevealed)
	for i = 0, (board_size-1) do
		for j = 0, (board_size-1) do
			if not revealed[i+1][j+1] then
				love.graphics.rectangle('fill', i*cell_size + cell_padding, j*cell_size + cell_padding, cell_size - cell_padding*2, cell_size - cell_padding*2)
			end
		end
	end

	-- revealed cells
	love.graphics.setColor(palette.revealed)
	for i = 0, (board_size-1) do
		for j = 0, (board_size-1) do
			if revealed[i+1][j+1] then
				love.graphics.rectangle('fill', i*cell_size + cell_padding, j*cell_size + cell_padding, cell_size - cell_padding*2, cell_size - cell_padding*2)
			end
		end
	end

	-- print hints
	love.graphics.setColor(palette.hint)
	for i = 0, (board_size-1) do
		for j = 0, (board_size-1) do
			if revealed[i+1][j+1] and board[i+1][j+1]==false and hints[i+1][j+1]~=0 then
				love.graphics.print(hints[i+1][j+1], i*cell_size + cell_size/2 - font:getWidth(hints[i+1][j+1])/2, j*cell_size + cell_size/2 - font:getHeight(hints[i+1][j+1])/2, 0, 1)
			end
		end
	end

	-- print revealed mines
	love.graphics.setColor(palette.mine)
	for i = 0, (board_size-1) do
		for j = 0, (board_size-1) do
			if revealed[i+1][j+1] and board[i+1][j+1] then
				love.graphics.circle('fill', i*cell_size + cell_size/2, j*cell_size + cell_size/2, (cell_size - cell_padding*3)/2)
			end
		end
	end

	-- print flags
	love.graphics.setColor(palette.flag)
	for i = 0, (board_size-1) do
		for j = 0, (board_size-1) do
			if not revealed[i+1][j+1] and flagged[i+1][j+1] then
				love.graphics.circle('fill', i*cell_size + cell_size/2, j*cell_size + cell_size/2, (cell_size - cell_padding*3)/2)
			end
		end
	end	
end


function toCell(offset)
	return math.ceil(offset/cell_size)
end


function revealSurrounding(i, j)
	if i+1 <= board_size then
		if not revealed[i+1][j] and not flagged[i+1][j] then
			reveal(i+1, j)
		end
		if j+1 <= board_size and not revealed[i+1][j+1] and not flagged[i+1][j+1] then
			reveal(i+1, j+1)
		end
		if j-1 >= 1 and not revealed[i+1][j-1] and not flagged[i+1][j-1] then
			reveal(i+1, j-1)
		end
	end
	if j+1 <= board_size and not revealed[i][j+1] and not flagged[i][j+1] then
		reveal(i, j+1)
	end
	if j-1 >= 1 and not revealed[i][j-1] and not flagged[i][j-1] then
		reveal(i, j-1)
	end
	if i-1 >= 1 then
		if not revealed[i-1][j] and not flagged[i-1][j] then
			reveal(i-1, j)
		end
		if j+1 <= board_size and not revealed[i-1][j+1] and not flagged[i-1][j+1] then
			reveal(i-1, j+1)
		end
		if j-1 >= 1 and not revealed[i-1][j-1] and not flagged[i-1][j-1] then
			reveal(i-1, j-1)
		end
	end
end


function reveal(i, j)
	revealed[i][j] = true
	total_revealed = total_revealed + 1
	if board[i][j] then
		lost = true
		revealMines()
	elseif hints[i][j] == 0 then
		revealSurrounding(i, j)
	end
end


function getQuantitySurroundingFlags(i, j)
	surroundingFlags = 0
	if i+1 <= board_size then
		if flagged[i+1][j] then
			surroundingFlags = surroundingFlags + 1
		end
		if j+1 <= board_size and flagged[i+1][j+1] then
			surroundingFlags = surroundingFlags + 1
		end
		if j-1 >= 1 and flagged[i+1][j-1] then
			surroundingFlags = surroundingFlags + 1
		end
	end
	if j+1 <= board_size and flagged[i][j+1] then
		surroundingFlags = surroundingFlags + 1
	end
	if j-1 >= 1 and flagged[i][j-1] then
		surroundingFlags = surroundingFlags + 1
	end
	if i-1 >= 1 then
		if flagged[i-1][j] then
			surroundingFlags = surroundingFlags + 1
		end
		if j+1 <= board_size and flagged[i-1][j+1] then
			surroundingFlags = surroundingFlags + 1
		end
		if j-1 >= 1 and flagged[i-1][j-1] then
			surroundingFlags = surroundingFlags + 1
		end
	end
	return surroundingFlags
end


function aoeReveal(i, j)
	if getQuantitySurroundingFlags(i, j) == hints[i][j] then
		revealSurrounding(i, j)
	end
end


function revealMines()
	for i = 1, board_size do
		for j = 1, board_size do
			if board[i][j] and not flagged[i][j] then
				revealed[i][j] = true
			end
		end
	end
end


function won()
	return total_revealed == board_size*board_size - mine_count
end


function love.mousereleased(x, y, button, istouch)
	if not lost then
		i = toCell(x)
		j = toCell(y)
		if button == 1 and not flagged[i][j] and not revealed[i][j] then
			reveal(i, j)
		elseif button == 2 and not revealed[i][j] then
			if flagged[i][j] then
				flagged[i][j] = false
				flagged_count = flagged_count - 1
			else
				flagged[i][j] = true
				flagged_count = flagged_count + 1
			end
		elseif button == 3 and hints[i][j]~=0 and not board[i][j] then
			aoeReveal(i, j)
		end
		updateTitle()
		updatePalette()
	end
end


function love.keyreleased(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'r' then
		init()
	end
end
