return {
  id = "slotomancer",
  name = "Slotomancer",
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
  ai = {
    behavior = "aggressive", -- optional special behavior tags
  },
  symbols = { 'sword_attack' },
  abilities = {
    "quick_slash",
    "taunt",
  }
}
