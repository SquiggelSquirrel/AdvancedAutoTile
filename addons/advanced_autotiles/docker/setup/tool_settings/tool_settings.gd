@tool
extends VBoxContainer

signal settings_changed


@export var terrain_select_butons: Array[OptionButton] = []
var tile_set: AdvancedTileSet = null:
	set(value):
		if value == tile_set:
			return
		if tile_set != null:
			if tile_set.changed.is_connected(_on_tile_set_changed):
				tile_set.changed.disconnect(_on_tile_set_changed)
		tile_set = value
		if tile_set != null:
			tile_set.changed.connect(_on_tile_set_changed)
		_setup_orientations()
		_setup_terrains_lists()
		_on_tool_select_changed()


func _ready() -> void:
	%ToolSelect.item_selected.connect(_on_tool_select_changed.unbind(1))
	%OrientationSelect.item_selected.connect(_on_settings_changed.unbind(1))
	for button in terrain_select_butons:
		button.item_selected.connect(_on_settings_changed.unbind(1))


func _on_tile_set_changed() -> void:
	_setup_orientations()
	_on_tool_select_changed()


func _on_tool_select_changed() -> void:
	var to_show: Control
	match %ToolSelect.get_selected_id():
		0:
			to_show = %Terrain
		1:
			to_show = %Mask
		2:
			to_show = %OrientationSelect
	for control in [%Terrain, %Mask, %OrientationSelect]:
		control.visible = (control == to_show)
	_on_settings_changed()


func _on_settings_changed() -> void:
	settings_changed.emit()


func _setup_terrains_lists() -> void:
	for button in terrain_select_butons:
		button.tile_set = tile_set


func _setup_orientations() -> void:
	if tile_set == null:
		return
	var orientations := TileGeometry.get_orientations(
			tile_set.advanced_shape,
			tile_set.advanced_axis
	)
	%OrientationSelect.clear()
	for orientation in orientations:
		%OrientationSelect.add_item(
				TileGeometry.Orientation.find_key(
					orientation).capitalize(),
				orientation
		)
	%ToolSelect.set_item_disabled(0, orientations.size() < 2)
	if %ToolSelect.is_item_disabled(%ToolSelect.selected):
		%ToolSelect.select(%ToolSelect.selected + 1)


func get_tool_settings() -> Dictionary:
	var settings: Dictionary
	match %ToolSelect.get_selected_id():
		0:
			settings = {
				"mode": 0,
				"lmb_terrain": %TerrainSelect.get_selected_terrain_index(),
				"rmb_terrain": -1,
				"shift_lmb_terrain": -1,
				"orientation": TileGeometry.Orientation.UP
			}
		1:
			settings = {
				"mode": 1,
				"lmb_terrain": %LMBSelect.get_selected_terrain_index(),
				"rmb_terrain": %RMBSelect.get_selected_terrain_index(),
				"shift_lmb_terrain": %ShiftSelect.get_selected_terrain_index(),
				"orientation": TileGeometry.Orientation.UP
			}
		2:
			settings = {
				"mode": 2,
				"lmb_terrain": -1,
				"rmb_terrain": -1,
				"shift_lmb_terrain": -1,
				"orientation": %OrientationSelect.get_selected_id()
			}
	return settings
