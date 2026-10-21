@tool
extends ItemList

@export var tile_set: AdvancedTileSet:
	set(value):
		tile_set = value
		if is_node_ready():
			_on_tile_set_update()
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
		item_terrain_index[
				add_item(
						tile_set.get_advanced_terrain_name(i),
						_create_icon(
							tile_set.get_advanced_terrain_color(i)
						)
				)
				] = i
	select(0)
	item_selected.emit()


func _create_icon(color: Color) -> Texture2D:
	var texture := GradientTexture1D.new()
	texture.width = 1
	texture.gradient = Gradient.new()
	texture.gradient.colors = [color]
	texture.gradient.offsets = [0]
	return texture
