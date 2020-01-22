--Player Class & Implementation
--Based on tutorial by Lucas Black

player = {
	health = 100,
	x = 0,
	y = 0,
	width = 32,
	height = 64,
	gravity = 950,
	jumpGravity = 450,
	runSpeed = 150,
	airSpeed = 25,
	xVelocity = 0,
	yVelocity = 0,
	terminalVelocity = 900,
	onGround = false,
	isJumping = false,
	jumpVelocity = -350,
	colType = 'Player',
	knockback = false,
	knockbackForce = 150,
	isInvuln = false,
	invulnTime = 0.5,
	coyoteTime = 0.2
}

local hitGroundTimer
local jumpTimer

--Deal damage to the player
function player.dealDamage(value)
	player.health = player.health - value
	--TODO: Handle negative health
	if player.health <= 0 then
		print("Game Over")
	end
end

function player.setPosition(x,y)
	player.x, player.y = x,y
end

function player.update(dt)
	player.move(dt)
	player.applyGravity(dt)
	player.collide(dt)
	
end

--Control movement with keyboard input
function player.move(dt)
	--prevent player from using normal speed in knockback or in the air
	if player.knockback == false and player.onGround == true then
		if love.keyboard.isDown("d", "right") then
			player.xVelocity = player.runSpeed
		elseif love.keyboard.isDown("a", "left") then
			player.xVelocity = -player.runSpeed
		else
			player.xVelocity = 0
		end
	elseif player.onGround == false and player.knockback == false then --can still move in air, but to a much lesser extent
		if love.keyboard.isDown("d", "right") then
			player.xVelocity = player.runSpeed + player.airSpeed
		elseif love.keyboard.isDown("a", "left") then
			player.xVelocity = -(player.runSpeed + player.airSpeed)
		else
			player.xVelocity = 0
		end
	end
end

function player.applyGravity(dt)
	--Prevent the player from going beyond the terminal velocity
	if player.yVelocity < player.terminalVelocity then
		if player.isJumping == false then
			player.yVelocity = player.yVelocity + player.gravity * dt
		else
			--Apply a different velocity if we're jumping
			--This works similar to Mario's jump
			player.yVelocity = player.yVelocity + player.jumpGravity * dt
		end
	else
		player.yVelocity = player.terminalVelocity
	end
end

--Filter out collisions based on certain criteria
function playerFilter(player, target)
    if target.colType == "Enemy" then
		if player.isInvuln == true then
			return nil
		else 
			return 'slide' 
		end	
	else
		return 'slide'
	end
end

--Controls collision with world objects and enemies
function player.collide(dt)
	
	if player.xVelocity == 0 then
		player.xVelocity = 1
	end
	
	if player.yVelocity == 0 then
		player.yVelocity = 1
	end
	
	local futureX = player.x + player.xVelocity * dt
	local futureY = player.y + player.yVelocity * dt
	
	-- Get collision data from bump.lua
	local nextX, nextY, cols, len = world:move(player, futureX, futureY, playerFilter)
	
	player.onGround = false
	for i = 1, len do
		local col = cols[i]
		
		if col.other.colType == 'Enemy' then
			print("Hit Enemy")
			player.dealDamage(10)
			print("Knockback")
			player.knockback = true
			
			--Check X direction for knockback
			if col.normal.x == 1 then
				player.xVelocity = player.knockbackForce
				player.yVelocity = - player.knockbackForce
			elseif col.normal.x == -1 then
				player.xVelocity = - player.knockbackForce
				player.yVelocity = - player.knockbackForce
			end
			
			if col.normal.y == -1 then
				player.xVelocity = - player.knockbackForce
				player.yVelocity = -player.knockbackForce
			end
			
			if player.isInvuln == false then
				player.isInvuln = true
			end

		else				
			if col.normal.y == -1 then
				player.isInvuln = false
				player.yVelocity = 0
				player.onGround = true
				player.isJumping = false
				player.knockback = false
				hitGroundTimer = love.timer.getTime()
			end	
		end
	end
	
	player.x = nextX
	player.y = nextY
	
end

function player.draw()
	love.graphics.setColor(255,255,0)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

function player.shoot(key)
	if (key == "h") then
		-- TODO: Implement shoot functionality
	end
end

function player.jump(key)
	
	--Functionality for "Coyote Time"; the ability to jump just slightly after falling off a ledge
	local canCoyoteJump = false
	jumpTimer = love.timer.getTime()
	
	if (jumpTimer - hitGroundTimer) < player.coyoteTime then
		canCoyoteJump = true
	end
	
	-- Jump using w or space, and only when on the ground
	-- Brackets are necessary here to create the proper boolean condition
	if (key == "w" or key == "space") and (player.onGround or canCoyoteJump) and player.knockback == false then
		 player.yVelocity = player.jumpVelocity
		 player.isJumping = true
	end
end

--Necessary for controlling jump height
function player.releaseJump(key)
	if (key == "w" or key == "space") then
		 player.isJumping = false
	end
end

return player