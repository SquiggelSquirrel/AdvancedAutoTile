@tool
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/advanced_autotiles/docker/docker.tscn")
enum DockMode {SETUP, PAINTING}
enum PaintAction {PAINT, ERASE, SELECT}
enum PaintConstraint {CELLS, CORNERS}
enum PaintShape {POINT, LINE, RECTANGLE, FILL}
enum ActionState {NONE, LMB, RMB}
var dock: EditorDock
var dock_scene :AdvancedAutotilesDockPanel
var active_tilemap_layer: AdvancedTileMapLayer
var active_tileset: AdvancedTileSet
var cell_under_mouse: Vector2i
var flag_under_mouse: TileGeometry.CellNeighbor
var cell_selection: Dictionary[Vector2i, bool] = {}
var _current_action := ActionState.NONE
var _action_start_cell: Vector2i


func _enter_tree() -> void:
	dock_scene = DOCK_SCENE.instantiate()
	dock = EditorDock.new()
	dock.transient = true
	dock.add_child(dock_scene)
	dock.title = "Advanced Autotiles"
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.available_layouts = (
			EditorDock.DOCK_LAYOUT_HORIZONTAL
			| EditorDock.DOCK_LAYOUT_FLOATING
	)
	add_dock(dock)
	dock_scene.overlay_changed.connect(_on_dock_scene_overlay_changed)
	dock.close()


func _exit_tree() -> void:
	active_tileset = null
	active_tilemap_layer = null
	remove_dock(dock)
	dock.queue_free()


func _handles(object: Object) -> bool:
	if object is AdvancedTileSet:
		return true
	if object is AdvancedTileMapLayer and object.tile_set is AdvancedTileSet:
		return true
	return false


func _edit(object: Object) -> void:
	if object is AdvancedTileSet:
		active_tileset = object
		dock.open()
		dock_scene.tile_set = active_tileset
	elif object is AdvancedTileMapLayer and object.tile_set is AdvancedTileSet:
		active_tilemap_layer = object
		active_tileset = object.tile_set
		dock.open()
		dock_scene.tile_set = active_tileset
	else:
		active_tilemap_layer = null
		active_tileset = null
		dock.close()
		dock_scene.tile_set = active_tileset


func _clear() -> void:
	active_tilemap_layer = null
	active_tileset = null
	dock.close()


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if not (
			active_tilemap_layer is AdvancedTileMapLayer
			and active_tileset is AdvancedTileSet
	):
		return
	if ! dock_scene.get_editor_show_grid():
		return
	var area := active_tilemap_layer.get_used_rect().grow(5)
	var transform := active_tilemap_layer.get_viewport_transform()
	var settings := EditorInterface.get_editor_settings()
	var color: Color = settings["editors/tiles_editor/grid_color"]
	
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
			var orientation := active_tileset.get_advanced_cell_orientation(coords)
			var polyline := TileGeometry.get_tile_polygon(
					active_tileset.advanced_shape,
					active_tileset.advanced_axis,
					orientation
			)
			polyline.append(polyline[0])
			viewport_control.draw_polyline(
					transform * cell_transform * polyline,
					color
			)
			if (
					coords == cell_under_mouse
					and dock_scene.get_paint_constraint() == PaintConstraint.CORNERS
			):
				var flag_polygons := TileGeometry.get_flag_polygons(
						active_tileset.advanced_shape,
						active_tileset.advanced_axis,
						TileGeometry.ConnectionMode.CORNERS,
						orientation
				)
				if flag_under_mouse in flag_polygons.keys():
					viewport_control.draw_polyline(
						transform
						* cell_transform 
						* PackedVector2Array(flag_polygons[flag_under_mouse]),
						Color.WHITE
					)
	
	var coord_text_position := Vector2(24, viewport_control.size.y - 24)
	var coord_text := "(%s, %s)" % [cell_under_mouse.x, cell_under_mouse.y]
	if dock_scene.get_paint_constraint() == PaintConstraint.CORNERS:
		coord_text += " " + TileGeometry.CellNeighbor.find_key(flag_under_mouse)
	viewport_control.draw_string(
			ThemeDB.fallback_font,
			coord_text_position,# Vector2(0, viewport_control.size.y),
			coord_text,
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1,
			ThemeDB.fallback_font_size,
			Color.WHITE
	)
	viewport_control.draw_string_outline(
			ThemeDB.fallback_font,
			coord_text_position,
			coord_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			ThemeDB.fallback_font_size,
			1,
			Color.BLACK
	)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if ! dock_scene.is_visible_in_tree():
		return false
	if ! event is InputEventMouse:
		return false
	if active_tilemap_layer == null or active_tileset == null:
		return false
	if dock_scene.get_mode() != DockMode.PAINTING:
		return false
	_update_cell_and_flag_under_mouse()
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					_handle_lmb_press()
				MOUSE_BUTTON_RIGHT:
					_handle_rmb_press()
		else:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					_handle_lmb_release()
				MOUSE_BUTTON_RIGHT:
					_handle_rmb_release()
	elif event is InputEventMouseMotion:
		_handle_motion()
	return true


