
## Player Turn 

1. Resolve Status Effects Phase
	1. Negative effects first
	2. Positives next
2. Roll Phase
	1. Roll up to as many coins as you have available
	2. You roll for symbols that can be used to charge up abilities
		1. Swords charge melee attacks
		2. Arrow charge range attacks
		3. Shield charge defense abilities
		4. Heart charge healing abilities
		5. Wand charges magic abilities
		6. Potion charge status effects
		7. Boots charge mobility abilities
		8. Wild or specials per character? 
	3. These symbols will go into a symbol bank or something similar that you can use in your main phase. This bank might have a limited size that you can increase as a prestige upgrade?
3. Main Phase
	1. Target an enemy/creature
	2. Use your symbols on unlocked abilities to do damage/stun/heal
		1. Each ability will have specific requirements for example:
			1. Dash and Slash
				1. 2 boots and 3 sword - Deal 4 damage and stun the enemy for 1 round
			2. Triple Shot 
				1. 1 boot and 3 arrows - Deal 3 shots for 2 dmg (can target multiple enemies)
		2. Each ability can have some of the following mechanics
			1. Offensive
				1. Chance to hit
				2. Chance to crit
				3. Chance to proc some special ability
				4. Chance to chain
				5. Chance to bleed
				6. Chance to stun
				7. Chance to burn
			2. Healing
				1. Maybe they have limited uses per round?
				2. Chance to over heal
				3. Chance to gain a healing charge back
			3. Defensive
				1. Chance to mitigate
				2. Chance to skip enemy turn
				3. etc etc
	3. If enemy killed
		1. Chance to drop one of the following
			1. Heal charges
			2. One of their Symbols
			3. An enemies ability
		2. Collect XP
		3. Collect Currencies
4. Upgrade phase
		1. Collect currencies earned from the round. 
		2. Use (some currency) to upgrade:
			1. More reels (expensive)
			2. Upgrade symbols
			   There can be multiple symbols of the same type per reel. 
				1. Sword 1 -> Sword 2
				2. Heart 2 -> Heart 3
				3. etc
5. End Turn


## Enemy turns

1. Resolve Status Effects Phase
2. Roll Phase
	1. Basically identical to the player
3. Main Phase
	1. Enemies will follow a similar approach to the player but they will have several base AI behaviors that guide how they play their round
		1. Aggressive
			1. Tend toward attacking more than playing defensively
		2. Tank
			1. Will attack less frequently and attempt to block or heal
		3. Healer
			1. Will attempt to heal other enemies on the battlefield before attacking if there are wounded enemies
		4. Etc. 
			1. More profiles will be fleshed out as we go. 
	2. Need to decide how to display what the enemy is doing to the player so it's not all just happening in the code, but they can see their strategy so that they can learn from it or something?  Undecided on this. 
4. Upgrade Phase
	1. I don't know if the enemies should be upgrading their abilities yet... 
	2. If they do, maybe their currency collection is reduced, can use this as a knob to turn for difficulty?
5. End Turn

## Lair Turn
Some lairs might have special effects that get performed every x round.  This will look a little different to Player and Enemy turns, will flesh this out in the future.  Not MVP critical. 

---

### ChatGPT Lair Ideas

https://t3.chat/chat/03457d86-d3d2-4855-8bef-88eb35539d99

Here are some concept‐level ideas for a “Lair Turn” subsystem—an environmental/arena mechanic that triggers special effects every X rounds. You can pick and mix these, or use them as springboards for your own:

#### Lair Turn Framework  
   • Define a Lair object with:  
     – interval (every N rounds)  
     – list of Effects to fire on its turn  
     – optional phase (pre-roll, post-main, end-turn) for when to apply  
   • At the end of each full round (after both Player and Enemy turns), increment a lair counter; when it hits the interval, run the lair’s Effects, then reset.
#### Timed Hazard Zones  
   • “Poisonous Fumes”: at round 3, lair emits a cloud—everyone in zone takes DOT for 2 rounds  
   • “Lava Pools”: every 5 rounds, random tiles erupt; standing actors take fire damage and gain a burn stack  
   • “Spore Burst”: every 4 rounds, spawn weak adds (mushroom minions) that have 1-round lifespan but can block movement or explode on death  

#### Environmental Buff/Debuff Auras  
   • “Arcane Surge”: every 6 rounds, lair glows—next round all magic abilities deal +1 symbol charge for free  
   • “Gravity Well”: every 4 rounds, defense rolls cost an extra shield symbol (simulating weight)  
   • “Frenzy Roar”: every 7 rounds, all enemies get a one‐time haste charge (extra coin next roll), but drop 1 sword on death  

#### Dynamic Terrain Alterations  
   • “Shifting Walls”: every 3 rounds, the arena layout rotates—targets may change, line‐of‐sight recalculated  
   • “Quicksand Pits”: every 5 rounds, random tiles become “slow”—boots cost double to remove  
   • “Crystal Growth”: every 4 rounds, crystals sprout—symbol-on-use triggered: swords do +1 damage when hitting a crystal  

#### Phase-Based Boss Lair  
   • Boss Lair has multiple phases tied to lair turns:  
     – Phase 1 (rounds 1–5): activate minor hazards  
     – Phase 2 (rounds 6–10): hazards intensify (higher damage, faster intervals)  
     – Phase 3 (round 11+): introduces a lair‐bound elite minion that aids the boss  
   • Visual/UI cue: change arena background or border glow to signal phase shift

#### Player-Interactive Lair Elements
 
   • “Rune Pillars”: when a lair turn rolls, it empowers one pillar—players can spend wand charges to absorb and deactivate it for a round  
   • “Mana Fount”: every X rounds, a central fountain pulses—anyone standing adjacent regains 1 heart symbol in their bank  
   • “Trap Control Lever”: one side gives players an ability to delay the next lair turn by 1 round (costs currency or symbol)

#### Lair Loot & Rewards  
   • If players defeat the boss before the next lair turn, they salvage special loot (unique symbols or one-off abilities)  
   • Surviving a lair turn without taking damage grants bonus XP or a temporary symbol buff in the following round

#### Scaling & Variants  
   • ―Difficulty knob: shorten lair interval or increase effect potency on harder modes  
   • ―Lair archetypes: fire, ice, arcane, nature—each with themed effects and symbol synergies (e.g. ice lair grants extra shield rolls)  
   • ―Mini‐lair events: some rounds trigger “mini‐boss” lair effects that only affect specific quarters of the arena

#### Implementation Considerations  
   • Treat LairTurn as a sibling of Player/Enemy turns in your TurnController—just toggle “lair mode.”  
   • Lair effects can be data‐driven: JSON entries with interval, effect type, target filter, magnitude.  
   • Provide clear UI warnings (“Next Poison Cloud in 1 Round”) so players can strategize around lair timing.

These mechanics layer an extra strategic dimension—forcing players to plan not just around enemies’ AI and abilities, but around the arena itself. Pick a handful for your MVP lairs and expand once the core combat loop is solid.

---