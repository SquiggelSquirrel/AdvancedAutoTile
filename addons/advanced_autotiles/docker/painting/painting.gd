@tool
extends HSplitContainer

signal changed

enum PaintAction {PAINT, ERASE, SELECT}
enum PaintConstraint {CELLS, CORNERS}
enum PaintShape {POINT, LINE, RECTANGLE, FILL}
var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		%TerrainSelect.tile_set = tile_set
var editor_show_grid := true
var paint_action := PaintAction.PAINT
var paint_constraint := PaintConstraint.CELLS
var paint_shape := PaintShape.POINT
var paint_terrain := -1


func _on_action_select_item_selected(index: int) -> void:
	paint_action = index
	changed.emit()


func _on_shape_select_item_selected(index: int) -> void:
	paint_shape = index
	changed.emit()


func _on_show_grid_toggled(toggled_on: bool) -> void:
	editor_show_grid = toggled_on
	changed.emit()


func _on_terrain_select_item_selected(index: int) -> void:
	paint_terrain = index
	changed.emit()


func _on_constraint_select_item_selected(index: int) -> void:
	paint_constraint = index
	changed.emit()
