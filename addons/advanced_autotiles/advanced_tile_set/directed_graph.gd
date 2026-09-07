class_name DirectedGraph
extends RefCounted

var node_count := 0
var edges: Array[PackedInt32Array] = []
var sccs: Array[PackedInt32Array] = []
var node_sccs: PackedInt32Array = []
var t_sort: PackedInt32Array = []
var _scss_determined := false


func add_node() -> int:
	node_count += 1
	edges.append([])
	return node_count - 1


func add_edge(from_id: int, to_id: int) -> void:
	assert(from_id > -1)
	assert(from_id < node_count)
	assert(to_id > -1)
	assert(to_id < node_count)
	if to_id in edges[from_id]:
		return
	_scss_determined = false
	edges[from_id].append(to_id)
	edges[from_id].sort()


func sort() -> void:
	t_sort.clear()
	if ! _scss_determined:
		determine_sccs()
	var scc_edges_in := _scc_edges_in()
	var scc_is_sorted: Array[bool] = []
	scc_is_sorted.resize(sccs.size())
	scc_is_sorted.fill(false)
	for safety_limit in sccs.size():
		var next_nodes: PackedInt32Array = []
		var sccs_to_sort: PackedInt32Array = []
		for i in sccs.size():
			if scc_is_sorted[i]:
				continue
			if scc_edges_in[i].size() == 0:
				next_nodes.append_array(sccs[i])
				scc_is_sorted[i] = true
				sccs_to_sort.append(i)
		next_nodes.sort()
		t_sort.append_array(next_nodes)
		for i in sccs.size():
			for index in sccs_to_sort:
				scc_edges_in[i].erase(index)


func _scc_edges_in() -> Array[PackedInt32Array]:
	var scc_edges_in: Array[PackedInt32Array] = []
	scc_edges_in.resize(sccs.size())
	for i in scc_edges_in.size():
		scc_edges_in[i] = []
	for start_node in edges.size():
		for end_node in edges[start_node]:
			var start_scc := node_sccs[start_node]
			var end_scc := node_sccs[end_node]
			if start_scc == end_scc:
				continue
			if not start_scc in scc_edges_in[end_scc]:
				scc_edges_in[end_scc].append(start_scc)
	return scc_edges_in


func determine_sccs() -> void:
	var search := SCCSearch.new()
	search.order.resize(node_count)
	search.order.fill(-1)
	sccs.clear()
	node_sccs.resize(node_count)
	node_sccs.fill(-1)
	for node in node_count:
		if search.order[node] > -1:
			continue
		_scc_search_visit(node, search)
	_scss_determined = true


func _scc_search_visit(node: int, search: SCCSearch) -> void:
	search.order[node] = search.count
	search.count += 1
	search.s.append(node)
	search.p.append(node)
	for w in edges[node]:
		if search.order[w] == -1:
			_scc_search_visit(w, search)
		elif node_sccs[w] == -1:
			while search.order[search.p[-1]] > search.order[w]:
				search.p.pop_back()
	if search.p[-1] == node:
		var nodes_in_component: PackedInt32Array = []
		while true:
			var popped := search.s.pop_back()
			nodes_in_component.append(popped)
			if popped == node:
				break
		nodes_in_component.sort()
		var scc_index := sccs.size()
		sccs.append(nodes_in_component)
		for n in nodes_in_component:
			node_sccs[n] = scc_index
		search.p.pop_back()


class SCCSearch:
	var count: int = 0
	var s: Array[int] = []
	var p: Array[int] = []
	var order: PackedInt32Array = []
