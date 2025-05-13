return {
  id = 'taunt',
  name = "Taunt",
  description = "Chance to taunt the enemy.",
  cost = {
    defense = 3,
    ranged = 1
  },
  appliesEffect = {
    'distract'
  },
  rollDistract = function()
    return love.math.random() < 0.8
  end
}
