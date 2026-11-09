# DirectedGraph Class Reference

*File:* `addons/advanced_autotiles/advanced_tile_set/directed_graph.gd`
*Class name:* `DirectedGraph`
*Inherits:* `RefCounted`

## Synopsis

```gdscript
class_name DirectedGraph
extends RefCounted
```

## Brief

A directed graph, with tools to identifiy Strongly Connected Components,
and to run a topological sort.

## Public Member Functions

- `func add_node() -> int`
- `func add_edge(from_id: int, to_id: int) -> void`
- `func sort() -> void`
- `func _scc_edges_in() -> Array[PackedInt32Array]`
- `func determine_sccs() -> void`
- `func _scc_search_visit(node: int, search: SCCSearch) -> void`

## Public Attributes

- `Array[PackedInt32Array] edges`
- `Array[PackedInt32Array] sccs`
- `PackedInt32Array node_sccs`
- `PackedInt32Array t_sort`
- `int count`
- `Array[int] s`
- `Array[int] p`
- `PackedInt32Array order`

## Member Function Documentation

### add_node

```gdscript
func add_node() -> int
```

### add_edge

```gdscript
func add_edge(from_id: int, to_id: int) -> void
```

### sort

```gdscript
func sort() -> void
```

### _scc_edges_in

```gdscript
func _scc_edges_in() -> Array[PackedInt32Array]
```

### determine_sccs

```gdscript
func determine_sccs() -> void
```

### _scc_search_visit

```gdscript
func _scc_search_visit(node: int, search: SCCSearch) -> void
```

## Member Data Documentation

### edges

```gdscript
var edges: Array[PackedInt32Array]
```

### sccs

```gdscript
var sccs: Array[PackedInt32Array]
```

### node_sccs

```gdscript
var node_sccs: PackedInt32Array
```

### t_sort

```gdscript
var t_sort: PackedInt32Array
```

### count

```gdscript
var count: int
```

### s

```gdscript
var s: Array[int]
```

### p

```gdscript
var p: Array[int]
```

### order

```gdscript
var order: PackedInt32Array
```
