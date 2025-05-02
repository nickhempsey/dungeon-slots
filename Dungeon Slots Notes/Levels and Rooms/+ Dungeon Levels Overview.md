
Each level in the game is generated procedurally using a branching node-based map structure, similar to _Slay the Spire_ or _Inscryption_. At the start of each run, the system creates a series of interconnected "floors," each composed of several paths that contain combat rooms, shops, rest stops, mystery rooms, and boss encounters. 

The layout begins with a fixed number of starting nodes (e.g. 3) and expands downward through a tree-like structure, ensuring multiple route options. Nodes are connected in such a way that players must make choices about which rooms to enter and what types of encounters they want to prioritize, creating tension between risk, reward, and resource management. Each node type has a weighted chance to appear based on the floor number and recent player activity (e.g., reducing back-to-back shops or repeat mystery rooms).

Room placement itself is semi-random but guided by simple constraints. For example, each floor will always end with a boss or mini-boss node, and ensure a minimum number of combat encounters to preserve pacing. On early floors, nodes are more likely to contain mystery or healing rooms to encourage exploration and survivability, while later floors increase combat density and introduce rare rooms with powerful upgrades or elite enemies. Each room, when instantiated, loads a self-contained tile layout or grid (for combat or interaction) with modular visual themes. 

Future systems could include seeded generation or "biomes" with unique modifiers, enemy pools, or gimmicks per floor. This approach ensures every run feels fresh and strategic, with player agency in how to navigate the chaos.

## Room Types

- [[Level Start]]
- [[Monster Room]] 
- [[Rest Room]]
-  [[Mystery Room]]
- [[Shop Room]]
- [[Elite Monster Room]]
- [[Boss Room]]

Example Layout 
[[+ Level Layouts.canvas|+ Level Layouts]]