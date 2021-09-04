platform.apilevel = '2.4' 

--GLOBALS   
screen = platform.window
width = screen:width()
height = screen:height()
menuButtonsWidth = 100
menuButtonsHeight = 30
title = "Space Invaders"
PROJECTILE_WIDTH = 10
PROJECTILE_HEIGHT = 10
PROJECTILE_SPEED = 2
STARTING_HEALTH = 3
ENEMY_FIRE_FREQ_MODIFIER = 4000
ENEMY_FREQ_CHANGE = 150
totalElements = 0
-------------GLOBAL TABLES FOR OBJECTS(tables)------------------------------------
enemies = {};
enemyProjectiles = {};
playerProjectiles = {};
player = {}
-------------END GLOBAL TABLES----------------------------------------------------



---------------------SETUP STUFF-----------------------------------------------------------------------------------
function on.construction() 
	loadImages()
   timer.start(.02);
end
function startGame()
	ENEMY_FIRE_FREQ_MODIFIER = 4000
	createEnemyGrid(12,3)
	playerMaker(150,155,20,20)
end

function getTableLength(localTable)
	local elements = 0
	for i, v in ipairs(localTable) do
		elements = elements + 1
	end
	return elements
end
function clearTable(localTable) 
	for i, v in ipairs(localTable) do 
		table.remove(localTable, i)
		totalElements = totalElements - 1
	end
end
function endGame()
	totalElements = getTableLength(enemies) + getTableLength(enemyProjectiles) + getTableLength(playerProjectiles)
	clearTable(enemies)
	clearTable(enemyProjectiles)
	clearTable(playerProjectiles)
	if(totalElements <= 0) then
		graphicsHandler.game = false
		graphicsHandler.menu = true
	end
	
end
 ------------------------ENDSETUP STUFF----------------------------------------------------------------------------


-------------INPUT STUFF---------------------------------------------------------
--Table to store state of different inputs
controls = {
    up = false,
    down = false,
    right = false,
    left = false,
    fire = false
}
--Returns all members of the controls table to false
function clearControls() 
   controls.up = false
   controls.down = false
   controls.right = false
   controls.left = false
   controls.fire = false
end

function on.charIn(char)
    if char == "8" then
        print("8")
        controls.up = true
        end
    if char == "4" then 
        print("4")
        controls.left = true
        end
    if char == "6" then
        print("6")
        controls.right = true
        end
    if char == "5" then
        print("5")
        controls.down = true
        end
    
     end
function on.enterKey()
    print("enter")
    controls.fire = true
end
--clicky stuff, used in menu and options
function on.mouseDown(x,y)
  print(x);
  print(y);
  if (x >= width/2-menuButtonsWidth/2 and x <= width/2-menuButtonsWidth/2 + menuButtonsWidth)and 
      (y >= height/2.5 and y <= height/2.5 + menuButtonsHeight) 
  then
  print("fired");
  graphicsHandler.menu = false;
  graphicsHandler.game = true;
  startGame()
   end
  end
--------------------------END CONTROL STUFF------------------------------------------------------------
gameStarted = false;


function on.timer()
    if graphicsHandler.game == true then
        updatePositions();
        screen:invalidate() ;
    end
end
-----------------------------GRAPHICS STUFF----------------------------------------------------
function loadImages()
	playerShip = image.new(playerShip)
end

function on.paint(gc)
--menu graphics stuff
if graphicsHandler.menu == true then
    gc:setColorRGB(153,153,230);
    gc:fillRect(0,0,width,height) ;
    --start button
    gc:setColorRGB(55,5,5);
    gc:fillRect(width/2-menuButtonsWidth/2,height/2.5,menuButtonsWidth,menuButtonsHeight);
    gc:setColorRGB(33,55,66);
    gc:drawString("Start",width/2-gc:getStringWidth("Start")/2,height/2.5,"top");
 --begin main title
    gc:setColorRGB(0,255,55);
    gc:setFont("serif","b",32);
    gc:drawString(title,width/2-gc:getStringWidth(title)/2,35,"middle");
    
elseif graphicsHandler.options == true then
    print("options");
--Calls main drawing function for game
elseif graphicsHandler.game == true then
    updateGraphics(gc)
    spawnInterface(gc);
end
    end
  
function spawnInterface(gc)
--gc:fillRect(22,22,22,22);

end
--Main drawing function
function updateGraphics(gc)
     for i,v in ipairs(enemies) do
           v.draw(gc);
       end
     for i,v in ipairs(playerProjectiles) do
        v.draw(gc)
     end
     for i, v in ipairs(enemyProjectiles) do 
        v.draw(gc)
     end
       player.draw(gc)
    end
--Function to update positions of objects
function updatePositions() 
        for i,v in ipairs(enemies) do
            v.backAndForth()
            v.fire()
         end
         for i, v in ipairs(playerProjectiles) do 
            v.update()
            if(v.y < 0) then
                table.remove(playerProjectiles, i)
            end    
         end
         for i, v in ipairs(enemyProjectiles) do
            v.move()
			if(v.y > height) then
				table.remove(enemyProjectiles, i)
			end
         end
         checkEnemyHits()
         checkPlayerHits()
         updatePlayerPos()
         clearControls()
		 if(getTableLength(enemies) <= 0) then
			createEnemyGrid(12,3)
		 end
		 if(player.health <= 0) then
			print("gameshould be ending")
			endGame()
		 end
     end
