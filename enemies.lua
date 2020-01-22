--Contains all individual enemies and can access them together

enemies_controller = {}
enemies_controller.enemies = {}

function enemies_controller:spawnEnemy(x, y, width, height)
	local enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = width
	enemy.height = height
	enemy.xVelocity = 0
	enemy.yVelocity = 0
	enemy.runSpeed = 20
	enemy.gravity = 550
	enemy.terminalVelocity = 700
	enemy.onGround = false
	enemy.colType = 'Enemy'
	enemy.moveLeft = true --Enemies will move left by default
	table.insert(self.enemies, enemy)
	world:add(enemy, enemy.x, enemy.y, enemy.width, enemy.height)
end

function enemies_controller:updateAllEnemies(dt)

	--Move enemies
	enemies_controller:move(dt)
	
	for _,e in pairs(enemies_controller.enemies) do
		local futureX = e.x + e.xVelocity * dt
		local futureY = e.y + e.yVelocity * dt
		
		local nextX, nextY, cols, len = world:move(e, futureX, futureY)
		e.onGround = false
		for i = 1, len do
			local col = cols[i]
			if col.normal.y == -1 or col.normal.y == 1 then
				e.yVelocity = 0
			end
			
			if col.normal.y == -1 then
				e.onGround = true
			end	
			
			if col.normal.x == 1 then
				e.moveLeft = false
			elseif col.normal.x == -1 then
				e.moveLeft = true
			end
		end
		
		e.x = nextX
		e.y = nextY
	end
end

function enemies_controller:move(dt)
	for _,e in pairs(enemies_controller.enemies) do
		if e.moveLeft == true then
			e.xVelocity = -e.runSpeed
		else
			e.xVelocity = e.runSpeed
		end
	end
end

function enemies_controller:enemyApplyGravity(dt)
	for _,e in pairs (enemies_controller.enemies) do 
		--Prevent the enemy from going beyond the terminal velocity
		if e.yVelocity < e.terminalVelocity then
			e.yVelocity = e.yVelocity + e.gravity * dt
		else
			e.yVelocity = e.terminalVelocity
		end
	end
end

function enemies_controller:drawEnemies()
	love.graphics.setColor(255,0,0)
	
	for _,e in pairs(enemies_controller.enemies) do
		love.graphics.rectangle("fill", e.x, e.y, e.width, e.height)
	end
end

return enemies_controller