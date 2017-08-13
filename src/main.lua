-- The size of the game board, in **pixels**
GAME_SIZE_PX = 550
-- The size of a "pixel" - really a point or block
-- TODO: rename
PIXEL_SIZE   = 10
-- Game board size in **points**
GAME_SIZE_PT = math.floor(GAME_SIZE_PX / PIXEL_SIZE)
-- Center coordinate of the game board (points)
CENTER_POS   = math.floor(GAME_SIZE_PT / 2)

-- Inital snek length
SNEK_SIZE_INIT = 10

-- How many pixels should the snek grow by when he eats
FOOD_GROWTH = 3

-- How often should we spawn food (%/100)
FOOD_SPAWN_CHANCE = 0.05

-- How many food pixels are allowed to be in play at once?
FOOD_LIMIT = 5

-- Directions "enum", for easier-to-read code
Directions       = {}
Directions.UP    = 1
Directions.RIGHT = 2
Directions.DOWN  = 3
Directions.LEFT  = 4

-- Directions pixel offset "enum"
DirectionsValues = {
	{x = 0,  y = -1},
	{x = 1,  y = 0},
	{x = 0,  y = 1},
	{x = -1, y = 0},
}

function love.load()
	-- Set this here instead of the config
	-- TODO: see if I can access LOVE config vars outside of conf.lua
	love.window.setMode(GAME_SIZE_PX, GAME_SIZE_PX, {
		resizable = false,
	})

	-- Initialize our essentail vars
	snek = {}
	food = {}

	timeAcc = 0
	-- Current game tick speed, in seconds
	-- TODO: make constant? use speed manipulation code?
	gameSpeed = 0.08333
	gameSpeedDelta = 0
	curDirection = Directions.UP
	curDirectionFrame = curDirection

	snekLen = SNEK_SIZE_INIT

	foodEaten = 0

	-- Place the starting pixel (head) at the center of the game board
	snek[1] = {x = CENTER_POS, y = CENTER_POS, lifetime = snekLen}

	gameOver = false

	score = 0
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(string.format("SCORE: %d", score), 10, 10, 0, 2)

	if gameOver then
		love.graphics.setColor(255, 100, 100)
		love.graphics.print("GAME OVER - PRESS ENTER", 10, 50, 0, 2)
	end

	-- Draw the snek
	for i, pos in ipairs(snek) do
		local x = pos.x * PIXEL_SIZE
		local y = pos.y * PIXEL_SIZE

		if gameOver then
			-- Ded snek is red snek
			love.graphics.setColor(255, 100, 100)
		else
			love.graphics.setColor(0, 150, 0)
		end

		-- Head is a different coller
		if i == #snek then
			if gameOver then
				-- Ded snek is red snek
				love.graphics.setColor(255, 150, 150)
			else
				love.graphics.setColor(0, 200, 0)
			end
		end

		love.graphics.rectangle("fill", x, y, PIXEL_SIZE, PIXEL_SIZE)
	end

	-- Draw all food pixels
	for i, pos in ipairs(food) do
		local x = pos.x * PIXEL_SIZE
		local y = pos.y * PIXEL_SIZE

		love.graphics.setColor(255, 25, 25)
		love.graphics.rectangle("fill", x, y, PIXEL_SIZE, PIXEL_SIZE)
		love.graphics.setColor(255, 255, 255)
	end
end

function love.update(dt)
	if gameOver then
		if love.keyboard.isDown('return') then
			love.load()
		end

		return
	end

	-- Keep track of time passed for game ticks
	timeAcc = timeAcc + dt
	gameSpeedDelta = gameSpeedDelta + dt

	-- Keep track of the direction chosen on this frame, but don't override the actual movement direction yet
	-- Prevents the snek from moving on top of itself, as I found out could happen before
	if love.keyboard.isDown('up') and curDirection ~= Directions.DOWN then
		curDirectionFrame = Directions.UP
	elseif love.keyboard.isDown('right') and curDirection ~= Directions.LEFT then
		curDirectionFrame = Directions.RIGHT
	elseif love.keyboard.isDown('left') and curDirection ~= Directions.RIGHT then
		curDirectionFrame = Directions.LEFT
	elseif love.keyboard.isDown('down') and curDirection ~= Directions.UP then
		curDirectionFrame = Directions.DOWN
	end

	-- Game speed changing code - needs refactoring
	--[[ if gameSpeedDelta > 5 then
		gameSpeed = gameSpeed / 2
		gameSpeedDelta = 0
	end ]]--

	-- "Frame" limiting - only update values once every ~gameSpeed seconds
	if timeAcc > gameSpeed then
		-- Reset the timeAcc for next tick
		timeAcc = 0

		curDirection = curDirectionFrame

		if foodEaten == 0 then
			for k, block in ipairs(snek) do
				block.lifetime = block.lifetime - 1
			end
		else
			snekLen = snekLen + 1
			foodEaten = foodEaten - 1
		end

		-- If there's less than 5 food on the table and RNG says we should spawn something...
		if math.random() < FOOD_SPAWN_CHANCE and #food < FOOD_LIMIT then
			local foodX, foodY
			local validFoodPos = true

			foodX = love.math.random(0, GAME_SIZE_PT - 1)
			foodY = love.math.random(0, GAME_SIZE_PT - 1)

			-- Don't let food spawn on top of snek
			for _, block in ipairs(snek) do
				if foodX == block.x and foodY == block.y then
					validFoodPos = false
					break
				end
			end

			-- If the food pos isn't on the snek, spawn it
			-- Otherwise, just ignore it - the RNG will trigger this again soon
			if validFoodPos then
				food[#food + 1] = {x = foodX, y = foodY}
			end
		end

		local head = snek[#snek]

		-- If the snek is touching a wall, they lose
		if head.y == -1 or head.x == -1 or head.x == GAME_SIZE_PT or head.y == GAME_SIZE_PT then
			gameOver = true
			return
		end

		-- Store the new head position - shift old head by curDirection's coordinate offsets and store pixel lifetime
		-- Credits to Fizzy for the idea of lifetime values instead of trying to keep track of every pixel and moving them around.
		-- That was a stupid idea, me.
		snek[#snek + 1] = {x = head.x + DirectionsValues[curDirection].x, y = head.y + DirectionsValues[curDirection].y, lifetime = snekLen}

		-- Remove old tail pixel
		if snek[1].lifetime == 0 then
			table.remove(snek, 1)
		end

		head = snek[#snek]

		-- If the snek is touching itself, they lose
		for i = 1, #snek do
			for j = 1, #snek do
				if i ~= j and snek[i].x == snek[j].x and snek[i].y == snek[j].y then
					gameOver = true
					break
				end
			end
		end

		-- But if the snek is touching food, it grows!
		for i = 1, #food do
			if food[i].x == head.x and food[i].y == head.y then
				foodEaten = foodEaten + FOOD_GROWTH
				score = score + 1
				table.remove(food, i)
				break
			end
		end
	end
end