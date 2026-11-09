# AdvancedTileSet Class Reference

*File:* `addons/advanced_autotiles/advanced_tile_set/advanced_tile_set.gd`
*Class name:* `AdvancedTileSet`
*Inherits:* `TileSet`

## Synopsis

```gdscript
class_name AdvancedTileSet
extends TileSet
```

## Brief

Tile Set for use with Advanced Autotiles plugin

An extension of Godot's built-in [TileSet] class, intended for use with an
[AdvancedTileMapLayer] node.

## Detailed Description

Adds support for triangle grid configuration
and terrain setup for this plugin.

Plugins cannot extend built-in methods or properties, so this class has
a number of replacements, and the built-in class features are hidden in the
editor unless `member hide_base_class_features` is disabled.

Triangle grids are implemented using Godot's square grid with half the
width/height for horizontal/vertical stacking, so triangles must have an
even width/height (depending on axis).

Key used for storing per-tile plugin data on TileSet custom data layer

Hide properties of the base `class TileSet` in the editor, if an
Advanced Autotiles property is intended to replace.
(Does not affect underlying API)

The tile shape used by the Advanced Autotiles plugin.
Overwrites `member TileSet.tile_shape`

The tile layout used by the Advanced Autotiles plugin.
Overwrites `member TileSet.tile_layout`

For half-offset shapes (isometric, hexagonal, half-offset square),
determines the offset axis. For triangles, determines the stacking and
allowed orientations.

The size, in pixels, of the minumum rectangle that fully encompasses
one cell. Triangles must have even width if horizontal, or height if vertical
(due to implementation limitations).

If true, calculate terrain properties automatically from bindings

If true, determine bindings for the "empty" terrain automatically.

Set the orientation of a tile (only relevant for triangle tiles)

Set a flag of the "Advanced Autotiles" mask of a tile

Add a new "Advanced Autotile" terrain. Returns the index of the new terrain.

Get the connection mode of an "Advanced Autotile" terrain

Set the connection mode of an "Advanced Autotile" terrain

Set whether binding should be determined automatically for the specified
"Advanced Autotile" terrain.

Test whether a given terrain binds to another terrain (Advanced Autotiles)

Set whether a given terrain binds to another terrain (Advanced Autotiles)

Get an empty tile mask for the given connection mode and tile orientation

Class TileKey contains all fields needed to identify a Tile in a TileSet

