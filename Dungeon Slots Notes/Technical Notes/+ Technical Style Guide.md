This documents purpose is an attempt to bring consistency throughout the codebase and define how modules, classes, tables, functions, etc will be structured.  This is easier said than done especially since there are several modules that are being directly imported from other vendors.  Any module that is imported that has been deprecated by the author will be brought into alignment with this guide in order to bring parity throughout the codebase. 

This doc is heavily inspired by [Tiger Style](https://tigerstyle.dev/), from the Tiger Beetle team, it will not rewrite the aforementioned manifest, rather it'll use it as a guide to outline stylistic choices and patterns that should be adhered to while building this project. While it's inspired, it does deviate since Lua is not a typed language nor does it allow for static memory allocation.  That doesn't mean we shouldn't do our best to write performant and safe code. 

---

## Philosophy

>       
>     _"Programs should be written for people to read, 
>     and only incidentally for machines to execute."_  
>        — **Harold Abelson**
>        

>     
>     "_Any fool can write code that a computer can understand. 
>     Good programmers write code that humans can understand._” 
>        — **Martin Fowler**
>        

- **Favor simplicity over cleverness.**
- **Avoid magic. Embrace clarity.**
- **Minimize side effects. Respect scope.**
- **Structure code like a narrative.**
- **Optimize for understanding, not just execution.**

---

## Formatting & Structure

### Indentation
- Use **2 spaces** per indentation level.
- This should be handled by the Lua formatter

```lua
function greet(name)
  if name then
    print("Hello, " .. name)
  else
    print("Hello, stranger")
  end
end
```

### Line Length
- Keep lines under **80 characters** when possible.
- Break longer expressions thoughtfully.

### File Layout
- **One module per file.**
- Group related functions together.
- Put "public" interface at the top; helpers below.

---

## Naming Conventions

### Variables & Functions
- `snake_case` for variables and functions.
- Use **descriptive** names (`enemy_hp`, not `ehp`).
- Avoid using single letter variable names.

### Constants
- Use `ALL_CAPS` for module-level constants.

### Modules
- Use `PascalCase` for module names: `CombatSystem`, `InventoryManager`.

---

## Control Structures

### Conditionals

Prefer clarity over terseness.

**:LiCheckCircle: Good**

```lua
if player.hp <= 0 then
  player:die()
end
```

**:LiCircleX: Bad**

```lua
-- one-liners are harder to grok
if not player:isAlive() then player:die() end  
```

### Loops

Use `ipairs` for arrays, `pairs` for tables.

```lua
for i, item in ipairs(inventory) do
  print(item.name)
end
```

Avoid recursion if possible to keep execution bounded and predictable, preventing stack overflows and uncontrolled resource use. 

The exception is if you're writing a coroutine or FSM (Finite State Machine). 

### FSMs

- Keep **each state function** focused — short and named clearly.
- **Avoid duplication** by reusing transitions and common logic.
- **Drive state changes** only from within state logic or explicitly via a `transition()` function.
- Consider separating **data** and **logic**

**:LiCheckCircle: Good**

```lua
local states = {}

states.idle = function(self)
  print("Standing still")
  if self.enemy_in_sight then
    self.state = "chase"
  end
end

states.chase = function(self)
  print("Running toward enemy")
  if self.enemy_in_range then
    self.state = "attack"
  elseif not self.enemy_in_sight then
    self.state = "idle"
  end
end

states.attack = function(self)
  print("Attacking!")
  -- Maybe go back to chase or idle after a cooldown
end

local actor = {
  state = "idle",
  enemy_in_sight = false,
  enemy_in_range = false
}

function actor:update()
  states[self.state](self)
end
```

**:LiXCircle: Bad**

```lua
if isIdle then
  -- idle logic
elseif enemyInSight then
  -- chase logic
elseif enemyInRange then
  -- attack logic
else

```

This will lead to a dark place as the logic and state tree gets larger. 

---

## Tables

Treat tables like lightweight objects.
- Constructor tables should be formatted cleanly.

```lua
local config = {
  window_width  = 800,
  window_height = 600,
  fullscreen    = false,
}
```

### The Line Up

Bonus points for cleanly lining up values for increased readability on:
- **Static tables** like config, theme settings, key mappings, color palettes
- **Data-only tables** where logic or expressions are minimal
- **Small to medium size** (e.g. 5–10 keys)

#### When to avoid the line up**

- **Dynamic or expression-heavy values**:  
    It can become awkward or messy if some values are long expressions or function calls.

**:LiXCircle: Bad**

```lua
local status = {
  health    = get_health(player),  -- short
  inventory = fetch_inventory_data(player, zone_id, true),  -- very long
  buffs     = {},  -- this will now feel misaligned
}
```

In order to combat this it would be preferred, not mandatory that expressions are ordered shortest to longest:

**:LiCheckCircle: Good**

```lua
local status = {
  buffs     = {},  
  health    = get_health(player),
  inventory = fetch_inventory_data(player, zone_id, true),
}
```

This provides a clear start and end to the table, further increasing readability.

---

## Functions

- Keep functions **short and single-purpose**.
- Use **early returns** to avoid deep nesting.
- Document expectations: input types, return values, and side effects.

```lua
-- Calculates damage after armor
--
-- @param base_damage number
-- @param armor number
-- @return number
function calculate_damage(base_damage, armor)
  return math.max(base_damage - armor, 0)
end
```

---

## Modules

- Use a local table to define the module:
- Avoid global variables. Always return a table.

```lua
local Combat = {}

function Combat.attack(attacker, target)
  -- ...
end

return Combat

```

--- 

## Metatables & Magic

- Don’t use `__index` or other metatable features unless you _really_ need them.
- Avoid operator overloading except in DSL-like modules (e.g. vector math).

### When to use Metatables

#### 1. **Operator Overloading for Math-like Types**

Metatables make sense when you're creating types like vectors, matrices, or complex numbers where arithmetic feels natural.

```lua
local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
  return setmetatable({x = x, y = y}, Vector)
end

function Vector.__add(a, b)
  return Vector.new(a.x + b.x, a.y + b.y)
end
```

#### 2. **Prototypal Inheritance / Object Systems**

Metatables are useful for building lightweight class-like systems using `__index`.

```lua
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name)
  return setmetatable({name = name, hp = 100}, Enemy)
end

function Enemy:take_damage(amount)
  self.hp = self.hp - amount
end
```

#### 3. **Customizing Table Behavior**

This includes:
- **`__tostring`**: Custom string representation.
- **`__len`**: Custom behavior for `#table`.
- **`__pairs`**: Control iteration order or filtering.

#### 4. **Weak Tables**

When managing caches, registries, or references you don’t want to prevent from being GC’d.

```lua
local cache = setmetatable({}, { __mode = "v" })  -- weak values
```

Use case: Memory-efficient data structures.

### When _Not_ to Use Metatables

#### 1. **Just to Simulate Classes**

If your data structure doesn't need methods or inheritance, a plain table is often clearer.

:LiXCircle: Bad

```lua
setmetatable(myTable, { __index = someOtherTable })
```

:LiCheckCircle: Better
```lua
-- explicit copy or reference
myTable.someField = someOtherTable.someField  
```

#### 2. **Dynamic Behavior That Obscures Logic**

Avoid magic like `__index` or `__call` unless it's truly beneficial. It can make debugging harder and performance worse.

#### 3. **Performance-Critical Loops**

Metatables incur overhead. If you're doing thousands of iterations per frame (e.g., in a game loop), avoid using them for hot-path data structures.

#### 4. **Obfuscating Table Contents**

If you’re using metatables to hide or override behavior in a way that’s not obvious to readers or collaborators, it’s likely a misuse.

---
