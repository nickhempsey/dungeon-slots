return {
  id = "luck_punk",
  name = "Luck Punk",
  stats = {
    health = 30,
    attack = 5,
    defense = 2,
  },
  assets = {
    sprite = "sprite.png",
    attackSound = "attack_sound.wav",
    deathSound = "death_sound.wav",
  },
  baseSymbols = { 'sword_attack', 'coin_toss' },
  ai = {
    behavior = "aggressive", -- optional special behavior tags
  },
  abilities = {
    "quick_slash",
    "taunt",
  }
}
