# AdvancedTileMapLayer.TilePriority

**Inherits:** [`RefCounted`](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

(Intended only for internal use by [`AdvancedTileMapLayer`](AdvancedTileMapLayer.md))

Represents a tile-match priority.

## Properties

| Type | Name | Default |
|------|------|---------|
| [`bool`](https://docs.godotengine.org/en/stable/classes/class_bool.html) | [`matching_tile`](#property-matching_tile) | `true` |
| [`Dictionary`](https://docs.godotengine.org/en/stable/classes/class_dictionary.html) | [`priorities`](#property-priorities) | `{}` |

## Methods

| Returns | Signature |
|---------|-----------|
| `void` | <code><a href="#method-add_priorty">add_priorty</a>(priority: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| [`Comparison`](#enum-Comparison) | <code><a href="#method-compare">compare</a>(other: AdvancedTileMapLayer.TilePriority)</code> |

## Constants

<a id="enum-Comparison"></a>

### enum `Comparison`

| Name | Value | Description |
|------|-------|-------------|
| <a id="enum-Comparison-OTHER_IS_LESSER"></a> `OTHER_IS_LESSER` | `0` |  |
| <a id="enum-Comparison-EQUAL"></a> `EQUAL` | `1` |  |
| <a id="enum-Comparison-OTHER_IS_GREATER"></a> `OTHER_IS_GREATER` | `2` |  |

## Property Descriptions

<a id="property-matching_tile"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_bool.html">bool</a> matching_tile = true</code>

<a id="property-priorities"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_dictionary.html">Dictionary</a> priorities = {}</code>

## Method Descriptions

<a id="method-add_priorty"></a>

### <code>add_priorty</code>

<pre><code>func add_priorty(priority: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>) -> void:</code></pre>

Add one flag-match priority

<a id="method-compare"></a>

### <code>compare</code>

<pre><code>func compare(other: AdvancedTileMapLayer.TilePriority) -> <a href="#enum-Comparison">Comparison</a>:</code></pre>

Compare with another TilePriority, based on count of flag-matches in descending flag-match priority order.
