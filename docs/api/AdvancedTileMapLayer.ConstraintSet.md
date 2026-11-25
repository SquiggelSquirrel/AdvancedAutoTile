# AdvancedTileMapLayer.ConstraintSet

**Inherits:** [`RefCounted`](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

Intended for internal use by AdvancedTileMapLayer Represents a set of constraints on a grid - each can be an edge between two cells, a corner-intersection, or a diagonal between two cells. Each has one terrain.

## Properties

| Type | Name | Default |
|------|------|---------|
| [`Shape`](TileGeometry.md#enum-Shape) | [`shape`](#property-shape) |  |
| [`Axis`](TileGeometry.md#enum-Axis) | [`axis`](#property-axis) |  |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html)[[`String`](https://docs.godotengine.org/en/stable/classes/class_string.html), [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html)] | [`data`](#property-data) | `{}` |

## Methods

| Returns | Signature |
|---------|-----------|
| `void` | <code><a href="#method-add_constraint">add_constraint</a>(tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>, cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>, terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-has_constraint">has_constraint</a>(tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>, cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-get_constraint">get_constraint</a>(tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>, cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>, flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>, mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>)</code> |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-get_count">get_count</a>()</code> |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | <code><a href="#method-get_cell">get_cell</a>(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`CellNeighbor`](TileGeometry.md#enum-CellNeighbor) | <code><a href="#method-get_flag">get_flag</a>(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`ConnectionMode`](TileGeometry.md#enum-ConnectionMode) | <code><a href="#method-get_mode">get_mode</a>(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-get_is_diagonal">get_is_diagonal</a>(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |

## Constants

<a id="constant-CN"></a>

**<code>CN = {&quot;BOTTOM&quot;: 16, &quot;BOTTOM_CLOCKWISE_CORNER&quot;: 82, &quot;BOTTOM_CORNER&quot;: 18, &quot;BOTTOM_COUNTERCLOCKWISE_CORNER&quot;: 146, &quot;BOTTOM_LEFT_CLOCKWISE_CORNER&quot;: 114, &quot;BOTTOM_LEFT_CORNER&quot;: 50, &quot;BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER&quot;: 178, &quot;BOTTOM_LEFT_SIDE&quot;: 49, &quot;BOTTOM_RIGHT_CLOCKWISE_CORNER&quot;: 90, &quot;BOTTOM_RIGHT_CORNER&quot;: 26, &quot;BOTTOM_RIGHT_COUNTERCLOCKWISE_CORNER&quot;: 154, &quot;BOTTOM_RIGHT_SIDE&quot;: 25, &quot;BOTTOM_SIDE&quot;: 17, &quot;CLOCKWISE&quot;: 64, &quot;CORNER&quot;: 2, &quot;COUNTERCLOCKWISE&quot;: 128, &quot;LEFT&quot;: 32, &quot;LEFT_CLOCKWISE_CORNER&quot;: 98, &quot;LEFT_CORNER&quot;: 34, &quot;LEFT_COUNTERCLOCKWISE_CORNER&quot;: 162, &quot;LEFT_SIDE&quot;: 33, &quot;RIGHT&quot;: 8, &quot;RIGHT_CLOCKWISE_CORNER&quot;: 74, &quot;RIGHT_CORNER&quot;: 10, &quot;RIGHT_COUNTERCLOCKWISE_CORNER&quot;: 138, &quot;RIGHT_SIDE&quot;: 9, &quot;SELF&quot;: 0, &quot;SIDE&quot;: 1, &quot;TOP&quot;: 4, &quot;TOP_CLOCKWISE_CORNER&quot;: 70, &quot;TOP_CORNER&quot;: 6, &quot;TOP_COUNTERCLOCKWISE_CORNER&quot;: 134, &quot;TOP_LEFT_CLOCKWISE_CORNER&quot;: 102, &quot;TOP_LEFT_CORNER&quot;: 38, &quot;TOP_LEFT_COUNTERCLOCKWISE_CORNER&quot;: 166, &quot;TOP_LEFT_SIDE&quot;: 37, &quot;TOP_RIGHT_CLOCKWISE_CORNER&quot;: 78, &quot;TOP_RIGHT_CORNER&quot;: 14, &quot;TOP_RIGHT_COUNTERCLOCKWISE_CORNER&quot;: 142, &quot;TOP_RIGHT_SIDE&quot;: 13, &quot;TOP_SIDE&quot;: 5}</code>**

<a id="enum-FlagType"></a>

### enum `FlagType`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-FlagType-CORNER"></a> `CORNER` | `0` |  |
| <a id="enum-FlagType-SIDE"></a> `SIDE` | `1` |  |
| <a id="enum-FlagType-DIAGONAL_POS"></a> `DIAGONAL_POS` | `2` |  |
| <a id="enum-FlagType-DIAGONAL_NEG"></a> `DIAGONAL_NEG` | `3` |  |

## Property Descriptions

<a id="property-shape"></a>

### <code><a href="TileGeometry.md#enum-Shape">Shape</a> shape</code>

<a id="property-axis"></a>

### <code><a href="TileGeometry.md#enum-Axis">Axis</a> axis</code>

<a id="property-data"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_string.html">String</a>, <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>] data = {}</code>

## Method Descriptions

<a id="method-add_constraint"></a>

### <code>add_constraint</code>

<pre><code>func add_constraint(
    tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>,
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>,
    terrain_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> void:</code></pre>

<a id="method-has_constraint"></a>

### <code>has_constraint</code>

<pre><code>func has_constraint(
    tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>,
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

<a id="method-get_constraint"></a>

### <code>get_constraint</code>

<pre><code>func get_constraint(
    tilemap: <a href="AdvancedTileMapLayer.md">AdvancedTileMapLayer</a>,
    cell: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>,
    flag: <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>,
    mode: <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

<a id="method-get_count"></a>

### <code>get_count</code>

<pre><code>func get_count() -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

<a id="method-get_cell"></a>

### <code>get_cell</code>

<pre><code>func get_cell(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>:</code></pre>

<a id="method-get_flag"></a>

### <code>get_flag</code>

<pre><code>func get_flag(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="TileGeometry.md#enum-CellNeighbor">CellNeighbor</a>:</code></pre>

<a id="method-get_mode"></a>

### <code>get_mode</code>

<pre><code>func get_mode(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="TileGeometry.md#enum-ConnectionMode">ConnectionMode</a>:</code></pre>

<a id="method-get_is_diagonal"></a>

### <code>get_is_diagonal</code>

<pre><code>func get_is_diagonal(index: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>
