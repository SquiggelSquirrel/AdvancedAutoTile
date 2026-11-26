# TileGeometry

**Inherits:** [`Object`](https://docs.godotengine.org/en/stable/classes/class_object.html)

A utility class with enums and static methods for use by Advanced Autotile plugin - not intended for instantiation.

## Methods

| Returns | Signature |
|---------|-----------|
| `TileSet.CellNeighbor` | <code><a href="#method-advanced_neighbor_to_base_neighbor">advanced_neighbor_to_base_neighbor</a>(advanced_neighbor: <a href="#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-shape_supports_diagonal_connections">shape_supports_diagonal_connections</a>(shape: <a href="#enum-Shape">Shape</a>)</code> |
| `TileGeometry.ConnectionMode[]` | <code><a href="#method-get_connection_modes">get_connection_modes</a>(shape: <a href="#enum-Shape">Shape</a>)</code> |
| `TileGeometry.Orientation[]` | <code><a href="#method-get_orientations">get_orientations</a>(shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>)</code> |
| [`PackedInt32Array`](https://docs.godotengine.org/en/stable/classes/class_packedint32array.html) | <code><a href="#method-get_flags">get_flags</a>(mode: <a href="#enum-ConnectionMode">ConnectionMode</a>, shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |
| [`CellNeighbor`](#enum-CellNeighbor) | <code><a href="#method-get_tile_outline_points">get_tile_outline_points</a>(shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |
| [`PackedVector2Array`](https://docs.godotengine.org/en/stable/classes/class_packedvector2array.html) | <code><a href="#method-get_tile_polygon">get_tile_polygon</a>(shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |
| [`CellNeighbor`](#enum-CellNeighbor) | <code><a href="#method-cell_neighbor_flip_h">cell_neighbor_flip_h</a>(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`CellNeighbor`](#enum-CellNeighbor) | <code><a href="#method-cell_neighbor_flip_v">cell_neighbor_flip_v</a>(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`CellNeighbor`](#enum-CellNeighbor) | <code><a href="#method-cell_neighbor_transpose">cell_neighbor_transpose</a>(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | <code><a href="#method-get_triangle_neighbor_cell">get_triangle_neighbor_cell</a>(coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, neighbor: <a href="#enum-CellNeighbor">CellNeighbor</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |
| [`CellNeighbor`](#enum-CellNeighbor) | <code><a href="#method-get_flag_polygons">get_flag_polygons</a>(shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>, mode: <a href="#enum-ConnectionMode">ConnectionMode</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |
| `TileGeometry.CellNeighbor[]` | <code><a href="#method-get_corners_of_side">get_corners_of_side</a>(side_flag: <a href="#enum-CellNeighbor">CellNeighbor</a>, shape: <a href="#enum-Shape">Shape</a>, axis: <a href="#enum-Axis">Axis</a>, orientation: <a href="#enum-Orientation">Orientation</a>)</code> |

## Constants

<a id="constant-CENTER_FLAG_SHRINK"></a>

**<code>CENTER_FLAG_SHRINK = 0.6</code>**

Amount to shrink the outline by, to get the center flag polygon.

<a id="constant-FLAG_EMPTY"></a>

**<code>FLAG_EMPTY = -1</code>**

Terrain index for "empty"

<a id="enum-Shape"></a>

### enum `Shape`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-Shape-SQUARE"></a> `SQUARE` | `0` |  |
| <a id="enum-Shape-ISOMETRIC"></a> `ISOMETRIC` | `1` |  |
| <a id="enum-Shape-HALF_OFFSET_SQUARE"></a> `HALF_OFFSET_SQUARE` | `2` |  |
| <a id="enum-Shape-HEXAGON"></a> `HEXAGON` | `3` |  |
| <a id="enum-Shape-TRIANGLE"></a> `TRIANGLE` | `4` |  |

<a id="enum-Layout"></a>

### enum `Layout`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-Layout-STACKED"></a> `STACKED` | `0` |  |
| <a id="enum-Layout-STACKED_OFFSET"></a> `STACKED_OFFSET` | `1` |  |
| <a id="enum-Layout-STAIRS_RIGHT"></a> `STAIRS_RIGHT` | `2` |  |
| <a id="enum-Layout-STAIRS_DOWN"></a> `STAIRS_DOWN` | `3` |  |
| <a id="enum-Layout-DIAMOND_RIGHT"></a> `DIAMOND_RIGHT` | `4` |  |
| <a id="enum-Layout-DIAMOND_DOWN"></a> `DIAMOND_DOWN` | `5` |  |

<a id="enum-Axis"></a>

### enum `Axis`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-Axis-HORIZONTAL"></a> `HORIZONTAL` | `0` | Horizontal half-offet, or triangles with a horizontal edge |
| <a id="enum-Axis-VERTICAL"></a> `VERTICAL` | `1` | Vertical half-offset, or triangles with a vertical edge |

<a id="enum-Orientation"></a>

### enum `Orientation`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-Orientation-UP"></a> `UP` | `0` | Bottom side and top corner |
| <a id="enum-Orientation-DOWN"></a> `DOWN` | `1` | Top side and bottom corner |
| <a id="enum-Orientation-LEFT"></a> `LEFT` | `2` | Right side and left corner |
| <a id="enum-Orientation-RIGHT"></a> `RIGHT` | `3` | Left side and right corner |

<a id="enum-ConnectionMode"></a>

### enum `ConnectionMode`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-ConnectionMode-NONE"></a> `NONE` | `0` |  |
| <a id="enum-ConnectionMode-CORNERS"></a> `CORNERS` | `1` |  |
| <a id="enum-ConnectionMode-EDGES"></a> `EDGES` | `2` |  |
| <a id="enum-ConnectionMode-DIAGONALS"></a> `DIAGONALS` | `4` |  |
| <a id="enum-ConnectionMode-NON_ACUTE"></a> `NON_ACUTE` | `8` |  |
| <a id="enum-ConnectionMode-CORNERS_AND_EDGES"></a> `CORNERS_AND_EDGES` | `3` |  |
| <a id="enum-ConnectionMode-EDGES_AND_DIAGONALS"></a> `EDGES_AND_DIAGONALS` | `6` |  |
| <a id="enum-ConnectionMode-EDGES_AND_NON_ACUTE_DIAGONALS"></a> `EDGES_AND_NON_ACUTE_DIAGONALS` | `14` |  |

<a id="enum-CellNeighbor"></a>

### enum `CellNeighbor`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-CellNeighbor-SELF"></a> `SELF` | `0` |  |
| <a id="enum-CellNeighbor-SIDE"></a> `SIDE` | `1` |  |
| <a id="enum-CellNeighbor-CORNER"></a> `CORNER` | `2` |  |
| <a id="enum-CellNeighbor-TOP"></a> `TOP` | `4` |  |
| <a id="enum-CellNeighbor-RIGHT"></a> `RIGHT` | `8` |  |
| <a id="enum-CellNeighbor-BOTTOM"></a> `BOTTOM` | `16` |  |
| <a id="enum-CellNeighbor-LEFT"></a> `LEFT` | `32` |  |
| <a id="enum-CellNeighbor-CLOCKWISE"></a> `CLOCKWISE` | `64` |  |
| <a id="enum-CellNeighbor-COUNTERCLOCKWISE"></a> `COUNTERCLOCKWISE` | `128` |  |
| <a id="enum-CellNeighbor-TOP_SIDE"></a> `TOP_SIDE` | `5` |  |
| <a id="enum-CellNeighbor-RIGHT_SIDE"></a> `RIGHT_SIDE` | `9` |  |
| <a id="enum-CellNeighbor-BOTTOM_SIDE"></a> `BOTTOM_SIDE` | `17` |  |
| <a id="enum-CellNeighbor-LEFT_SIDE"></a> `LEFT_SIDE` | `33` |  |
| <a id="enum-CellNeighbor-TOP_RIGHT_SIDE"></a> `TOP_RIGHT_SIDE` | `13` |  |
| <a id="enum-CellNeighbor-BOTTOM_RIGHT_SIDE"></a> `BOTTOM_RIGHT_SIDE` | `25` |  |
| <a id="enum-CellNeighbor-BOTTOM_LEFT_SIDE"></a> `BOTTOM_LEFT_SIDE` | `49` |  |
| <a id="enum-CellNeighbor-TOP_LEFT_SIDE"></a> `TOP_LEFT_SIDE` | `37` |  |
| <a id="enum-CellNeighbor-TOP_CORNER"></a> `TOP_CORNER` | `6` |  |
| <a id="enum-CellNeighbor-RIGHT_CORNER"></a> `RIGHT_CORNER` | `10` |  |
| <a id="enum-CellNeighbor-BOTTOM_CORNER"></a> `BOTTOM_CORNER` | `18` |  |
| <a id="enum-CellNeighbor-LEFT_CORNER"></a> `LEFT_CORNER` | `34` |  |
| <a id="enum-CellNeighbor-TOP_RIGHT_CORNER"></a> `TOP_RIGHT_CORNER` | `14` |  |
| <a id="enum-CellNeighbor-BOTTOM_RIGHT_CORNER"></a> `BOTTOM_RIGHT_CORNER` | `26` |  |
| <a id="enum-CellNeighbor-BOTTOM_LEFT_CORNER"></a> `BOTTOM_LEFT_CORNER` | `50` |  |
| <a id="enum-CellNeighbor-TOP_LEFT_CORNER"></a> `TOP_LEFT_CORNER` | `38` |  |
| <a id="enum-CellNeighbor-TOP_CLOCKWISE_CORNER"></a> `TOP_CLOCKWISE_CORNER` | `70` |  |
| <a id="enum-CellNeighbor-RIGHT_CLOCKWISE_CORNER"></a> `RIGHT_CLOCKWISE_CORNER` | `74` |  |
| <a id="enum-CellNeighbor-BOTTOM_CLOCKWISE_CORNER"></a> `BOTTOM_CLOCKWISE_CORNER` | `82` |  |
| <a id="enum-CellNeighbor-LEFT_CLOCKWISE_CORNER"></a> `LEFT_CLOCKWISE_CORNER` | `98` |  |
| <a id="enum-CellNeighbor-TOP_RIGHT_CLOCKWISE_CORNER"></a> `TOP_RIGHT_CLOCKWISE_CORNER` | `78` |  |
| <a id="enum-CellNeighbor-BOTTOM_RIGHT_CLOCKWISE_CORNER"></a> `BOTTOM_RIGHT_CLOCKWISE_CORNER` | `90` |  |
| <a id="enum-CellNeighbor-BOTTOM_LEFT_CLOCKWISE_CORNER"></a> `BOTTOM_LEFT_CLOCKWISE_CORNER` | `114` |  |
| <a id="enum-CellNeighbor-TOP_LEFT_CLOCKWISE_CORNER"></a> `TOP_LEFT_CLOCKWISE_CORNER` | `102` |  |
| <a id="enum-CellNeighbor-TOP_COUNTERCLOCKWISE_CORNER"></a> `TOP_COUNTERCLOCKWISE_CORNER` | `134` |  |
| <a id="enum-CellNeighbor-RIGHT_COUNTERCLOCKWISE_CORNER"></a> `RIGHT_COUNTERCLOCKWISE_CORNER` | `138` |  |
| <a id="enum-CellNeighbor-BOTTOM_COUNTERCLOCKWISE_CORNER"></a> `BOTTOM_COUNTERCLOCKWISE_CORNER` | `146` |  |
| <a id="enum-CellNeighbor-LEFT_COUNTERCLOCKWISE_CORNER"></a> `LEFT_COUNTERCLOCKWISE_CORNER` | `162` |  |
| <a id="enum-CellNeighbor-TOP_RIGHT_COUNTERCLOCKWISE_CORNER"></a> `TOP_RIGHT_COUNTERCLOCKWISE_CORNER` | `142` |  |
| <a id="enum-CellNeighbor-BOTTOM_RIGHT_COUNTERCLOCKWISE_CORNER"></a> `BOTTOM_RIGHT_COUNTERCLOCKWISE_CORNER` | `154` |  |
| <a id="enum-CellNeighbor-BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER"></a> `BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER` | `178` |  |
| <a id="enum-CellNeighbor-TOP_LEFT_COUNTERCLOCKWISE_CORNER"></a> `TOP_LEFT_COUNTERCLOCKWISE_CORNER` | `166` |  |

## Method Descriptions

<a id="method-advanced_neighbor_to_base_neighbor"></a>

### <code>advanced_neighbor_to_base_neighbor</code>

<pre><code>func advanced_neighbor_to_base_neighbor(advanced_neighbor: <a href="#enum-CellNeighbor">CellNeighbor</a>) -> TileSet.CellNeighbor:</code></pre>

Convert an TileGeometry.CellNeighbor (Advanced Autotiles Plugin) to a TileSet.CellNeighbor (base Godot engine)

<a id="method-shape_supports_diagonal_connections"></a>

### <code>shape_supports_diagonal_connections</code>

<pre><code>func shape_supports_diagonal_connections(shape: <a href="#enum-Shape">Shape</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

Check whether diagonal connections make sense for a grid of given shape.

<a id="method-get_connection_modes"></a>

### <code>get_connection_modes</code>

<pre><code>func get_connection_modes(shape: <a href="#enum-Shape">Shape</a>) -> TileGeometry.ConnectionMode[]:</code></pre>

Returns an array of connection modes supported for the given shape

<a id="method-get_orientations"></a>

### <code>get_orientations</code>

<pre><code>func get_orientations(
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>
) -> TileGeometry.Orientation[]:</code></pre>

Returns an array of orientations supported for the given shape and axis

<a id="method-get_flags"></a>

### <code>get_flags</code>

<pre><code>func get_flags(
    mode: <a href="#enum-ConnectionMode">ConnectionMode</a>,
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_packedint32array.html">PackedInt32Array</a>:</code></pre>

Returns an array of autotile mask flags supported for the given terrain mode, tile shape, axis, and orientation

<a id="method-get_tile_outline_points"></a>

### <code>get_tile_outline_points</code>

<pre><code>func get_tile_outline_points(
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> <a href="#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

Get tile outline points, keyed by corner flags For tile size(1.0, 1.0) - scale as needed.

<a id="method-get_tile_polygon"></a>

### <code>get_tile_polygon</code>

<pre><code>func get_tile_polygon(
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_packedvector2array.html">PackedVector2Array</a>:</code></pre>

Get outline polygon for given tile shape, axis, and orientation For tile size(1.0, 1.0) - scale as needed. (n.b. half-offset squares get 6 points, to guarantee every polygon has (one point per corner flag. It just makes things easier.)

<a id="method-cell_neighbor_flip_h"></a>

### <code>cell_neighbor_flip_h</code>

<pre><code>func cell_neighbor_flip_h(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>) -> <a href="#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

Flip a cell neighbor flag horizontally

<a id="method-cell_neighbor_flip_v"></a>

### <code>cell_neighbor_flip_v</code>

<pre><code>func cell_neighbor_flip_v(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>) -> <a href="#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

Flip a cell neighbor flag vertically

<a id="method-cell_neighbor_transpose"></a>

### <code>cell_neighbor_transpose</code>

<pre><code>func cell_neighbor_transpose(neighbor_in: <a href="#enum-CellNeighbor">CellNeighbor</a>) -> <a href="#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

Transpose the horizontal/vertical components of a cell neighbor flag

<a id="method-get_triangle_neighbor_cell"></a>

### <code>get_triangle_neighbor_cell</code>

<pre><code>func get_triangle_neighbor_cell(
    coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    neighbor: <a href="#enum-CellNeighbor">CellNeighbor</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>:</code></pre>

Get the coordinates of a neighboring cell in a triangle grid.

<a id="method-get_flag_polygons"></a>

### <code>get_flag_polygons</code>

<pre><code>func get_flag_polygons(
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>,
    mode: <a href="#enum-ConnectionMode">ConnectionMode</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> <a href="#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

Get polygons used for drawing tile mask flags in-editor

<a id="method-get_corners_of_side"></a>

### <code>get_corners_of_side</code>

<pre><code>func get_corners_of_side(
    side_flag: <a href="#enum-CellNeighbor">CellNeighbor</a>,
    shape: <a href="#enum-Shape">Shape</a>,
    axis: <a href="#enum-Axis">Axis</a>,
    orientation: <a href="#enum-Orientation">Orientation</a>
) -> TileGeometry.CellNeighbor[]:</code></pre>

Get the corner flags around the given side flag
