return {
    id = 'tutorial_lair',
    name = 'Tutorial Lair',
    availableEnemies = { 'change_goblin', 'change_ogre' },
    rollQuantityOfEnemies = function()
        return love.math.random(1, 4)
    end
}
