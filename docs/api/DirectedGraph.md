# DirectedGraph

**Inherits:** [`RefCounted`](https://docs.godotengine.org/en/stable/classes/class_refcounted.html)

A directed graph, with tools to identifiy Strongly Connected Components, and to run a topological sort.

## Properties

| Type | Name | Default |
|------|------|---------|
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | [`node_count`](#property-node_count) | `0` |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`PackedInt32Array`](https://docs.godotengine.org/en/stable/classes/class_packedint32array.html)] | [`edges`](#property-edges) | `[]` |
| [`Array`](https://docs.godotengine.org/en/stable/classes/class_array.html)[[`PackedInt32Array`](https://docs.godotengine.org/en/stable/classes/class_packedint32array.html)] | [`sccs`](#property-sccs) | `[]` |
| [`PackedInt32Array`](https://docs.godotengine.org/en/stable/classes/class_packedint32array.html) | [`node_sccs`](#property-node_sccs) | `[]` |
| [`PackedInt32Array`](https://docs.godotengine.org/en/stable/classes/class_packedint32array.html) | [`t_sort`](#property-t_sort) | `[]` |

## Methods

| Returns | Signature |
|---------|-----------|
| [`int`](https://docs.godotengine.org/en/stable/classes/class_int.html) | <code><a href="#method-add_node">add_node</a>()</code> |
| `void` | <code><a href="#method-add_edge">add_edge</a>(from_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>, to_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>)</code> |
| `void` | <code><a href="#method-sort">sort</a>()</code> |
| `void` | <code><a href="#method-determine_sccs">determine_sccs</a>()</code> |

## Property Descriptions

<a id="property-node_count"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a> node_count = 0</code>

<a id="property-edges"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_packedint32array.html">PackedInt32Array</a>] edges = []</code>

<a id="property-sccs"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_array.html">Array</a>[<a href="https://docs.godotengine.org/en/stable/classes/class_packedint32array.html">PackedInt32Array</a>] sccs = []</code>

<a id="property-node_sccs"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_packedint32array.html">PackedInt32Array</a> node_sccs = []</code>

<a id="property-t_sort"></a>

### <code><a href="https://docs.godotengine.org/en/stable/classes/class_packedint32array.html">PackedInt32Array</a> t_sort = []</code>

## Method Descriptions

<a id="method-add_node"></a>

### <code>add_node</code>

<pre><code>func add_node() -> <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>:</code></pre>

<a id="method-add_edge"></a>

### <code>add_edge</code>

<pre><code>func add_edge(
    from_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>,
    to_id: <a href="https://docs.godotengine.org/en/stable/classes/class_int.html">int</a>
) -> void:</code></pre>

<a id="method-sort"></a>

### <code>sort</code>

<pre><code>func sort() -> void:</code></pre>

<a id="method-determine_sccs"></a>

### <code>determine_sccs</code>

<pre><code>func determine_sccs() -> void:</code></pre>
