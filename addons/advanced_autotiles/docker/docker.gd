@tool
class_name AdvancedAutotilesDockPanel
extends PanelContainer

signal overlay_changed

const TILESET_META_KEY := "_AdvancedAutotile"
enum Mode {SETUP, PAINTING}
var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		%Setup.tile_set = tile_set
		%Painting.tile_set = tile_set


func _ready() -> void:
	%Painting.changed.connect(_on_painting_setup_changed)


func _on_painting_setup_changed() -> void:
	overlay_changed.emit()


func get_editor_show_grid() -> bool:
	return %Painting.is_visible_in_tree() and %Painting.editor_show_grid


func get_mode() -> Mode:
	return get_node("TabContainer").current_tab


func get_paint_action() -> int:
	return %Painting.paint_action


func get_paint_shape() -> int:
	return %Painting.paint_shape


func get_paint_constraint() -> int:
	return %Painting.paint_constraint


func get_paint_terrain() -> int:
	return %Painting.paint_terrain
