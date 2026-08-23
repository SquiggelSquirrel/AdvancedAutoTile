@tool
extends VBoxContainer

signal settings_changed


@export var terrain_select_butons: Array[OptionButton] = []
var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		_setup_terrains_lists()


func _ready() -> void:
	%ToolSelect.item_selected.connect(_on_tool_select_changed.unbind(1))
	for button in terrain_select_butons:
		button.item_selected.connect(_on_settings_changed.unbind(1))


func _on_tool_select_changed() -> void:
	%Terrain.visible = (%ToolSelect.selected == 0)
	%Mask.visible = (%ToolSelect.selected == 1)
	_on_settings_changed()


func _on_settings_changed() -> void:
	settings_changed.emit()


# Set up terrains option button
func _setup_terrains_lists() -> void:
	for button in terrain_select_butons:
		button.tile_set = tile_set


func get_tool_settings() -> Dictionary:
	var settings: Dictionary
	match %ToolSelect.selected:
		0:
			settings = {
				"mode": 0,
				"lmb_terrain": %TerrainSelect.get_selected_terrain_index(),
				"rmb_terrain": -1,
				"shift_lmb_terrain": -1
			}
		1:
			settings = {
				"mode": 1,
				"lmb_terrain": %LMBSelect.get_selected_terrain_index(),
				"rmb_terrain": %RMBSelect.get_selected_terrain_index(),
				"shift_lmb_terrain": %ShiftSelect.get_selected_terrain_index(),
			}
	return settings
