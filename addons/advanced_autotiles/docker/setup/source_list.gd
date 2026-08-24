@tool
class_name SourcesList
extends ItemList


var tile_set: AdvancedTileSet = null:
	set(value):
		if tile_set != null:
			if tile_set.changed.is_connected(_on_tile_set_changed):
				tile_set.changed.disconnect(_on_tile_set_changed)
		tile_set = value
		if tile_set != null:
			tile_set.changed.connect(_on_tile_set_changed)
		if ! is_node_ready():
			await ready
		_update_sources()
var source_indices: PackedInt32Array = []


func _on_tile_set_changed() -> void:
	_update_sources()


func _update_sources() -> void:
	clear()
	source_indices.clear()
	if ! tile_set is AdvancedTileSet:
		return
	var sources: Array[TileSetAtlasSource] = []
	for i in tile_set.get_source_count():
		var source: TileSetSource = tile_set.get_source(i)
		if ! source is TileSetAtlasSource:
			continue
		source_indices.append(i)
		add_item(source.texture.get_path().get_file(), source.texture)
	if ! source_indices.is_empty():
		select(0)
		item_selected.emit(0)


func get_selected_source_id() -> int:
	if source_indices.size() == 0 or ! is_anything_selected():
		return -1
	return source_indices[get_selected_items()[0]]
