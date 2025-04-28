Player = {}
Player.__index = Player

Player.debug = Debug

function Player:new(characterClass)
  local player = setmetatable({}, Player)
  player.name = characterClass
  player.hp = 100
  player.maxHp = 100
  player.baseDmg = 10
  player.maxDmg = 20
  player.defense = 0
  player.mana = 0
  player.statusEffects = {}
  player.baseSymbols = {} -- your default reel pool
  player.abilities = {}
  player.artifacts = {}

  if characterClass == "Warrior" then
    player.baseSymbols = { "sword", "sword", "shield", "potion", "coin", "wild" }
    player.abilities = {
      {
        name = "Rage",
        cost = 3,
        effect = function(gs)
          gs.player.hp = gs.player.hp + 10
          gs.player.baseDmg = gs.player.baseDmg + 10
          gs.player.maxDmg = gs.player.maxDmg + 10
          gs.player.defense = gs.player.defense - 5
        end
      }
    }
  end

  return player
end

function Player:getBaseSymbols()
  return self.baseSymbols
end

function Player:applyDamage(amount)
  local dmg = math.max(0, amount - self.defense)
  self.hp = self.hp - dmg
end

return Player
