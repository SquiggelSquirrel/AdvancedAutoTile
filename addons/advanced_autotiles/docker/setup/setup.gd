@tool
extends HSplitContainer

var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		_setup_sources_list()
		_setup_tool_settings()


func _ready() -> void:
	%SourceList.item_selected.connect(_on_source_list_item_selected)
	%ToolSettings.settings_changed.connect(_on_tool_settings_settings_changed)


func _setup_sources_list() -> void:
	%SourceList.tile_set = tile_set


func _setup_tool_settings() -> void:
	%ToolSettings.tile_set = tile_set


# When an atlas is selected, update the atlas editor
func _on_source_list_item_selected(_item_index: int) -> void:
	var source_id: int = %SourceList.get_selected_source_id()
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	if ! atlas is TileSetAtlasSource:
		%AtlasView.hide()
		return
	%AtlasView.show()
	%AtlasView.tile_set = tile_set
	%AtlasView.source_id = source_id


func _on_tool_settings_settings_changed() -> void:
	%AtlasView.apply_settings(%ToolSettings.get_tool_settings())
