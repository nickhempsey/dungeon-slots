return {
  id = "change_ogre",
  name = "Change Ogre",
  w = 64,
  h = 64,
  ox = 64 / 2,
  oy = 64 - 16,
  baseStats = function()
    return {
      health = love.math.random(20, 30),
      attack = love.math.random(6, 15),
      defense = love.math.random(5, 20),
      initiative = love.math.random(6, 10),
    }
  end,
  assets = {
    images = {
      sprite = {
        src = 'change_ogre.png',
        animation = 'change_ogre.json'
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
