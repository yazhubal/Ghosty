-- ghosty - refactored
-- by gemini sensei 👻

function _init()
  -- player object
  p = {
    x = 60,
    y = 95,
    sp = 1,
    w = 8,
    h = 8,
    powerup_t = 0 -- time left for triple shot
  }

  -- multiple objects lists! 🔫👻💥
  bullets = {}
  aliens = {}
  expls = {}
  items = {} -- for power-ups

  -- game state
  score = 0
  game_over = false
  game_started = false
  
  -- spawning logic
  spawn_timer = 0
  spawn_rate = 90 -- frames between spawns
  alien_speed = 1

  -- juicy effects ✨
  shake = 0
  
  -- messages
  msg_restart = "for restart press fire"
end

-- helper: spawn a new spooky alien 👻
function spawn_alien()
  local new_en = {
    x = 128,
    y = 10 + rnd(84),
    sp = 5,
    w = 8,
    h = 8
  }
  add(aliens, new_en)
end

function _update()
  -- title screen check
  if not game_started then
    if btnp(4) then
      game_started = true
      music(0)
    end
    return
  end

  -- game over check
  if game_over then
    if btnp(4) then _init() end
    return
  end

  -- player movement
  if btn(0) then p.x -= 2 end
  if btn(1) then p.x += 2 end
  if btn(2) then p.y -= 2 end
  if btn(3) then p.y += 2 end

  -- safety walls (clamping) 🚧
  p.y = mid(10, p.y, 94)
  p.x = mid(0, p.x, 120)

  -- shooting (triple shot logic!)
  if btnp(4) then
    sfx(0)
    if p.powerup_t > 0 then
      -- triple shot! 🔫🔫🔫
      add(bullets, {x = p.x, y = p.y, w = 8, h = 8, dy = 0})
      add(bullets, {x = p.x, y = p.y, w = 8, h = 8, dy = -0.5})
      add(bullets, {x = p.x, y = p.y, w = 8, h = 8, dy = 0.5})
    else
      -- normal shot
      add(bullets, {x = p.x, y = p.y, w = 8, h = 8, dy = 0})
    end
  end

  -- update bullets
  for b in all(bullets) do
    b.x += 3
    b.y += b.dy
    -- delete bullet if it leaves screen
    if b.x > 128 or b.y < 0 or b.y > 128 then del(bullets, b) end
  end

  -- spawn aliens
  spawn_timer -= 1
  if spawn_timer <= 0 then
    spawn_alien()
    -- reset timer (gets faster as you score!)
    spawn_timer = max(20, spawn_rate - (score * 0.5))
  end

  -- update aliens
  for en in all(aliens) do
    en.x -= alien_speed
    
    -- game over if any alien escapes
    if en.x < -8 then
      game_over = true
      sfx(2)
      music(-1)
      shake = 10 
    end

    -- collision with bullets
    for b in all(bullets) do
      if collide(b, en) then
        sfx(1)
        shake = 4 
        add(expls, {x = en.x, y = en.y, t = 10})
        
        -- chance to drop power-up! (10%)
        if rnd(1) < 0.1 then
          add(items, {x = en.x, y = en.y, w = 8, h = 8, sp = 10})
        end

        del(aliens, en)
        del(bullets, b)
        
        score += 1
        alien_speed = 1 + flr(score / 10) * 0.2
      end
    end
  end

  -- update items (power-ups)
  for i in all(items) do
    i.x -= 0.5 -- float slowly to the left
    i.y += sin(time()) * 0.2 -- bob up and down
    
    -- collect power-up
    if collide(p, i) then
      sfx(3) -- play a "pickup" sound if you have one!
      p.powerup_t = 300 -- 10 seconds of glory
      del(items, i)
    end
    
    if i.x < -8 then del(items, i) end
  end

  -- update explosions
  for ex in all(expls) do
    ex.t -= 1
    if ex.t <= 0 then del(expls, ex) end
  end

  -- power-up timer decay
  if p.powerup_t > 0 then p.powerup_t -= 1 end

  -- update shake decay
  shake = max(0, shake * 0.8)
  if (shake < 0.1) shake = 0
end

function _draw()
  local sx = rnd(shake) - shake/2
  local sy = rnd(shake) - shake/2
  camera(sx, sy)

  cls()
  
  -- title screen
  if not game_started then
    print("ghost shooter", 40, 50, 7)
    if (time() % 1 < 0.5) print("press z to start", 35, 70, 6)
    return
  end

  -- draw the world
  map(0, 0, 0, 0, 16, 16)

  -- draw items
  for i in all(items) do
    spr(i.sp, i.x, i.y)
  end

  -- draw player
  local p_sp = p.sp
  if (btn(0) or btn(1) or btn(2) or btn(3)) then
    p_sp += flr(time() * 12) % 2
  end
  -- flash player if powered up! ⚡
  if (p.powerup_t > 0 and time() % 0.2 < 0.1) p_sp = 1 
  
  spr(p_sp, p.x, p.y)

  -- draw bullets
  for b in all(bullets) do
    spr(4, b.x, b.y)
  end

  -- draw aliens
  for en in all(aliens) do
    local en_sp = en.sp + flr(time() * 10) % 2
    spr(en_sp, en.x, en.y)
  end

  -- draw explosions
  for ex in all(expls) do
    spr(7, ex.x, ex.y)
  end

  -- draw ui
  print("score: "..score, 0, 0, 7)
  if p.powerup_t > 0 then
    rectfill(0, 124, p.powerup_t / 300 * 128, 127, 12) -- power-up bar!
  end

  -- game over screen
  if game_over then
    print("game over", 48, 60, 8)
    print(msg_restart, 20, 70, 7)
  end
end

-- helper: box collision (aabb) 📦
function collide(a, b)
  return not (a.x > b.x + b.w - 1 or
              a.x + a.w - 1 < b.x or
              a.y > b.y + b.h - 1 or
              a.y + a.h - 1 < b.y)
end
