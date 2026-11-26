# Advanced Autotile Plugin

Autotile plugin developed for Godot 4.7

## Features:

1. An improved autotile (terrains) algorithm
2. Mixed connection modes (per-terrain, without terrain "sets")
3. Custom connection logic (e.g. Map-edge bleed, different terrains connecting)
4. Diagonal connection modes
5. Connection painting tool (good for dual-grid approach)
6. Triangle grids (good for hexagon dual-grid and sub-grid)

## Installation/Setup:

Download plugin from asset store or Github. Only the `addons` folder is
required (even for in-editor documentation). The
`addons/advanced_autotiles/scene` folder contains everything needed for the API,
the rest is for the editor plugin.

The plugin must be enabled via project settings.

Create a new `AdvancedTileMapLayer` node and give it a new `AdvancedTileSet`
resource.

(Alternatively, change an existing `TileSet` resource into an `AdvancedTileSet`
by attaching the script
`addons/advanced_autotiles/scene/advanced_tile_set/advanced_tile_set.gd` to it,
or any script extending the `AdvancedTileSet` class, then change a
`TileMapLayer` to an `AdvancedTileMapLayer` by attaching the script
`addons/advanced_autotiles/scene/advanced_tile_map_layer/advanced_tile_map_layer.gd`
to it, or a script that extends the `AdvancedTileMapLayer` class.)

Add terrains to the `AdvancedTileSet` as needed (in the "Autotiling" property
group). Set up atlas sources and tiles using the "TileSet" docker as usual.
For triangle tiles, use the "Advanced Autotiles" docker to set orientation.
Use the "Advanced Autotiles" tab to set up tile terrain masks, and to paint
using terrains.

## AI Disclaimer:

AI was not used during the development of this plugin.
