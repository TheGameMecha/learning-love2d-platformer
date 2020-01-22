-- Platformer Game by Scott Melanson

require('lib.camera')
player = require "player"
enemiesTable = require "enemies"
bump = require "lib.bump"
local level = require "levels.level_1" --load the map data exported from Tiled

world = bump.newWorld()

function levelLoadObjects(level)
	local objects = level.layers[1].objects
	
	for i = 1, #objects do
		local obj = objects[i]
		world:add(obj, obj.x, obj.y, obj.width, obj.height)
	end
end

function levelDrawObjects(level)
	local objects = level.layers[1].objects
	love.graphics.setColor(0,20,200)
	for i = 1, #objects do
		local obj = objects[i]
		love.graphics.rectangle('line', obj.x, obj.y, obj.width, obj.height)
	end
end

function levelSetSpawnPoint(level)
	local spawnPoints = level.layers[2].objects
	for i = 1, #spawnPoints do
		local obj = spawnPoints[i]
		player.setPosition(obj.x, obj.y)
	end
		
	world:add(player, player.x, player.y, player.width, player.height)
end

function levelSpawnEnemies(level)
local spawnPoints = level.layers[3].objects
	for i = 1, #spawnPoints do
		local obj = spawnPoints[i]
		enemiesTable:spawnEnemy(obj.x,obj.y, obj.width, obj.height)
	end
end

--##LOVE FUNCTIONS##
function love.load()

	levelSetSpawnPoint(level)
	levelLoadObjects(level)
	levelSpawnEnemies(level)
	-- Allow the camera to only scroll up and down
	--camera:setBounds(0, 0, 0, love.graphics.getHeight())

end

function love.update(dt)
	player.update(dt)
	enemies_controller:updateAllEnemies(dt, player)
	enemies_controller:enemyApplyGravity(dt)
	
	camera:setPosition(player.x - love.graphics.getWidth() / 2, player.y - love.graphics.getHeight() / 2)
end

function love.draw()
	camera:set()

	player.draw()
	enemiesTable:drawEnemies()
	levelDrawObjects(level)
	
	camera:unset()
end

function love.keypressed(key)
	player.jump(key)
	player.shoot(key)
end

function love.keyreleased(key)
	player.releaseJump(key)
end