return {
  id = "coin_toss",
  name = "Coin Toss",
  rollDamage = function()
    return math.random(1, 3)
  end,
  rollCrit = function()
    return false
  end,
  effects = {},
  assets = {
    images = {
      sprite = {
        src = "coin_toss.png",
        animation = "coin_toss.json"
      }
    },
    sounds = {
      --spin = "spin.wav",
    },
  }
}
