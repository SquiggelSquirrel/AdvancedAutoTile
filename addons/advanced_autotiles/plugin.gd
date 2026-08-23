@tool
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/advanced_autotiles/docker/docker.tscn")
var dock: EditorDock
var active_tilemap_layer: TileMapLayer
var active_tileset: AdvancedTileSet


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	var dock_scene := DOCK_SCENE.instantiate()
	dock = EditorDock.new()
	dock.transient = true
	dock.add_child(dock_scene)
	dock.title = "Advanced Autotiles"
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING
	add_dock(dock)
	dock.close()


func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()


func _handles(object: Object) -> bool:
	if object is AdvancedTileSet:
		return true
	if object is TileMapLayer and object.tile_set is AdvancedTileSet:
		return true
	return false


func _edit(object: Object) -> void:
	if object is AdvancedTileSet:
		active_tilemap_layer = null
		active_tileset = object
		dock.open()
		dock.get_node(^"AdvancedAutotilesDocker").tile_set = active_tileset
	elif object is TileMapLayer and object.tile_set is AdvancedTileSet:
		active_tilemap_layer = object
		active_tileset = object.tile_set
		dock.open()
		dock.get_node(^"AdvancedAutotilesDocker").tile_set = active_tileset
	else:
		active_tilemap_layer = null
		active_tileset = null
		dock.close()
		dock.get_node(^"AdvancedAutotilesDocker").tile_set = active_tileset