function updatePlayerPos() 
         if controls.up == true then
             if player.y >= 110 then
             player.y = player.y - 6
             end
             end
         if controls.down == true then
             if player.y + 6 + player.height <= height then
             player.y = player.y + 6
             end
             end
         if controls.right == true then
             if player.x + 6 + player.width <= width then
                 player.x = player.x+6
                 end
             end
         if controls.left == true then
             if player.x - 6 >= 0 then
                 player.x = player.x -6
                 end
             end
         if controls.fire == true then
             player.fire()
         end
     end
--Handles state of program, different menus
     graphicsHandler = {
         menu = true,
         options = false,
         game = false,
     }
----------------------END GRAPHICS STUFF--------------------------------------------------

-----------------------TABLE / OBJECT CONSTRUCTORS-----------------------------------------

--Constructor for enemy 
function createEnemy(x,y,width,height,color)
    local direction = true
	local target = {	
	}
	target.x = x;
	target.y = y;
	target.width = width;
	target.height = height;
	target.color = color;
	target.draw = function(gc)
        gc:setColorRGB(44,4,60)
        gc:fillRect(target.x,target.y,target.width,target.height)
	end
	target.backAndForth = function()
	   target.fire()
	   if direction == true then
	       target.x = target.x + 1
	           if target.x+target.width >= screen:width() then
	               direction = false
	           end
	       end
	   if direction == false then
	       target.x = target.x - 1
	           if target.x <= 0 then
	               direction = true
	               end
	       end
	end
	target.fire = function()
	   
	   local randomNumber = math.random(1, ENEMY_FIRE_FREQ_MODIFIER);
	   if(randomNumber == (ENEMY_FIRE_FREQ_MODIFIER / 2)) then
	       createEnemyProjectile(target.x,target.y)
	   end
	end
	table.insert(enemies, 1, target);
end
--Creates a grid of enemies
function createEnemyGrid(rows, number)
    local width = 10
    local height = 10
    for i=0,rows, 1 do
        for g=0,number,1 do
            createEnemy(i*20,g*20,width,height)
            print(i)
            print(g)
        end
    end
end
--Constructor for player object
function playerMaker(x,y,width,height)
    player.x = x
    player.y = y
    player.width = width
    player.height = height
    player.health = STARTING_HEALTH
    player.draw = function(gc)
		gc:drawImage(playerShip, player.x, player.y)
        gc:setColorRGB(255,5,5)
        gc:fillRect(player.x,player.y,player.width,player.height)
    end
    player.fire = function()
        createPlayerProjectile(player.x,player.y,gc)
    end
end
--Constructor for projectiles fired by player
function createPlayerProjectile(x,y)
    local target = {}
    
    target.x = x
    target.y = y - 5
    target.width = PROJECTILE_WIDTH
    target.height = PROJECTILE_HEIGHT
    target.move = function() 
        target.y = target.y - PROJECTILE_SPEED
    end
    target.draw = function(gc)
        gc:setColorRGB(200,55,0)
        gc:fillRect(target.x,target.y,target.width,target.height)
    end
    target.update = function(gc) 
        target.move()
        --target.draw(gc)
    end
    table.insert(playerProjectiles, 1, target)
    
end
--Constructor for enemey projectiles
function createEnemyProjectile(x,y)
    print("new projectile")
    local tempTable = {}
    tempTable.x = x
    tempTable.y = y
    tempTable.width = PROJECTILE_WIDTH
    tempTable.height = PROJECTILE_HEIGHT
    
    tempTable.move = function()
        tempTable.y = tempTable.y + PROJECTILE_SPEED
    end
    tempTable.draw = function(gc)
        gc:setColorRGB(255,0,0)
        gc:fillRect(tempTable.x,tempTable.y,tempTable.width,tempTable.height)
    end
    
    table.insert(enemyProjectiles,1,tempTable)
end
-------------------------END CONSTRUCTORS-------------------------------------------

----------------------------COLLISION DETECTION STUFF--------------------------------------------------------
function checkCollisions(target, other)
    if target.x + target.width > other.x and 
        target.x < other.x + other.width and
        target.y + target.height > other.y and
        target.y < other.y + other.height then
        print("collision")
      return true
      end
end

function checkEnemyHits() 
    for i,v in ipairs(playerProjectiles) do
        for g, m in ipairs(enemies) do 
            if checkCollisions(v,m) then
                table.remove(enemies,g)
                table.remove(playerProjectiles,i)
				if(ENEMY_FIRE_FREQ_MODIFIER - ENEMY_FREQ_CHANGE > ENEMY_FREQ_CHANGE) then
					ENEMY_FIRE_FREQ_MODIFIER = ENEMY_FIRE_FREQ_MODIFIER - ENEMY_FREQ_CHANGE
				end
            end
        end
    end
end

function checkPlayerHits()
    for i, v in ipairs(enemyProjectiles) do
        if(checkCollisions(v, player)) then
            print("Player hit")
            player.health = player.health - 1
			table.remove(enemyProjectiles, i)
        end
    end
end
-------------------------------END COLLISION STUFF------------------------------------------------------------------


 
