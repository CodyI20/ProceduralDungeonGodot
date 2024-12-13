# ProceduralDungeonGodot
This repo holds an app which creates procedurally generated dungeons in Godot


It uses a series of algorithms that firstly create certain rooms based on set parameters. It then uses the physics engine to distribute them and push them apart. The main rooms are then chosen (based on some predefined conditions) and using Delunay Triangulation and Minimum Spanning Tree it generates a graph of nodes that are connected to all rooms. In the end hallways are created based on the approximate orientation of the tree lines. Using a TilemapLayer and a Tileset of choice we can nicely visualize the dungeon.

## Here the dungeon rooms are generated using the distrubtion and the main rooms are selected

![Collision_showcase](https://github.com/user-attachments/assets/b0a1fe51-a3c1-423a-93c9-7530f2cccd82)


## Here the minimum spanning tree is generated

![Minimum_spanning_tree_showcase](https://github.com/user-attachments/assets/0f5faa41-1412-4fb6-b00d-03c04d93663a)


## Here is the final result with the application of the tilemap

![Tilemap_image](https://github.com/user-attachments/assets/96a814d2-79a3-4166-8b89-d0bb927cc33d)