Class for storing a single terrain (intended only for internal use
by [AdvancedTileSet] class.

## Public Member Functions

- `func _binding_get_terrain_mask(terrain_index: int) -> int`
- `func _binding_get_matched_terrains(binding: int) -> PackedInt32Array`
- `func _init() -> void`
- `func _set_is_loaded() -> void`
- `func _get_property_list() -> Array[Dictionary]`
- `func _validate_property(property: Dictionary) -> void`
- `func _set(property: StringName, value: Variant) -> bool`
- `func _get(property: StringName) -> Variant`
- `func advanced_get_tile_orientation(tile: TileKey) -> TileGeometry.Orientation` — Get the orientation of a tile
- `func advanced_set_tile_terrain(tile: TileKey, terrain_index: int) -> void` — Set the terrain index of a tile
- `func advanced_get_tile_terrain(tile: TileKey) -> int` — Get the terrain index of a tile
- `func advanced_clear_tile_mask(tile: TileKey) -> void` — Clear the "Advanced Autotiles" mask of a tile (set all flags to "empty")
- `func advanced_get_tile_mask(tile: TileKey) -> Dictionary` — Get the "Advanced Autotiles" mask of a tile
- `func advanced_get_tiles() -> Array[TileKey]` — Returns an array of tile keys objects, for all tiles in all the atlas sources
of this tile set.
- `func get_tile_data(tile: TileKey) -> TileData` — Return the [TileData] of a tile identified by a [TileKey]
- `func advanced_get_terrains_count() -> int` — Get the number of "Advanced Autotile" terrains defined for this tileset.
- `func advanced_get_terrain_name(terrain_index: int) -> String` — Get the name of the "Advanced Autotile" terrain at this index.
- `func advanced_set_terrain_name(terrain_index: int, name: String) -> void` — Set the name of an "Advanced Autotile" terrain
- `func advanced_get_tile_terrain_color(terrain_index: int) -> Color` — Get the color assigned to an "Advanced Autotile" terrain (for use in editor)
- `func advanced_set_tile_terrain_color(terrain_index: int, color: Color) -> void` — Set the color assigned to an "Advanced Autotile" terrain (for use in editor)
- `func advanced_get_terrain_auto_binding(terrain_index: int) -> bool` — If true, binding will be determined automatically for the specified
- `func advanced_get_terrain_priority(terrain_index: int) -> int` — Get the priority of the specified "Advanced Autotile" terrain
- `func advanced_set_terrain_priority(terrain_index: int, priority: int) -> void` — Set the priority of the specified "Advanced Autotile" terrain
- `func advanced_get_terrain_has_tiles(terrain_id: int) -> bool` — Test whether the specified "Advanced Autotile" terrain has any tiles
assigned to it.
- `func _recalc() -> void`
- `func _advanced_terrain_update_auto_bindings() -> void`
- `func _advanced_terrain_update_priorities() -> void`
- `func _clear_advanced_tile_data(tile: TileKey, key: String) -> void`
- `func _apply_base_overrides() -> void`
- `func _get_bindings_hint_string(include_empty := true) -> String`
- `func _queue_signal(signal_object: Signal) -> void`
- `func _emit_queued_signals() -> void`
- `func _init(source_id: int, coords: Vector2i, alternative_id: int)`
- `func equals(other_tile: TileKey) -> bool` — Test if this key identifies the same tile as another key
- `func _init(init_name: String, init_color: Color) -> void`

## Public Attributes

- `int empty_terrain_bindings` — Bitmask of bindings for the "empty" terrain.
- `int empty_terrain_priority` — Priority of the "empty" terrain.
- `Array[Terrain] _terrains`
- `Array[Signal] _queued_signals`
- `int terrain_index`
- `PackedInt32Array flags`
- `int layer_index`
- `Dictionary custom_data`
- `PackedStringArray hint_strings`
- `int source_id`
- `Vector2i coords`
- `int alternative_id`
- `TileGeometry.ConnectionMode mode`
- `int bindings`
- `int priority`

## Signals

- `signal terrains_changed` — Emitted when the terrains setup changes.

## Member Function Documentation

### _binding_get_terrain_mask

```gdscript
func _binding_get_terrain_mask(terrain_index: int) -> int
```

### _binding_get_matched_terrains

```gdscript
func _binding_get_matched_terrains(binding: int) -> PackedInt32Array
```

### _init

```gdscript
func _init() -> void
```

### _set_is_loaded

```gdscript
func _set_is_loaded() -> void
```

### _get_property_list

```gdscript
func _get_property_list() -> Array[Dictionary]
```

### _validate_property

```gdscript
func _validate_property(property: Dictionary) -> void
```

### _set

```gdscript
func _set(property: StringName, value: Variant) -> bool
```

### _get

```gdscript
func _get(property: StringName) -> Variant
```

### advanced_get_tile_orientation

```gdscript
func advanced_get_tile_orientation(tile: TileKey) -> TileGeometry.Orientation
```

Get the orientation of a tile

### advanced_set_tile_terrain

```gdscript
func advanced_set_tile_terrain(tile: TileKey, terrain_index: int) -> void
```

Set the terrain index of a tile

### advanced_get_tile_terrain

```gdscript
func advanced_get_tile_terrain(tile: TileKey) -> int
```

Get the terrain index of a tile

### advanced_clear_tile_mask

```gdscript
func advanced_clear_tile_mask(tile: TileKey) -> void
```

Clear the "Advanced Autotiles" mask of a tile (set all flags to "empty")

### advanced_get_tile_mask

```gdscript
func advanced_get_tile_mask(tile: TileKey) -> Dictionary
```

Get the "Advanced Autotiles" mask of a tile

### advanced_get_tiles

```gdscript
func advanced_get_tiles() -> Array[TileKey]
```

Returns an array of tile keys objects, for all tiles in all the atlas sources
of this tile set.

### get_tile_data

```gdscript
func get_tile_data(tile: TileKey) -> TileData
```

Return the [TileData] of a tile identified by a [TileKey]

### advanced_get_terrains_count

```gdscript
func advanced_get_terrains_count() -> int
```

Get the number of "Advanced Autotile" terrains defined for this tileset.

### advanced_get_terrain_name

```gdscript
func advanced_get_terrain_name(terrain_index: int) -> String
```

Get the name of the "Advanced Autotile" terrain at this index.

### advanced_set_terrain_name

```gdscript
func advanced_set_terrain_name(terrain_index: int, name: String) -> void
```

Set the name of an "Advanced Autotile" terrain

### advanced_get_tile_terrain_color

```gdscript
func advanced_get_tile_terrain_color(terrain_index: int) -> Color
```

Get the color assigned to an "Advanced Autotile" terrain (for use in editor)

### advanced_set_tile_terrain_color

```gdscript
func advanced_set_tile_terrain_color(terrain_index: int, color: Color) -> void
```

Set the color assigned to an "Advanced Autotile" terrain (for use in editor)

### advanced_get_terrain_auto_binding

```gdscript
func advanced_get_terrain_auto_binding(terrain_index: int) -> bool
```

If true, binding will be determined automatically for the specified
"Advanced Autotile" terrain

### advanced_get_terrain_priority

```gdscript
func advanced_get_terrain_priority(terrain_index: int) -> int
```

Get the priority of the specified "Advanced Autotile" terrain

### advanced_set_terrain_priority

```gdscript
func advanced_set_terrain_priority(terrain_index: int, priority: int) -> void
```

Set the priority of the specified "Advanced Autotile" terrain

### advanced_get_terrain_has_tiles

```gdscript
func advanced_get_terrain_has_tiles(terrain_id: int) -> bool
```

Test whether the specified "Advanced Autotile" terrain has any tiles
assigned to it.

### _recalc

```gdscript
func _recalc() -> void
```

### _advanced_terrain_update_auto_bindings

```gdscript
func _advanced_terrain_update_auto_bindings() -> void
```

### _advanced_terrain_update_priorities

```gdscript
func _advanced_terrain_update_priorities() -> void
```

### _clear_advanced_tile_data

```gdscript
func _clear_advanced_tile_data(tile: TileKey, key: String) -> void
```

### _apply_base_overrides

```gdscript
func _apply_base_overrides() -> void
```

### _get_bindings_hint_string

```gdscript
func _get_bindings_hint_string(include_empty := true) -> String
```

### _queue_signal

```gdscript
func _queue_signal(signal_object: Signal) -> void
```

### _emit_queued_signals

```gdscript
func _emit_queued_signals() -> void
```

### _init

```gdscript
func _init(source_id: int, coords: Vector2i, alternative_id: int)
```

### equals

```gdscript
func equals(other_tile: TileKey) -> bool
```

Test if this key identifies the same tile as another key

### _init

```gdscript
func _init(init_name: String, init_color: Color) -> void
```

## Member Data Documentation

### empty_terrain_bindings

```gdscript
var empty_terrain_bindings: int
```

Decorators: `@export`

Bitmask of bindings for the "empty" terrain.

### empty_terrain_priority

```gdscript
var empty_terrain_priority: int
```

Decorators: `@export_range(1, 100, 1, "or_greater")`

Priority of the "empty" terrain.

### _terrains

```gdscript
var _terrains: Array[Terrain]
```

### _queued_signals

```gdscript
var _queued_signals: Array[Signal]
```

### terrain_index

```gdscript
var terrain_index: int
```

### flags

```gdscript
var flags: PackedInt32Array
```

### layer_index

```gdscript
var layer_index: int
```

### custom_data

```gdscript
var custom_data: Dictionary
```

### hint_strings

```gdscript
var hint_strings: PackedStringArray
```

### source_id

```gdscript
var source_id: int
```

### coords

```gdscript
var coords: Vector2i
```

### alternative_id

```gdscript
var alternative_id: int
```

### mode

```gdscript
var mode: TileGeometry.ConnectionMode
```

### bindings

```gdscript
var bindings: int
```

### priority

```gdscript
var priority: int
```

## Signal Documentation

### terrains_changed

```gdscript
signal terrains_changed
```

Emitted when the terrains setup changes. (Other changes use the
`signal changed` signal.
