return {
    id = 'tutorial_lair',
    name = 'Tutorial Lair',
    floorLevel = 176,
    availableEnemies = { 'change_goblin', 'change_ogre' },
    rollQuantityOfEnemies = function()
        return love.math.random(2, 4)
    end,
    assets = {
        images = {
            bg = {
                src = 'tutorial_lair.png'
            }
        }
    },
}
