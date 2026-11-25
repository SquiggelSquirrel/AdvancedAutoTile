# AdvancedTileSet

**Inherits:** [`TileSet`](https://docs.godotengine.org/en/stable/classes/class_tileset.html)

Tile Set for use with Advanced Autotiles plugin

## Description

An extension of Godot's built-in `TileSet` class, intended for use with an [`AdvancedTileMapLayer`](AdvancedTileMapLayer.md) node. Adds support for triangle grid configuration and terrain setup for this plugin.  Plugins cannot extend built-in methods or properties, so this class has a number of replacements, and the built-in class features are hidden in the editor unless [`hide_base_class_features`](#property-hide_base_class_features) is disabled.  Triangle grids are implemented using Godot's square grid with half the width/height for horizontal/vertical stacking, so triangles must have an even width/height (depending on axis).

## Properties

| Type | Name | Default |
|------|------|---------|
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | [`hide_base_class_features`](#property-hide_base_class_features) | `true` |
| [`Shape`](TileGeometry.md#enum-Shape) | [`advanced_shape`](#property-advanced_shape) | `0` |
| [`Layout`](TileGeometry.md#enum-Layout) | [`advanced_layout`](#property-advanced_layout) | `0` |
| [`Axis`](TileGeometry.md#enum-Axis) | [`advanced_axis`](#property-advanced_axis) | `0` |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | [`advanced_tile_size`](#property-advanced_tile_size) | `Vector2i(16, 16)` |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | [`auto_priorities`](#property-auto_priorities) | `true` |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | [`empty_terrain_auto_bindings`](#property-empty_terrain_auto_bindings) | `true` |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | [`empty_terrain_bindings`](#property-empty_terrain_bindings) | `0` |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | [`empty_terrain_priority`](#property-empty_terrain_priority) | `0` |

## Methods

| Returns | Signature |
|---------|-----------|
| `void` | <code><a href="#method-advanced_set_tile_orientation">advanced_set_tile_orientation</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>, orientation: <a href="TileGeometry.md#enum-Orientation">Orientation</a>)</code> |
| [`Orientation`](TileGeometry.md#enum-Orientation) | <code><a href="#method-advanced_get_tile_orientation">advanced_get_tile_orientation</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>)</code> |
| `void` | <code><a href="#method-advanced_set_tile_terrain">advanced_set_tile_terrain</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>, terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-advanced_get_tile_terrain">advanced_get_tile_terrain</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>)</code> |
| `void` | <code><a href="#method-advanced_set_tile_mask_flag">advanced_set_tile_mask_flag</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, flag_value: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_clear_tile_mask">advanced_clear_tile_mask</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-advanced_get_tile_mask">advanced_get_tile_mask</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>)</code> |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`AdvancedTileSet.TileKey`](AdvancedTileSet.TileKey.md)] | <code><a href="#method-advanced_get_tiles">advanced_get_tiles</a>()</code> |
| [`TileData`](https://docs.godotengine.org/en/stable/classes/class_tiledata.html) | <code><a href="#method-get_tile_data">get_tile_data</a>(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-advanced_get_terrains_count">advanced_get_terrains_count</a>()</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-advanced_add_terrain">advanced_add_terrain</a>(terrain_name: <a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>, terrain_mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| [`String`](https://docs.godotengine.org/en/stable/classes/class_string.html) | <code><a href="#method-advanced_get_terrain_name">advanced_get_terrain_name</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_terrain_name">advanced_set_terrain_name</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, name: <a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>)</code> |
| [`Color`](https://docs.godotengine.org/en/stable/classes/class_color.html) | <code><a href="#method-advanced_get_tile_terrain_color">advanced_get_tile_terrain_color</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_tile_terrain_color">advanced_set_tile_terrain_color</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, color: <a href="https://docs.godotengine.org/en/stable/classes/class_color.html">Color</a>)</code> |
| [`ConnectionMode`](TileGeometry.md#enum-ConnectionMode) | <code><a href="#method-advanced_get_terrain_mode">advanced_get_terrain_mode</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_terrain_mode">advanced_set_terrain_mode</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-advanced_get_terrain_auto_binding">advanced_get_terrain_auto_binding</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_terrain_auto_binding">advanced_set_terrain_auto_binding</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, auto_binding: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-advanced_get_terrain_binds_to">advanced_get_terrain_binds_to</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, other_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_terrain_binds_to">advanced_set_terrain_binds_to</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, other_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, binds: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-advanced_get_terrain_priority">advanced_get_terrain_priority</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-advanced_set_terrain_priority">advanced_set_terrain_priority</a>(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, priority: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-advanced_get_terrain_has_tiles">advanced_get_terrain_has_tiles</a>(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | <code><a href="#method-get_terrain_empty_mask">get_terrain_empty_mask</a>(mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>, orientation: <a href="TileGeometry.md#enum-Orientation">Orientation</a>)</code> |

## Signals

| Signal |
|--------|
| <code><a href="#signal-terrains_changed">terrains_changed</a>()</code> |

## Constants

<a id="constant-DATA_LAYER_NAME"></a>

**<code>DATA_LAYER_NAME = &quot;_advanced_autotiles&quot;</code>**

Key used for storing per-tile plugin data on TileSet custom data layer

## Property Descriptions

<a id="property-hide_base_class_features"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> hide_base_class_features = true</code>

Hide properties of the base `class TileSet` in the editor, if an Advanced Autotiles property is intended to replace. (Does not affect underlying API)

<a id="property-advanced_shape"></a>

### <code><a href="TileGeometry.md#enum-Shape">Shape</a> advanced_shape = 0</code>

The tile shape used by the Advanced Autotiles plugin. Overwrites `tile_shape`

<a id="property-advanced_layout"></a>

### <code><a href="TileGeometry.md#enum-Layout">Layout</a> advanced_layout = 0</code>

The tile layout used by the Advanced Autotiles plugin. Overwrites `tile_layout`

<a id="property-advanced_axis"></a>

### <code><a href="TileGeometry.md#enum-Axis">Axis</a> advanced_axis = 0</code>

For half-offset shapes (isometric, hexagonal, half-offset square), determines the offset axis. For triangles, determines the stacking and allowed orientations.

<a id="property-advanced_tile_size"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a> advanced_tile_size = Vector2i(16, 16)</code>

The size, in pixels, of the minumum rectangle that fully encompasses one cell. Triangles must have even width if horizontal, or height if vertical (due to implementation limitations).

<a id="property-auto_priorities"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> auto_priorities = true</code>

If true, calculate terrain properties automatically from bindings

<a id="property-empty_terrain_auto_bindings"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> empty_terrain_auto_bindings = true</code>

If true, determine bindings for the "empty" terrain automatically.

<a id="property-empty_terrain_bindings"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a> empty_terrain_bindings = 0</code>

Bitmask of bindings for the "empty" terrain.

<a id="property-empty_terrain_priority"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a> empty_terrain_priority = 0</code>

Priority of the "empty" terrain.

## Method Descriptions

<a id="method-advanced_set_tile_orientation"></a>

### <code>advanced_set_tile_orientation</code>

<pre><code>func advanced_set_tile_orientation(
    tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>,
    orientation: <a href="TileGeometry.md#enum-Orientation">Orientation</a>
) -> void:</code></pre>

Set the orientation of a tile (only relevant for triangle tiles)

<a id="method-advanced_get_tile_orientation"></a>

### <code>advanced_get_tile_orientation</code>

<pre><code>func advanced_get_tile_orientation(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>) -> <a href="TileGeometry.md#enum-Orientation">Orientation</a>:</code></pre>

Get the orientation of a tile

<a id="method-advanced_set_tile_terrain"></a>

### <code>advanced_set_tile_terrain</code>

<pre><code>func advanced_set_tile_terrain(
    tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>,
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> void:</code></pre>

Set the terrain index of a tile

<a id="method-advanced_get_tile_terrain"></a>

### <code>advanced_get_tile_terrain</code>

<pre><code>func advanced_get_tile_terrain(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

Get the terrain index of a tile

<a id="method-advanced_set_tile_mask_flag"></a>

### <code>advanced_set_tile_mask_flag</code>

<pre><code>func advanced_set_tile_mask_flag(
    tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    flag_value: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> void:</code></pre>

Set a flag of the "Advanced Autotiles" mask of a tile

<a id="method-advanced_clear_tile_mask"></a>

### <code>advanced_clear_tile_mask</code>

<pre><code>func advanced_clear_tile_mask(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>) -> void:</code></pre>

Clear the "Advanced Autotiles" mask of a tile (set all flags to "empty")

<a id="method-advanced_get_tile_mask"></a>

### <code>advanced_get_tile_mask</code>

<pre><code>func advanced_get_tile_mask(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Get the "Advanced Autotiles" mask of a tile

<a id="method-advanced_get_tiles"></a>

### <code>advanced_get_tiles</code>

<pre><code>func advanced_get_tiles() -> <a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>]:</code></pre>

Returns an array of tile keys objects, for all tiles in all the atlas sources of this tile set.

<a id="method-get_tile_data"></a>

### <code>get_tile_data</code>

<pre><code>func get_tile_data(tile: <a href="AdvancedTileSet.TileKey.md">AdvancedTileSet.TileKey</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_tiledata.html">TileData</a>:</code></pre>

Return the `TileData` of a tile identified by a `TileKey`

<a id="method-advanced_get_terrains_count"></a>

### <code>advanced_get_terrains_count</code>

<pre><code>func advanced_get_terrains_count() -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

Get the number of "Advanced Autotile" terrains defined for this tileset.

<a id="method-advanced_add_terrain"></a>

### <code>advanced_add_terrain</code>

<pre><code>func advanced_add_terrain(
    terrain_name: <a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>,
    terrain_mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

Add a new "Advanced Autotile" terrain. Returns the index of the new terrain.

<a id="method-advanced_get_terrain_name"></a>

### <code>advanced_get_terrain_name</code>

<pre><code>func advanced_get_terrain_name(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>:</code></pre>

Get the name of the "Advanced Autotile" terrain at this index.

<a id="method-advanced_set_terrain_name"></a>

### <code>advanced_set_terrain_name</code>

<pre><code>func advanced_set_terrain_name(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    name: <a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>
) -> void:</code></pre>

Set the name of an "Advanced Autotile" terrain

<a id="method-advanced_get_tile_terrain_color"></a>

### <code>advanced_get_tile_terrain_color</code>

<pre><code>func advanced_get_tile_terrain_color(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_color.html">Color</a>:</code></pre>

Get the color assigned to an "Advanced Autotile" terrain (for use in editor)

<a id="method-advanced_set_tile_terrain_color"></a>

### <code>advanced_set_tile_terrain_color</code>

<pre><code>func advanced_set_tile_terrain_color(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    color: <a href="https://docs.godotengine.org/en/stable/classes/class_color.html">Color</a>
) -> void:</code></pre>

Set the color assigned to an "Advanced Autotile" terrain (for use in editor)

<a id="method-advanced_get_terrain_mode"></a>

### <code>advanced_get_terrain_mode</code>

<pre><code>func advanced_get_terrain_mode(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>:</code></pre>

Get the connection mode of an "Advanced Autotile" terrain

<a id="method-advanced_set_terrain_mode"></a>

### <code>advanced_set_terrain_mode</code>

<pre><code>func advanced_set_terrain_mode(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> void:</code></pre>

Set the connection mode of an "Advanced Autotile" terrain

<a id="method-advanced_get_terrain_auto_binding"></a>

### <code>advanced_get_terrain_auto_binding</code>

<pre><code>func advanced_get_terrain_auto_binding(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

If true, binding will be determined automatically for the specified "Advanced Autotile" terrain

<a id="method-advanced_set_terrain_auto_binding"></a>

### <code>advanced_set_terrain_auto_binding</code>

<pre><code>func advanced_set_terrain_auto_binding(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    auto_binding: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>
) -> void:</code></pre>

Set whether binding should be determined automatically for the specified "Advanced Autotile" terrain.

<a id="method-advanced_get_terrain_binds_to"></a>

### <code>advanced_get_terrain_binds_to</code>

<pre><code>func advanced_get_terrain_binds_to(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    other_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

Test whether a given terrain binds to another terrain (Advanced Autotiles)

<a id="method-advanced_set_terrain_binds_to"></a>

### <code>advanced_set_terrain_binds_to</code>

<pre><code>func advanced_set_terrain_binds_to(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    other_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    binds: <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>
) -> void:</code></pre>

Set whether a given terrain binds to another terrain (Advanced Autotiles)

<a id="method-advanced_get_terrain_priority"></a>

### <code>advanced_get_terrain_priority</code>

<pre><code>func advanced_get_terrain_priority(terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

Get the priority of the specified "Advanced Autotile" terrain

<a id="method-advanced_set_terrain_priority"></a>

### <code>advanced_set_terrain_priority</code>

<pre><code>func advanced_set_terrain_priority(
    terrain_index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    priority: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> void:</code></pre>

Set the priority of the specified "Advanced Autotile" terrain

<a id="method-advanced_get_terrain_has_tiles"></a>

### <code>advanced_get_terrain_has_tiles</code>

<pre><code>func advanced_get_terrain_has_tiles(terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

Test whether the specified "Advanced Autotile" terrain has any tiles assigned to it.

<a id="method-get_terrain_empty_mask"></a>

### <code>get_terrain_empty_mask</code>

<pre><code>func get_terrain_empty_mask(
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>,
    orientation: <a href="TileGeometry.md#enum-Orientation">Orientation</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>:</code></pre>

Get an empty tile mask for the given connection mode and tile orientation

## Signal Descriptions

<a id="signal-terrains_changed"></a>

### <code>terrains_changed()</code>

Emitted when the terrains setup changes. (Other changes use the [`changed`](#signal-changed) signal.
