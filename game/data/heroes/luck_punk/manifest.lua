return {
  id = "luck_punk",
  name = "Luck Punk",
  w = 64,
  h = 80,
  ox = 64 / 2,
  oy = 80 - 16,
  stats = {
    health = 30,
    attack = 5,
    defense = 2,
  },
  assets = {
    images = {
      sprite = {
        src = "luck_punk_64.png",
        animation = "luck_punk_64.json",
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
  symbols = {
    "defense",
    "heal",
    "magic",
    "melee",
    "mobility",
    "potion",
    "ranged",
    "wild"
  },
  abilities = {
    "quick_slash",
    "taunt",
    "quick_slash"
  }
}
