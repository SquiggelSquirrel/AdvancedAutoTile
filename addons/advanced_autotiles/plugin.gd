@tool
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/advanced_autotiles/docker/docker.tscn")
var dock: EditorDock
var active_tilemap_layer: TileMapLayer
var active_tileset: AdvancedTileSet
var cell_selection: Array[Vector2i] = []


func _enter_tree() -> void:
	var dock_scene := DOCK_SCENE.instantiate()
	dock = EditorDock.new()
	dock.transient = true
	dock.add_child(dock_scene)
	dock.title = "Advanced Autotiles"
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING
	add_dock(dock)
	dock_scene.overlay_changed.connect(_on_dock_scene_overlay_changed)


func _on_dock_scene_overlay_changed() -> void:
	update_overlays()


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


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not (
			active_tilemap_layer is TileMapLayer
			and active_tileset is AdvancedTileSet
	):
		return
	if ! dock.get_node(^"AdvancedAutotilesDocker").get_editor_show_grid():
		return
	var area := active_tilemap_layer.get_used_rect()
	var transform := active_tilemap_layer.get_viewport_transform()
	var settings := EditorInterface.get_editor_settings()
	var color: Color = settings["editors/tiles_editor/grid_color"]
	area = area.grow(5)
	
	for xi in range(area.position.x, area.end.x):
		for yi in range(area.position.y, area.end.y):
			color.a = clampf(
					minf(
						minf(xi - area.position.x + 1, area.end.x - xi),
						minf(yi - area.position.y + 1, area.end.y - yi)
					) * 0.075,
					0.0,
					1.0
			)
			var coords := Vector2i(xi, yi)
			var cell_transform := Transform2D(
					0.0,
					active_tileset.advanced_tile_size,
					0.0,
					active_tilemap_layer.map_to_local(coords)
					- active_tileset.advanced_tile_size * 0.5
			)
			var orientation := active_tileset.get_cell_orientation(coords)
			var polyline := TileGeometry.get_tile_polygon(
					active_tileset.advanced_shape,
					active_tileset.advanced_axis,
					orientation
			)
			polyline.append(polyline[0])
			viewport_control.draw_polyline(
					transform * cell_transform * polyline, color
			)
