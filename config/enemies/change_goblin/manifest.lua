return {
  id = "change_goblin",
  name = "Change Goblin",
  stats = {
    health = 30,
    attack = 5,
    defense = 2,
  },
  assets = {
    images = {
      --sprite = "sprite.png",
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
