@tool
extends HSplitContainer

signal changed

enum PaintMode {CELLS, CORNERS, PATH}
enum PaintShape {POINT, LINE, RECTANGLE, FILL}
var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		%LMBTerrainSelect.tile_set = tile_set
		%RMBTerrainSelect.tile_set = tile_set
var editor_show_grid := true
var paint_mode := PaintMode.CELLS
var paint_shape := PaintShape.POINT
var paint_terrain := -1
var rmb_terrain := -1


func _on_show_grid_toggled(toggled_on: bool) -> void:
	editor_show_grid = toggled_on
	changed.emit()


func _on_lmb_terrain_select_item_selected(index: int) -> void:
	paint_terrain = %LMBTerrainSelect.item_terrain_index[index]
	changed.emit()


func _on_rmb_terrain_select_item_selected(index: int) -> void:
	rmb_terrain = %LMBTerrainSelect.item_terrain_index[index]
	changed.emit()


func _on_paint_mode_item_selected(index: int) -> void:
	paint_mode = index
	changed.emit()


func _on_paint_shape_item_selected(index: int) -> void:
	paint_shape = index
	changed.emit()
