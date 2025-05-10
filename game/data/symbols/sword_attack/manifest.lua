return {
  id = "sword_attack",
  name = "Sword Attack",
  rollDamage = function()
    return math.random(2, 4)
  end,
  rollCrit = function()
    return math.random() < 0.1
  end,
  effects = {
    'stun',
    'debuff'
  },
  assets = {
    images = {
      sprite = {
        src = "sword_attack.png",
        animation = "sword_attack.json",
      }
    },
    sounds = {
      --spin = "spin.wav",
    },
  }
}
