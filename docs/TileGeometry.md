# TileGeometry Class Reference

*File:* `addons/advanced_autotiles/advanced_tile_set/tile_geometry.gd`
*Class name:* `TileGeometry`
*Inherits:* `Object`

## Synopsis

```gdscript
class_name TileGeometry
extends Object
```

## Brief

A utility class with enums and static methods for use by Advanced Autotile
plugin - not intended for instantiation.

## Detailed Description

Amount to shrink the outline by, to get the center flag polygon.

Terrain index for "empty"

Tile shapes suppored by advanced autotile plugin

Half-offset tile layouts supported by advanced autotile plugin
(i.e. mapping from co-ordinates to position in grid)
Some layouts only apply to some shapes, see `method get_tile_shape_layouts`

Tile layout axis (offset axis for hexagon or half-offset, orientations
for triangle layouts) see `method get_tile_shape_axes`

Tile orientations (for triangle shapes only)

Connection modes supported by Advanced Autotiles plugin.
Available modes depend on tile shape
(see `method get_tile_shape_terrain_modes`).
Diagonals-only mode is not supported for any shape,
but is included for bitwise logic testing on the compound flags.

Cell Neighbor flags, defined to support triangle layouts
and bit-wise logic

Convert an TileGeometry.CellNeighbor (Advanced Autotiles Plugin)
to a TileSet.CellNeighbor (base Godot engine)

Returns an array of orientations supported for the given shape and axis

Returns an array of autotile mask flags supported for the given terrain mode,
tile shape, axis, and orientation

Get tile outline points, keyed by corner flags
For tile size(1.0, 1.0) - scale as needed.

Get outline polygon for given tile shape, axis, and orientation
For tile size(1.0, 1.0) - scale as needed.
(n.b. half-offset squares get 6 points, to guarantee every polygon has
(one point per corner flag. It just makes things easier.)

Get the coordinates of a neighboring cell in a triangle grid.

Get polygons used for drawing tile mask flags in-editor

Get the corner flags around the given side flag

Static class mapping [TileGeometry] enums to Godot built-in enums

Return the `enum TileSet.TileShape` corresponding
the given to `enum TileGeometry.TileShape`
(Triangle maps to Square because triangle are implemented using squares).

Return the `enum TileSet.TileLayout` corresponding to the given
`enum TileGeometry.Layout`

Return the given `enum TileSet.TileOffsetAxis` corresponding to the given
`enum TileGeometry.Axis`

Get the base tile size corresponding to the Advanced Autotile tile size
(since triangles are implemented using smaller squares)

## Public Member Functions

- `func shape_has_diagonals(shape: Shape) -> bool` — Check whether diagonals make sense for a grid of given shape.
- `func get_connection_modes(shape: Shape) -> Array[ConnectionMode]` — Returns an array of connection modes supported for the given shape
- `func cell_neighbor_flip_h(neighbor_in: CellNeighbor) -> CellNeighbor` — Flip a cell neighbor flag horizontally
- `func cell_neighbor_flip_v(neighbor_in: CellNeighbor) -> CellNeighbor` — Flip a cell neighbor flag vertically
- `func cell_neighbor_transpose(neighbor_in: CellNeighbor) -> CellNeighbor` — Transpose the horizontal/vertical components of a cell neighbor flag
- `func _setup_triangle_offsets() -> void`
- `func _points_average(points: PackedVector2Array) -> Vector2`

## Public Attributes

- `String advanced_key`
- `String target_key`
- `PackedInt32Array corners`
- `PackedInt32Array sides`
- `Dictionary[CellNeighbor, Vector2] points`
- `Dictionary[CellNeighbor, Vector2] mirrored_points`
- `Dictionary[CellNeighbor, Vector2] transposed_points`
- `Dictionary[TileGeometry.CellNeighbor, Vector2i] offsets`
- `Dictionary[TileGeometry.CellNeighbor, PackedVector2Array] polygons`

## Public Constants

- `const _UP_TRIANGLE_NEIGHBOR_OFFSETS: Dictionary[TileGeometry.CellNeighbor, Vector2i]`

## Member Function Documentation

### shape_has_diagonals

```gdscript
func shape_has_diagonals(shape: Shape) -> bool
```

Check whether diagonals make sense for a grid of given shape.

### get_connection_modes

```gdscript
func get_connection_modes(shape: Shape) -> Array[ConnectionMode]
```

Returns an array of connection modes supported for the given shape

### cell_neighbor_flip_h

```gdscript
func cell_neighbor_flip_h(neighbor_in: CellNeighbor) -> CellNeighbor
```

Flip a cell neighbor flag horizontally

### cell_neighbor_flip_v

```gdscript
func cell_neighbor_flip_v(neighbor_in: CellNeighbor) -> CellNeighbor
```

Flip a cell neighbor flag vertically

### cell_neighbor_transpose

```gdscript
func cell_neighbor_transpose(neighbor_in: CellNeighbor) -> CellNeighbor
```

Transpose the horizontal/vertical components of a cell neighbor flag

### _setup_triangle_offsets

```gdscript
func _setup_triangle_offsets() -> void
```

### _points_average

```gdscript
func _points_average(points: PackedVector2Array) -> Vector2
```

## Member Data Documentation

### advanced_key

```gdscript
var advanced_key: String
```

### target_key

```gdscript
var target_key: String
```

### corners

```gdscript
var corners: PackedInt32Array
```

### sides

```gdscript
var sides: PackedInt32Array
```

### points

```gdscript
var points: Dictionary[CellNeighbor, Vector2]
```

### mirrored_points

```gdscript
var mirrored_points: Dictionary[CellNeighbor, Vector2]
```

### transposed_points

```gdscript
var transposed_points: Dictionary[CellNeighbor, Vector2]
```

### offsets

```gdscript
var offsets: Dictionary[TileGeometry.CellNeighbor, Vector2i]
```

### polygons

```gdscript
var polygons: Dictionary[TileGeometry.CellNeighbor, PackedVector2Array]
```

## Constant Documentation

### _UP_TRIANGLE_NEIGHBOR_OFFSETS

```gdscript
const _UP_TRIANGLE_NEIGHBOR_OFFSETS: Dictionary[TileGeometry.CellNeighbor, Vector2i]
```
