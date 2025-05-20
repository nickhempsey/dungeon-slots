return {
  id        = "luck_punk",
  w         = 128,
  h         = 128,
  ox        = 64 / 2,
  oy        = 128 - 16,
  baseStats = function()
    return {
      health     = 30,
      attack     = 5,
      defense    = 2,
      initiative = 4,
    }
  end,
  symbols   = {
    defense = {
      qty = 3,
      increase_cap = 3
    },
    heal = {
      qty = 2,
      increase_cap = 2
    },
    magic = {
      qty = 1,
      increase_cap = 1
    },
    melee = {
      qty = 1,
      increase_cap = 1
    },
    mobility = {
      qty = 1,
      increase_cap = 1
    },
    potion = {
      qty = 1,
      increase_cap = 1
    },
    ranged = {
      qty = 1,
      increase_cap = 1
    },
  },
  abilities = {
    "quick_slash",
    "taunt",
    "triple_arrow"
  },
  assets    = {
    images = {
      sprite = {
        src       = "luck_punk.png",
        animation = "luck_punk.json",
      }
    },
  },
}
