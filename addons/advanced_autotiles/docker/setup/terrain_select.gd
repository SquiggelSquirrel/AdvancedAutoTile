@tool
extends OptionButton


@export var include_empty := false
@export var default_index := 0
var tile_set: AdvancedTileSet = null:
	set(value):
		if value == tile_set:
			return
		if tile_set != null:
			if tile_set.terrains_changed.is_connected(_on_tile_set_terrains_changed):
				tile_set.terrains_changed.disconnect(_on_tile_set_terrains_changed)
		tile_set = value
		if tile_set != null:
			tile_set.terrains_changed.connect(_on_tile_set_terrains_changed)
		_update_terrains()
var item_terrain_indices: PackedInt32Array = []
var anti_recursion_lock := false


func _on_tile_set_terrains_changed() -> void:
	_update_terrains()


func _update_terrains() -> void:
	if anti_recursion_lock == true:
		anti_recursion_lock = false
		assert(false)
	anti_recursion_lock = true
	clear()
	item_terrain_indices.clear()
	if ! tile_set is AdvancedTileSet:
		anti_recursion_lock = false
		return
	if include_empty:
		add_item("Empty")
		item_terrain_indices.append(TileGeometry.FLAG_EMPTY)
	for terrain_index in tile_set.get_advanced_terrains_count():
		add_item(tile_set.get_advanced_terrain_name(terrain_index))
		item_terrain_indices.append(terrain_index)
	if default_index < item_count:
		select(default_index)
		item_selected.emit(default_index)
	else:
		select(0)
		item_selected.emit(0)
	anti_recursion_lock = false


func get_selected_terrain_index() -> int:
	if item_terrain_indices.size() == 0 or selected == -1:
		return -1
	return item_terrain_indices[selected]
