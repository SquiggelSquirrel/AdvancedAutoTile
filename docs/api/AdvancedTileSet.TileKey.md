# AdvancedTileSet.TileKey

**Inherits:** [`RefCounted`](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

Class TileKey contains all fields needed to identify a Tile in a TileSet

## Properties

| Type | Name | Default |
|------|------|---------|
| **AdvancedTileSet.TileKey** | [`EMPTY`](#property-EMPTY) | `<unknown>` |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | [`source_id`](#property-source_id) |  |
| [`Vector2i`](https://docs.godotengine.org/en/stable/classes/class_vector2i.html) | [`coords`](#property-coords) |  |
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | [`alternative_id`](#property-alternative_id) |  |

## Methods

| Returns | Signature |
|---------|-----------|
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | <code><a href="#method-equals">equals</a>(other_tile: AdvancedTileSet.TileKey)</code> |

## Property Descriptions

<a id="property-EMPTY"></a>

### <code>AdvancedTileSet.TileKey EMPTY = &lt;unknown&gt;</code>

<a id="property-source_id"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a> source_id</code>

<a id="property-coords"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_vector2i.html">Vector2i</a> coords</code>

<a id="property-alternative_id"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a> alternative_id</code>

## Method Descriptions

<a id="method-equals"></a>

### <code>equals</code>

<pre><code>func equals(other_tile: AdvancedTileSet.TileKey) -> <a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a>:</code></pre>

Test if this key identifies the same tile as another key
