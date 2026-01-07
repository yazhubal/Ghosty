function _init()
 bullet_x = 0 
 bullet_y = 0
 shooting = false 

 x= 60 
 y= 95

 alien_x = 128      
 alien_y = rnd(10 + 88)    
 alien_alive = true 

 score=0
 highscore="score:"
 restart="For restart press FIRE"
 game_over = false

 expl_x = 0        -- Where did the explosion happen?
  expl_y = 0
  expl_timer = 0    -- How long should the explosion stay on screen?

 alien_speed=1

 game_started = false -- The game is paused at the start


end

-- DRAW --
function _draw()
  cls() -- Always clean the screen first
  
  -- TITLE SCREEN DRAW
  if (game_started == false) then
      -- Center the text roughly
      print("GHOST SHOOTER", 40, 50, 7) 
      
      -- Make the "Press Z" text blink! 
      -- (time() changes constantly, so this turns on/off every 0.5 sec)
      if (time() % 1 < 0.5) then
          print("press z to start", 35, 70, 6)
      end
      
      return -- STOP here (don't draw the map or hero)
  end

 cls()                   
 map(0, 0, 0, 0, 16, 16) 
-- Animation math: Flips between 1 and 2
-- Default to standing still (Sprite 1)
 local hero_spr = 1 
 
 -- Check: Are we pressing ANY arrow button? (Left, Right, Up, or Down)
 if (btn(0) or btn(1) or btn(2) or btn(3)) then
    -- If yes, override sprite with the animation math!
    hero_spr = 1 + flr(time() * 12) % 2
 end

 spr(hero_spr, x, y)  
    
 if (shooting) then
   spr(4, bullet_x, bullet_y) 
 end
    
if (alien_alive) then
   -- This math creates a number that flips between 4 and 5
   -- speed: change 10 to make it faster/slower
   local anim_frame = 5 + flr(time() * 10) % 2
   
   spr(anim_frame, alien_x, alien_y)
end

-- Explosion after hit
 if (expl_timer > 0) then
    spr(7, expl_x, expl_y)
 end

 print (score, 23 , 0, 7)
 print (highscore, 0, 0, 7)

 -- I combined your two Game Over print blocks here!
 if (game_over) then
    print("game over", 48, 60, 8) 
    print(restart, 20, 70, 7)
 end
 
end

-- UPDATE --
function _update()

-- TITLE SCREEN CHECK
  if (game_started == false) then
      if (btnp(4)) then       -- If Z is pressed
          game_started = true -- Start the game!
          music(0)            -- Start the music NOW
      end
      return                  -- STOP here (don't run the rest of the game)
  end

  -- RESTART CHECK
  if (game_over) then
      if (btn(4)) _init()  
      return              
  end

  -- MOVEMENT
  if (btn(1)) x = x + 2 --to change speed of ghost add number
  if (btn(0)) x = x - 2 
  if (btn(2)) y = y - 2
  if (btn(3)) y = y + 2

  -- NEW: SAFETY WALLS (Clamping) 🚧
  
  -- 1. Don't hit the ceiling (Score)
  if (y < 10) then
      y = 10
  end

  -- 2. Don't hit the floor
  if (y > 94) then  -- You can tweak 100 if it's too high/low!
      y = 94
  end

  -- BULLET BOUNDARY
  if (bullet_x > 128) then 
      shooting = false
  end

  -- SHOOTING (Changed to btnp!)
  if (btnp(4)) then        -- <--- CHANGED THIS to btnp
    bullet_x = x        
    bullet_y = y        
    shooting = true      
    sfx(00)              
  end

  -- ALIEN MOVEMENT
  if (alien_alive) then
    alien_x = alien_x - alien_speed -- increasing speed of alien
  end

  -- GAME OVER CHECK
  if (alien_x < 0) then
    game_over = true
    alien_alive = false
    sfx(2)
    music(-1)  -- tells the music to STOP immediately
  end

  -- BULLET MOVEMENT
  if (shooting) then
    bullet_x = bullet_x + 3  -- Made bullet faster (optional!)
  end

-- COLLISION
  if (bullet_x + 8 > alien_x and bullet_x < alien_x + 8 and
      bullet_y + 8 >= alien_y and bullet_y < alien_y + 8) then
      
      sfx(01)
      
      -- NEW: Save the spot for the explosion!
      expl_x = alien_x
      expl_y = alien_y
      expl_timer = 10   -- Show explosion for 10 frames (1/3rd of a second)

      -- Reset Alien
      alien_x = 128  
      alien_y = 10 + rnd(88) 
      shooting = false
      score = score + 1
      --flr() rounds donw. So 4/5 = 0, but 5/5 =1.
      alien_speed = 1 + flr(score / 10) * 0.3
  end

  -- NEW: Count down the timer
  if (expl_timer > 0) then
      expl_timer = expl_timer - 1
  end
end