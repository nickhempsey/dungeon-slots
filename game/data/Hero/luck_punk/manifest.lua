return {
  id          = "luck_punk",
  name        = "Luck Punk",
  description = "",
  w           = 128,
  h           = 128,
  ox          = 64 / 2,
  oy          = 128 - 16,
  baseStats   = function()
    return {
      health     = 30,
      attack     = 5,
      defense    = 2,
      initiative = 4,
    }
  end,
  symbols     = {
    "defense",
    "heal",
    "magic",
    "melee",
    "mobility",
    "potion",
    "ranged",
    "wild"
  },
  abilities   = {
    "quick_slash",
    "taunt",
    "triple_arrow"
  },
  assets      = {
    images = {
      sprite = {
        src       = "luck_punk.png",
        animation = "luck_punk.json",
      }
    },
  },
}
