extends Control

var nodes := ["Trees", "Flower Bushes", "Bushes", "Deep Water", "Flowers", "Water", "Grass", "Dirt"]
var edges := {
	"Dirt": ["Grass", "Water"],
	"Grass": ["Flowers", "Bushes", "Flower Bushes"],
	"Water": ["Deep Water"],
	"Flowers": ["Grass", "Bushes", "Flower Bushes"],
	"Bushes": ["Flower Bushes", "Trees"],
	"Flower Bushes": ["Bushes", "Trees"]
}


func _run_test() -> void:
	var graph = DirectedGraph.new()
	for node_name in nodes:
		graph.add_node()
	for node_name in edges.keys():
		var start_index := nodes.find(node_name)
		for target_name in edges[node_name]:
			var end_index := nodes.find(target_name)
			graph.add_edge(start_index, end_index)
	graph.determine_sccs()
	print(graph.sccs)
	print(graph.node_sccs)
	print(graph._scc_edges_in())
	graph.sort()
	print(graph.t_sort)


func _on_button_pressed() -> void:
	_run_test()
