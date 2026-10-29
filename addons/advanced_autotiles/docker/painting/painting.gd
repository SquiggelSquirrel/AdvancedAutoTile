@tool
extends HSplitContainer

signal changed

const PAINT_MODE_INDEX = [
		AdvancedAutoTilePlugin.PaintMode.CELLS,
		AdvancedAutoTilePlugin.PaintMode.PATH,
		AdvancedAutoTilePlugin.PaintMode.CORNERS,
]
const PAINT_SHAPE_INDEX = [
		AdvancedAutoTilePlugin.PaintShape.POINT,
		AdvancedAutoTilePlugin.PaintShape.LINE,
		AdvancedAutoTilePlugin.PaintShape.RECTANGLE,
		AdvancedAutoTilePlugin.PaintShape.FILL,
]
var tile_set: AdvancedTileSet = null:
	set(value):
		if value == tile_set:
			return
		tile_set = value
		if is_node_ready():
			%LMBTerrainSelect.tile_set = tile_set
			%RMBTerrainSelect.tile_set = tile_set
var editor_show_grid := true
var paint_mode := AdvancedAutoTilePlugin.PaintMode.CELLS
var paint_shape := AdvancedAutoTilePlugin.PaintShape.POINT
var paint_terrain := -1
var rmb_terrain := -1


func _ready() -> void:
	%LMBTerrainSelect.tile_set = tile_set
	%RMBTerrainSelect.tile_set = tile_set


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
	paint_mode = PAINT_MODE_INDEX[index]
	var supported_shapes: PackedInt32Array
	match paint_mode:
		AdvancedAutoTilePlugin.PaintMode.CELLS:
			supported_shapes = [
					AdvancedAutoTilePlugin.PaintShape.POINT,
					AdvancedAutoTilePlugin.PaintShape.LINE,
					AdvancedAutoTilePlugin.PaintShape.RECTANGLE,
					AdvancedAutoTilePlugin.PaintShape.FILL,
			]
		AdvancedAutoTilePlugin.PaintMode.PATH:
			supported_shapes = [
					AdvancedAutoTilePlugin.PaintShape.POINT,
					AdvancedAutoTilePlugin.PaintShape.LINE,
			]
		AdvancedAutoTilePlugin.PaintMode.CORNERS:
			supported_shapes = [
					AdvancedAutoTilePlugin.PaintShape.POINT
			]
	for i in 4:
		var button: BaseButton = %PaintShape.get_child(i)
		button.disabled = not (
				PAINT_SHAPE_INDEX[i] in supported_shapes
		)
		if button.disabled and button.button_pressed:
			%PaintShape.get_child(0).button_pressed = true
	changed.emit()


func _on_paint_shape_item_selected(index: int) -> void:
	paint_shape = PAINT_SHAPE_INDEX[index]
	changed.emit()
