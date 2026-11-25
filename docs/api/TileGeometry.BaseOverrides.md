# TileGeometry.BaseOverrides

**Inherits:** [`RefCounted`](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

Static class mapping [`TileGeometry`](TileGeometry.md) enums to Godot built-in enums

## Methods

| Returns | Signature |
|---------|-----------|
| `TileSet.TileShape` | <code><a href="#method-get_tile_shape">get_tile_shape</a>(advanced_shape: <a href="TileGeometry.md#enum-Shape">Shape</a>)</code> |
| `TileSet.TileLayout` | <code><a href="#method-get_tile_layout">get_tile_layout</a>(advanced_layout: <a href="TileGeometry.md#enum-Layout">Layout</a>)</code> |
| `TileSet.TileOffsetAxis` | <code><a href="#method-get_tile_offset_axis">get_tile_offset_axis</a>(advanced_axis: <a href="TileGeometry.md#enum-Axis">Axis</a>)</code> |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | <code><a href="#method-get_tile_size">get_tile_size</a>(advanced_shape: <a href="TileGeometry.md#enum-Shape">Shape</a>, advanced_axis: <a href="TileGeometry.md#enum-Axis">Axis</a>, advanced_size: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>)</code> |

## Method Descriptions

<a id="method-get_tile_shape"></a>

### <code>get_tile_shape</code>

<pre><code>func get_tile_shape(advanced_shape: <a href="TileGeometry.md#enum-Shape">Shape</a>) -> TileSet.TileShape:</code></pre>

Return the `TileSet.TileShape` corresponding the given to `TileGeometry.TileShape` (Triangle maps to Square because triangle are implemented using squares).

<a id="method-get_tile_layout"></a>

### <code>get_tile_layout</code>

<pre><code>func get_tile_layout(advanced_layout: <a href="TileGeometry.md#enum-Layout">Layout</a>) -> TileSet.TileLayout:</code></pre>

Return the `TileSet.TileLayout` corresponding to the given [`Layout`](TileGeometry.md#enum-Layout)

<a id="method-get_tile_offset_axis"></a>

### <code>get_tile_offset_axis</code>

<pre><code>func get_tile_offset_axis(advanced_axis: <a href="TileGeometry.md#enum-Axis">Axis</a>) -> TileSet.TileOffsetAxis:</code></pre>

Return the given `TileSet.TileOffsetAxis` corresponding to the given [`Axis`](TileGeometry.md#enum-Axis)

<a id="method-get_tile_size"></a>

### <code>get_tile_size</code>

<pre><code>func get_tile_size(
    advanced_shape: <a href="TileGeometry.md#enum-Shape">Shape</a>,
    advanced_axis: <a href="TileGeometry.md#enum-Axis">Axis</a>,
    advanced_size: <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>
) -> <a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a>:</code></pre>

Get the base tile size corresponding to the Advanced Autotile tile size (since triangles are implemented using smaller squares)
