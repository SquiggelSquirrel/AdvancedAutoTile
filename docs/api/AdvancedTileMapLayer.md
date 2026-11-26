# AdvancedTileMapLayer

**Inherits:** [`TileMapLayer`](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)

TileMapLayer for Advanced Autotiles plugin

## Description

Node for 2D tile-based maps using the Advanced Autotiles plugin. Extends Godot's built-in `TileMapLayer` node.

For basic auto-tile usage, I recommend using [`advanced_autotile_paint_cells()`](#method-advanced_autotile_paint_cells), [`advanced_autotile_paint_path()`](#method-advanced_autotile_paint_path), or for "dual-grid": [`advanced_autotile_paint_connections()`](#method-advanced_autotile_paint_connections).

## Properties

| Type | Name | Default |
|------|------|---------|
| [`AdvancedTileSet`](AdvancedTileSet.md) | [`advanced_tile_set`](#property-advanced_tile_set) |  |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | [`hide_base_class_features`](#property-hide_base_class_features) | `true` |

## Methods

| Returns | Signature |
|---------|-----------|
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | <code><a href="#method-advanced_get_neighbor_cell">advanced_get_neighbor_cell</a>(coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, neighbor: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | <code><a href="#method-advanced_local_to_map">advanced_local_to_map</a>(local: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2.html">Vector2</a>)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_autotile_paint_cells">advanced_autotile_paint_cells</a>(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>], preserve_surrounding_connections: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = true, dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_autotile_paint_path">advanced_autotile_paint_path</a>(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, path: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>], dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_autotile_paint_connections">advanced_autotile_paint_connections</a>(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>], flags: TileGeometry.CellNeighbor[], dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_autotile_flood_fill">advanced_autotile_flood_fill</a>(start_cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| `void` | <code><a href="#method-add_incoming_terrain">add_incoming_terrain</a>(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>])</code> |
| `void` | <code><a href="#method-clear_incoming_terrains">clear_incoming_terrains</a>()</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_autotile_choose_tile">advanced_autotile_choose_tile</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, prioritize_mask: <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a> = {}, dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-advanced_get_final_cell_terrain">advanced_get_final_cell_terrain</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_get_existing_cell_mask">advanced_get_existing_cell_mask</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>)</code> |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html)] | <code><a href="#method-get_cells_surrounding_cells">get_cells_surrounding_cells</a>(cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>], include_diagonals: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html)] | <code><a href="#method-advanced_get_surrounding_cells">advanced_get_surrounding_cells</a>(coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, include_diagonals: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false)</code> |
| [`AdvancedTileSet.TileKey`](AdvancedTileSet.TileKey.md) | <code><a href="#method-advanced_get_existing_tile">advanced_get_existing_tile</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>)</code> |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html)] | <code><a href="#method-advanced_get_neighbor_cells_for_flag">advanced_get_neighbor_cells_for_flag</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| `TileGeometry.CellNeighbor[]` | <code><a href="#method-advanced_get_neighbor_flags_for_flag">advanced_get_neighbor_flags_for_flag</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| `TileGeometry.CellNeighbor[]` | <code><a href="#method-advanced_get_side_flags_for_diagonal">advanced_get_side_flags_for_diagonal</a>(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, diagonal_flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>)</code> |
| [`Orientation`](TileGeometry.md#enum-Orientation) | <code><a href="#method-advanced_get_cell_orientation">advanced_get_cell_orientation</a>(coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>)</code> |

## Property Descriptions

<a id="property-advanced_tile_set"></a>

### <code><a href="AdvancedTileSet.md">AdvancedTileSet</a> advanced_tile_set</code>

Base `tile_set` property as an [`AdvancedTileSet`](AdvancedTileSet.md) (For ease of static typing and inspector UX)

<a id="property-hide_base_class_features"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> hide_base_class_features = true</code>

If true, hide (in the inspector) any features of the base class that should be ignored as overriden by the plugin (currently only the base `tile_set` property).

## Method Descriptions

<a id="method-advanced_get_neighbor_cell"></a>

### <code>advanced_get_neighbor_cell</code>

<pre><code>func advanced_get_neighbor_cell(
    coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    neighbor: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>:</code></pre>

Get neighbor cell. Intended as a replacement for `get_neighbor_cell()`, but using [`TileGeometry`](TileGeometry.md) enums to identify cell neighbor, and with support for triangle cells.

<a id="method-advanced_local_to_map"></a>

### <code>advanced_local_to_map</code>

<pre><code>func advanced_local_to_map(local: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2.html">Vector2</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>:</code></pre>

Get map co-ordinates under point. Intended as a replacement for `local_to_map()`, but with support for triangle cells.

<a id="method-advanced_autotile_paint_cells"></a>

### <code>advanced_autotile_paint_cells</code>

<pre><code>func advanced_autotile_paint_cells(
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>],
    preserve_surrounding_connections: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = true,
    dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Paint the specified cells with the given Advanced Autotile terrain, and updates the surrounding cells.

Optionally try to preserve surrounding connections with non-painted cells.

Returns a Dictionary of changes, keyed by cell co-ordinates, where values are nested Dictionarties with String keys "old" and "new", values are `class AdvancedTileSet.TileKey` objects. (optionally dry-run to only return dictionary without applying changes).

<a id="method-advanced_autotile_paint_path"></a>

### <code>advanced_autotile_paint_path</code>

<pre><code>func advanced_autotile_paint_path(
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    path: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>],
    dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Paint a path of cells using Advanced Autotile terrain.

Will only try to create new high-priority connections where consecutive cells in the path are adjacent.

Returns a Dictionary of changes, keyed by cell co-ordinates, where values are nested Dictionarties with String keys "old" and "new", values are `class AdvancedTileSet.TileKey` objects. (optionally dry-run to only return dictionary without applying changes).

<a id="method-advanced_autotile_paint_connections"></a>

### <code>advanced_autotile_paint_connections</code>

<pre><code>func advanced_autotile_paint_connections(
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>],
    flags: TileGeometry.CellNeighbor[],
    dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Paint connections using Advanced Autotile terrain, without changing the cells terrain.

Connections are identified by cell-flag pairs, if more cell than flags are given, flags array will wrap. Each connection only needs to be specified from one cell - additional cell-flags are implied.

Returns a Dictionary of changes, keyed by cell co-ordinates, where values are nested Dictionarties with String keys "old" and "new", values are `class AdvancedTileSet.TileKey` objects. (optionally dry-run to only return dictionary without applying changes).

<a id="method-advanced_autotile_flood_fill"></a>

### <code>advanced_autotile_flood_fill</code>

<pre><code>func advanced_autotile_flood_fill(
    start_cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Flood-fills with a given Advanded Autotile terrain, from a given start cell. Returns a Dictionary`Vector2i: Dictionary[String: TileKey`] of cell co-ord, "old" and "new" tiles (optionally dry-run to only return dictionary without applying changes).

<a id="method-add_incoming_terrain"></a>

### <code>add_incoming_terrain</code>

<pre><code>func add_incoming_terrain(
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>]
) -> void:</code></pre>

Add an incoming terrain-to-be-painted in one or more cells, so that autotiling will connect with that terrain and not the existing one.

Lower-level than most autotiling functions, intended for use with [`advanced_autotile_choose_tile()`](#method-advanced_autotile_choose_tile).

Caution: remember to clear incoming terrains after you're done autotiling.

<a id="method-clear_incoming_terrains"></a>

### <code>clear_incoming_terrains</code>

<pre><code>func clear_incoming_terrains() -> void:</code></pre>

Clear incoming terrains (see [`add_incoming_terrain()`](#method-add_incoming_terrain) and [`advanced_autotile_choose_tile()`](#method-advanced_autotile_choose_tile))

<a id="method-advanced_autotile_choose_tile"></a>

### <code>advanced_autotile_choose_tile</code>

<pre><code>func advanced_autotile_choose_tile(
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    prioritize_mask: <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a> = {},
    dry_run: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Choose a tile for the given cell, based on incoming terrains.

Optionally provide a mask (dictionary of flag:terrain_id) to try and match. Returns a dictionary of "old": TileKey, "new": TileKey, or an empty dictionary if no change should occur. Optionally dry-run to only get dictionary result without applying change.

<a id="method-advanced_get_final_cell_terrain"></a>

### <code>advanced_get_final_cell_terrain</code>

<pre><code>func advanced_get_final_cell_terrain(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

Get the incoming terrain for this cell, or the existing terrain if there is no incoming terrain.

<a id="method-advanced_get_existing_cell_mask"></a>

### <code>advanced_get_existing_cell_mask</code>

<pre><code>func advanced_get_existing_cell_mask(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Get the mask of the existing tile in this cell, or an empty dictionary if no tile is present (or a tile with invalid orientation).

<a id="method-get_cells_surrounding_cells"></a>

### <code>get_cells_surrounding_cells</code>

<pre><code>func get_cells_surrounding_cells(
    cells: <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>],
    include_diagonals: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>]:</code></pre>

Get all the cells surrounding (but not included in) the given array of cells.

<a id="method-advanced_get_surrounding_cells"></a>

### <code>advanced_get_surrounding_cells</code>

<pre><code>func advanced_get_surrounding_cells(
    coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    include_diagonals: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> = false
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>]:</code></pre>

Get the cells surrounding the given cell. Similar to `get_surrounding_cells()`, but with support for triangles and diagonals (optionally).

<a id="method-advanced_get_existing_tile"></a>

### <code>advanced_get_existing_tile</code>

<pre><code>func advanced_get_existing_tile(cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>) -> <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>:</code></pre>

Get the TileKey for the tile already in this cell

<a id="method-advanced_get_neighbor_cells_for_flag"></a>

### <code>advanced_get_neighbor_cells_for_flag</code>

<pre><code>func advanced_get_neighbor_cells_for_flag(
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>]:</code></pre>

Get relevant neighbor cells for the given flag + connection mode.

<a id="method-advanced_get_neighbor_flags_for_flag"></a>

### <code>advanced_get_neighbor_flags_for_flag</code>

<pre><code>func advanced_get_neighbor_flags_for_flag(
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> TileGeometry.CellNeighbor[]:</code></pre>

Give a cell, mode, and flag for a mask, get the neighbor flags for relevant cells. 

(There will be one neighbor flag, which will be the same as the mask flag, if the mask flag isn't a corner or the connection mode treats corner flags as diagonals.)

<a id="method-advanced_get_side_flags_for_diagonal"></a>

### <code>advanced_get_side_flags_for_diagonal</code>

<pre><code>func advanced_get_side_flags_for_diagonal(
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    diagonal_flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>
) -> TileGeometry.CellNeighbor[]:</code></pre>

Get the side flags either side of a diagonal flag

<a id="method-advanced_get_cell_orientation"></a>

### <code>advanced_get_cell_orientation</code>

<pre><code>func advanced_get_cell_orientation(coords: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>) -> <a href="TileGeometry.md#enum-Orientation">Orientation</a>:</code></pre>

Get orientation of the specified cell
