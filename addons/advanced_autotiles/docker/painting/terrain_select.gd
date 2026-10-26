@tool
extends ItemList

@export var default_index := 0
@export var tile_set: AdvancedTileSet:
	set(value):
		if tile_set is AdvancedTileSet:
			if tile_set.changed.is_connected(_on_tile_set_update):
				tile_set.changed.disconnect(_on_tile_set_update)
		tile_set = value
		if is_node_ready():
			_on_tile_set_update()
			if tile_set is AdvancedTileSet:
				tile_set.changed.connect(_on_tile_set_update)
var item_terrain_index: PackedInt32Array = []


func _on_tile_set_update() -> void:
	clear()
	if tile_set == null:
		return
	item_terrain_index.resize(tile_set.get_advanced_terrains_count() + 1)
	item_terrain_index[
			add_item("Erase", _create_icon(Color.WHITE))
			] = TileGeometry.FLAG_EMPTY
	for i in tile_set.get_advanced_terrains_count():
		if tile_set.get_advanced_terrain_has_tiles(i):
			item_terrain_index[
					add_item(
							tile_set.get_advanced_terrain_name(i),
							_create_icon(
								tile_set.get_advanced_terrain_color(i)
							)
					)
					] = i
	if item_count >= default_index:
		select(default_index)
		item_selected.emit(default_index)


func _create_icon(color: Color) -> Texture2D:
	var texture := GradientTexture1D.new()
	texture.width = 1
	texture.gradient = Gradient.new()
	texture.gradient.colors = [color]
	texture.gradient.offsets = [0]
	return texture
