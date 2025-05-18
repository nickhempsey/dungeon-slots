return {
    id = 'vault',
    name = 'Vault Lair',
    floorLevel = 206,
    availableEnemies = { 'change_goblin', 'change_ogre' },
    rollQuantityOfEnemies = function()
        return love.math.random(2, 4)
    end,
    assets = {
        images = {
            bg = {
                src = 'vault.png'
            }
        }
    },
}
