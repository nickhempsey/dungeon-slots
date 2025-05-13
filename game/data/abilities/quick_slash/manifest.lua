return {
  id = 'quick_slash',
  name = "Quick Slash",
  description = "Does something, who know\'s what though?",
  cost = {
    mobility = 2,
    melee = 2
  },
  rollCrit = function()
    return love.math.random() < 0.3
  end,
  rollDamage = function()
    return love.math.random(2, 5)
  end
}
