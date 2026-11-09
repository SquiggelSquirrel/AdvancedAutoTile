# AdvancedTileMapLayer Class Reference

*File:* `addons/advanced_autotiles/advanced_tile_map_layer/advanced_tile_map_layer.gd`
*Class name:* `AdvancedTileMapLayer`
*Inherits:* `TileMapLayer`

## Synopsis

```gdscript
class_name AdvancedTileMapLayer
extends TileMapLayer
```

## Brief

TileMapLayer for Advanced Autotiles plugin

Hide the base `member TileMapLayer.tile_set` property

Get neighbor cell.

## Detailed Description

Intended as a replacement for
`method TileMapLayer.get_neighbor_cell`, but using [TileGeometry] enums
and supporting triangle cells

Paint the specified cells with the given Advanced Autotile terrain, and
updates the surrounding cells.
Optionally try to preserve surrounding connections with non-painted cells.
Returns a Dictionary[Vector2i: Dictionary[String: TileKey]]
of cell co-ord, "old" and "new" tiles (optionally dry-run to only return
dictionary without applying changes).

Paint a path of cells using Advanced Autotile terrain.
Will only try to create new high-priority connections where consecutive
cells in the path are adjacent.
Returns a Dictionary[Vector2i: Dictionary[String: TileKey]]
of cell co-ord, "old" and "new" tiles (optionally dry-run to only return
dictionary without applying changes).

Paint connections using Advanced Autotile terrain, without changing the
cells terrain. Cells are paired up with flags (if more cell than flags are
given, flags array will wrap) to specify connections. Each connection only
needs to be specified from one cell - additional cell-flags are implied.
Returns a Dictionary[Vector2i: Dictionary[String: TileKey]]
of cell co-ord, "old" and "new" tiles (optionally dry-run to only return
dictionary without applying changes).

Flood fills with a given Advanded Autotile terrain, from a given start cell.
Returns a Dictionary[Vector2i: Dictionary[String: TileKey]]
of cell co-ord, "old" and "new" tiles (optionally dry-run to only return
dictionary without applying changes).

Choose a tile for the given cell, based on incoming terrains.
Optionally provide a mask (dictionary of flag:terrain_id) to try and match.
Returns a dictionary of "old": TileKey, "new": TileKey, or an empty
dictionary if no change should occur.
Optionally dry-run to only get dictionary result without applying change.

Get the mask of the existing tile in this cell, or an empty dictionary
if no tile is present (or a tile with invalid orientation).

Get all the cells surrounding (but not included in) the given array of cells.

Get the cells surrounding the given cell. Similar to
`method TileMapLayer.get_surrounding_cells`, but with support for triangles
and diagonals (optionally).

Get relevant neighbor cells for the given flag + connection mode.

Give a cell, mode, and flag for a mask, get the neighbor flags for relevant
cells. 
(For every mode except match-corners, and every flag that isn't a corner
flag, there is one neighbor flag, it is just the same as the mask flag)

Get the side flags either side of a diagonal flag

Intended only for internal use by [AdvancedTileMapLayer].
Represents a tile-match priority.

Intended for internal use by AdvancedTileMapLayer
Represents a set of constraints on a grid - each can be an edge between
two cells, a corner-intersection, or a diagonal between two cells.
Each has one terrain.

## Public Member Functions

