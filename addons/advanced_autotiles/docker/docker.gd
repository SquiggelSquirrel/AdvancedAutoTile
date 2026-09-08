@tool
extends PanelContainer

signal overlay_changed


const TILESET_META_KEY := "_AdvancedAutotile"

var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		%Setup.tile_set = tile_set
		%Painting.tile_set = tile_set


func _ready() -> void:
	%Painting.changed.connect(_on_painting_setup_changed)
	focus_entered.connect(_on_focus_entered)


func _on_painting_setup_changed() -> void:
	overlay_changed.emit()


func get_editor_show_grid() -> bool:
	return %Painting.is_visible_in_tree() and %Painting.editor_show_grid


func _on_focus_entered() -> void:
	print("Focussed")