func _handle_lmb_press() -> void:
	if _current_action == ActionState.RMB:
		_current_action = ActionState.NONE
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return
	if (
			dock_scene.get_paint_shape() != PaintShape.FILL
			and _current_action == ActionState.NONE
	):
		_current_action = ActionState.LMB
		_action_start_cell = cell_under_mouse
	_perform_current_lmb_action([cell_under_mouse])


func _handle_lmb_release() -> void:
	_current_action = ActionState.NONE


func _handle_rmb_press() -> void:
	if _current_action == ActionState.LMB:
		_current_action = ActionState.NONE
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	if (
			dock_scene.get_paint_shape() != PaintShape.FILL
			and _current_action == ActionState.NONE
	):
		_current_action = ActionState.RMB
		_action_start_cell = cell_under_mouse
	_perform_current_rmb_action([cell_under_mouse])


func _handle_rmb_release() -> void:
	_current_action = ActionState.NONE


func _handle_motion() -> void:
	var action_cells: Array[Vector2i]
	match dock_scene.get_paint_shape():
		PaintShape.POINT:
			action_cells = [cell_under_mouse]
	match _current_action:
		ActionState.NONE:
			return
		ActionState.LMB:
			_perform_current_lmb_action(action_cells)
		ActionState.RMB:
			_perform_current_rmb_action(action_cells)


func _perform_current_lmb_action(cells: Array[Vector2i]) -> void:
	match dock_scene.get_paint_action():
		PaintAction.PAINT:
			match dock_scene.get_paint_constraint():
				PaintConstraint.CELLS:
					active_tilemap_layer.advanced_autotile_paint_cells(
							dock_scene.get_paint_terrain(),
							cells
					)
				PaintConstraint.CORNERS:
					active_tilemap_layer.advanced_autotile_paint_corners(
							dock_scene.get_paint_terrain(),
							cells,
							[flag_under_mouse]
					)
		PaintAction.ERASE:
			active_tilemap_layer.advanced_autotile_paint_cells(
					TileGeometry.FLAG_EMPTY,
					cells
			)
		PaintAction.SELECT:
			for cell in cells:
				cell_selection[cell] = true


func _perform_current_rmb_action(cells: Array[Vector2i]) -> void:
	match dock_scene.get_paint_action():
		PaintAction.PAINT, PaintAction.ERASE:
			active_tilemap_layer.advanced_autotile_paint_cells(
					TileGeometry.FLAG_EMPTY,
					cells
			)
		PaintAction.SELECT:
			for cell in cells:
				cell_selection.erase(cell)


func _update_cell_and_flag_under_mouse() -> void:
	var mouse := active_tilemap_layer.get_local_mouse_position()
	var new_cell := active_tilemap_layer.local_to_map(mouse)
	var new_flag :TileGeometry.CellNeighbor
	match dock_scene.get_paint_constraint():
		PaintConstraint.CELLS:
			new_flag = TileGeometry.CellNeighbor.SELF
		PaintConstraint.CORNERS:
			var point_in_cell := (
					(
						active_tileset.advanced_tile_size * 0.5
						+ mouse
						- active_tilemap_layer.map_to_local(new_cell)
					)
					/ Vector2(active_tileset.advanced_tile_size)
			)
			var corner_points := TileGeometry.get_tile_outline_points(
					active_tileset.advanced_shape,
					active_tileset.advanced_axis,
					active_tileset.get_advanced_cell_orientation(new_cell)
			)
			var min_distance_squared = 1.0
			for flag in corner_points.keys():
				var distance_squared := corner_points[
						flag
						].distance_squared_to(point_in_cell)
				if distance_squared < min_distance_squared:
					min_distance_squared = distance_squared
					new_flag = flag
	if new_cell != cell_under_mouse or new_flag != flag_under_mouse:
		cell_under_mouse = new_cell
		flag_under_mouse = new_flag
		update_overlays()


func _on_dock_scene_overlay_changed() -> void:
	update_overlays()
