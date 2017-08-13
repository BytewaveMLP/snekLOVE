GAME_SIZE_PX = 550
PIXEL_SIZE   = 10
GAME_SIZE_PT = math.floor(GAME_SIZE_PX / PIXEL_SIZE)
CENTER_POS   = math.floor(GAME_SIZE_PT / 2)
PIXEL_DIFF   = math.floor(PIXEL_SIZE / 2)
SNEK_SIZE_INIT = 5

INDEX_X        = 1
INDEX_Y        = 2
INDEX_LIFETIME = 3

FOOD_GROWTH = 3

Directions       = {}
Directions.UP    = 1
Directions.RIGHT = 2
Directions.DOWN  = 3
Directions.LEFT  = 4

DirectionsValues = {
	{x = 0,  y = -1},
	{x = 1,  y = 0},
	{x = 0,  y = 1},
	{x = -1, y = 0},
}

function love.load()
	love.window.setMode(GAME_SIZE_PX, GAME_SIZE_PX, {
		resizable = false,
	})

	snek = {}
	food = {}

	timeAcc = 0
	gameSpeed = 0.08333
	gameSpeedDelta = 0
	curDirection = Directions.UP
	curDirectionFrame = curDirection

	snekLen = 10

	foodEaten = 0

	local diff = -math.floor(SNEK_SIZE_INIT / 2)

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

	for i, pos in ipairs(snek) do
		local x = pos.x * PIXEL_SIZE
		local y = pos.y * PIXEL_SIZE

		if gameOver then
			love.graphics.setColor(255, 100, 100)
		else
			love.graphics.setColor(0, 150, 0)
		end


		if i == #snek then
			if gameOver then
				love.graphics.setColor(255, 150, 150)
			else
				love.graphics.setColor(0, 200, 0)
			end
		end

		love.graphics.rectangle("fill", x, y, PIXEL_SIZE, PIXEL_SIZE)
	end

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

	timeAcc = timeAcc + dt
	gameSpeedDelta = gameSpeedDelta + dt

	if love.keyboard.isDown('up') and curDirection ~= Directions.DOWN then
		curDirectionFrame = Directions.UP
	elseif love.keyboard.isDown('right') and curDirection ~= Directions.LEFT then
		curDirectionFrame = Directions.RIGHT
	elseif love.keyboard.isDown('left') and curDirection ~= Directions.RIGHT then
		curDirectionFrame = Directions.LEFT
	elseif love.keyboard.isDown('down') and curDirection ~= Directions.UP then
		curDirectionFrame = Directions.DOWN
	end

	--[[ if gameSpeedDelta > 5 then
		gameSpeed = gameSpeed / 2
		gameSpeedDelta = 0
	end ]]--

	if timeAcc > gameSpeed then
		curDirection = curDirectionFrame

		if foodEaten == 0 then
			for k, block in ipairs(snek) do
				block.lifetime = block.lifetime - 1
			end
		else
			snekLen = snekLen + 1
			foodEaten = foodEaten - 1
		end

		if math.random() < 0.05 and #food <= 5 then
			local foodX, foodY
			local validFoodPos = false

			while not validFoodPos do
				foodX = love.math.random(1, GAME_SIZE_PT)
				foodY = love.math.random(1, GAME_SIZE_PT)

				validFoodPos = true

				for _, block in ipairs(snek) do
					if foodX == block.x and foodY == block.y then
						validFoodPos = false
						break
					end
				end
			end

			food[#food + 1] = {x = foodX, y = foodY}
		end

		timeAcc = 0

		local head = snek[#snek]

		if head.y == -1 or head.x == -1 or head.x == GAME_SIZE_PT or head.y == GAME_SIZE_PT then
			gameOver = true
			return
		end

		snek[#snek + 1] = {x = head.x + DirectionsValues[curDirection].x, y = head.y + DirectionsValues[curDirection].y, lifetime = snekLen}

		if snek[1].lifetime == 0 then
			table.remove(snek, 1)
		end

		head = snek[#snek]

		for i = 1, #snek do
			for j = 1, #snek do
				if i ~= j and snek[i].x == snek[j].x and snek[i].y == snek[j].y then
					gameOver = true
					break
				end
			end
		end

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