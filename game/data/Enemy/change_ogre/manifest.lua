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
      initiative = love.math.random(-3, 2),
    }
  end,
  assets = {
    images = {
      sprite = {
        src = 'change_ogre.png',
        animation = 'change_ogre.json'
      }
    },
  },
  ai = {
    behavior = "aggressive", -- optional special behavior tags
  },
  -- symbols = {
  --   'defense',
  --   'heal',
  --   'magic',
  --   'melee',
  --   'mobility',
  --   'potion',
  --   'ranged',
  --   'wild'
  -- },
  abilities = {
    "quick_slash",
    "taunt",
  }
}
