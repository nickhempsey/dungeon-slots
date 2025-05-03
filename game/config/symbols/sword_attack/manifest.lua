return {
  id = "sword_attack",
  name = "Sword Attack",
  baseDmg = 2,
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