- `func _validate_property(property: Dictionary) -> void`
- `func advanced_local_to_map(local: Vector2) -> Vector2i` — Get map co-ordinates under point.
- `func add_incoming_terrain(terrain_id: int, cells: Array[Vector2i]) -> void` — Add an incoming terrain-to-be-painted in one or more cells, so that
autotiling will connect with that terrain and not the existing one.
- `func clear_incoming_terrains() -> void` — Clear incoming terrains (see `method add_incoming_terrain` and
- `func advanced_get_final_cell_terrain(cell: Vector2i) -> int` — Get the incoming terrain for this cell, or the existing terrain if there is
no incoming terrain.
- `func advanced_get_existing_tile(cell: Vector2i) -> AdvancedTileSet.TileKey` — Get the TileKey for the tile already in this cell
- `func advanced_get_cell_orientation(coords: Vector2i) -> TileGeometry.Orientation` — Get orientation of the specified cell
- `func add_priorty(priority: int) -> void` — Add one flag-match priority
- `func compare(other: TilePriority) -> Comparison` — Compare with another TilePriority, based on count of flag-matches
in descending flag-match priority order.
- `func get_count() -> int`
- `func get_cell(index: int) -> Vector2i`
- `func get_flag(index: int) -> TileGeometry.CellNeighbor`
- `func get_mode(index: int) -> TileGeometry.ConnectionMode`
- `func get_is_diagonal(index: int) -> bool`

## Public Attributes

- `AdvancedTileSet: advanced_tile_set` — Base `member TileMapLayer.tile_set` property as an [AdvancedTileSet]
- `Dictionary[Vector2i, int] _incoming_terrains`
- `Dictionary[Vector2i, Dictionary] changes`
- `PackedInt32Array pathable_flags`
- `change`
- `Array[Vector2i] cells`
- `Callable is_match`
- `Array[Vector2i] queue`
- `Array[AdvancedTileSet.TileKey] candidates`
- `Array[Vector2i] surrounding_cells`
- `TileGeometry.ConnectionMode mode`
- `Array[Vector2i] result_cells`
- `Dictionary mask`
- `TileGeometry.Shape shape`
- `TileGeometry.Axis axis`
- `Dictionary[String, int] data`
- `Vector2i key_cell`
- `TileGeometry.CellNeighbor key_flag`
- `TileGeometry.CellNeighbor return_flag`
- `TileGeometry.CellNeighbor neighbor_flag`

## Enumerations

- `enum Comparison`
- `enum FlagType`

## Member Function Documentation

### _validate_property

```gdscript
func _validate_property(property: Dictionary) -> void
```

### advanced_local_to_map

```gdscript
func advanced_local_to_map(local: Vector2) -> Vector2i
```

Get map co-ordinates under point. Intended as a replacement for
`method TileMapLayer.local_to_map`, but with support for triangle cells.

### add_incoming_terrain

```gdscript
func add_incoming_terrain(terrain_id: int, cells: Array[Vector2i]) -> void
```

Add an incoming terrain-to-be-painted in one or more cells, so that
autotiling will connect with that terrain and not the existing one.
Lower-level than most autotiling functions, intended for use with
`method advanced_autotile_choose_tile`.
Caution: remember to clear incoming terrains after you're done autotiling.

### clear_incoming_terrains

```gdscript
func clear_incoming_terrains() -> void
```

Clear incoming terrains (see `method add_incoming_terrain` and
`method advanced_autotile_choose_tile`)

### advanced_get_final_cell_terrain

```gdscript
func advanced_get_final_cell_terrain(cell: Vector2i) -> int
```

Get the incoming terrain for this cell, or the existing terrain if there is
no incoming terrain.

### advanced_get_existing_tile

```gdscript
func advanced_get_existing_tile(cell: Vector2i) -> AdvancedTileSet.TileKey
```

Get the TileKey for the tile already in this cell

### advanced_get_cell_orientation

```gdscript
func advanced_get_cell_orientation(coords: Vector2i) -> TileGeometry.Orientation
```

Get orientation of the specified cell

### add_priorty

```gdscript
func add_priorty(priority: int) -> void
```

Add one flag-match priority

### compare

```gdscript
func compare(other: TilePriority) -> Comparison
```

Compare with another TilePriority, based on count of flag-matches
in descending flag-match priority order.

### get_count

```gdscript
func get_count() -> int
```

### get_cell

```gdscript
func get_cell(index: int) -> Vector2i
```

### get_flag

```gdscript
func get_flag(index: int) -> TileGeometry.CellNeighbor
```

### get_mode

```gdscript
func get_mode(index: int) -> TileGeometry.ConnectionMode
```

### get_is_diagonal

```gdscript
func get_is_diagonal(index: int) -> bool
```

## Member Data Documentation

### advanced_tile_set

```gdscript
var advanced_tile_set: AdvancedTileSet:
```

Decorators: `@export`

Base `member TileMapLayer.tile_set` property as an [AdvancedTileSet]

### _incoming_terrains

```gdscript
var _incoming_terrains: Dictionary[Vector2i, int]
```

### changes

```gdscript
var changes: Dictionary[Vector2i, Dictionary]
```

### pathable_flags

```gdscript
var pathable_flags: PackedInt32Array
```

### change

```gdscript
var change
```

### cells

```gdscript
var cells: Array[Vector2i]
```

### is_match

```gdscript
var is_match: Callable
```

### queue

```gdscript
var queue: Array[Vector2i]
```

### candidates

```gdscript
var candidates: Array[AdvancedTileSet.TileKey]
```

### surrounding_cells

```gdscript
var surrounding_cells: Array[Vector2i]
```

### mode

```gdscript
var mode: TileGeometry.ConnectionMode
```

### result_cells

```gdscript
var result_cells: Array[Vector2i]
```

### mask

```gdscript
var mask: Dictionary
```

### shape

```gdscript
var shape: TileGeometry.Shape
```

### axis

```gdscript
var axis: TileGeometry.Axis
```

### data

```gdscript
var data: Dictionary[String, int]
```

### key_cell

```gdscript
var key_cell: Vector2i
```

### key_flag

```gdscript
var key_flag: TileGeometry.CellNeighbor
```

### return_flag

```gdscript
var return_flag: TileGeometry.CellNeighbor
```

### neighbor_flag

```gdscript
var neighbor_flag: TileGeometry.CellNeighbor
```

## Enumeration Type Documentation

### Comparison

```gdscript
enum Comparison
```

### FlagType

```gdscript
enum FlagType
```
