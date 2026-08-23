@tool
extends OptionButton

@export var include_empty := false
@export var include_ignore := false
var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		_update_terrains()
var item_terrain_indices: PackedInt32Array = []


func _update_terrains() -> void:
	clear()
	item_terrain_indices.clear()
	if ! tile_set is AdvancedTileSet:
		return
	if include_empty:
		add_item("Empty")
		item_terrain_indices.append(-1)
	if include_ignore:
		add_item("Ignore")
		item_terrain_indices.append(-2)
	for terrain_index in tile_set.terrains.size():
		var terrain: AdvancedTileSet.Terrain = tile_set.terrains[terrain_index]
		add_item(terrain.name)
		item_terrain_indices.append(terrain_index)
	select(0)


func get_selected_terrain_index() -> int:
	if item_terrain_indices.size() == 0 or selected == -1:
		return -1
	return item_terrain_indices[selected]
