return {
  id = "change_goblin",
  name = "Change Goblin",
  w = 64,
  h = 64,
  ox = 64 / 2,
  oy = 64 - 16,
  --- TODO: maybe change this to an enum for easier editor writing?
  --- ox = 'center' | 'left' | 'right' | number
  --- oy = 'floor' | 'bottom' | 'center' | 'top' | number
  baseStats = function()
    return {
      health = love.math.random(5, 15),
      attack = love.math.random(1, 3),
      defense = love.math.random(5, 10),
      initiative = love.math.random(1, 8),
    }
  end,
  rollCrit = function()
    return love.math.random() < 0.2 -- 20% chance
  end,
  assets = {
    images = {
      sprite = {
        src = 'change_goblin.png',
        animation = 'change_goblin.json'
      }
    },
    sounds = {
      --attackSound = "attack_sound.wav",
      --deathSound = "death_sound.wav",
    },
    -- Just incase we decide to give their names different fonts for dramatic effect.
    fonts = {
      --font = "font.ttf",
    },
  },
  ai = {
    behavior = "aggressive", -- optional special behavior tags
  },
  symbols = { 'sword_attack', 'coin_toss' },
  abilities = {
    "quick_slash",
    "taunt",
  }
}
