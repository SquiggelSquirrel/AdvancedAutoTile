@tool
class_name AdvancedAutoTilePlugin
extends EditorPlugin

const DOCK_SCENE := preload("res://addons/advanced_autotiles/docker/docker.tscn")
enum DockMode {SETUP, PAINTING}
enum PaintMode {CELLS, CORNERS, PATH}
enum PaintShape {POINT, LINE, RECTANGLE, FILL}
enum ActionState {NONE, LMB, RMB}
var dock: EditorDock
var dock_scene :AdvancedAutotilesDockPanel
var active_tilemap_layer: AdvancedTileMapLayer
var active_tileset: AdvancedTileSet
var cell_under_mouse: Vector2i
var flag_under_mouse: TileGeometry.CellNeighbor
var current_action: PaintAction


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
					and dock_scene.get_paint_mode() == PaintMode.CORNERS
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
	if dock_scene.get_paint_mode() == PaintMode.CORNERS:
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
	if current_action is PaintAction:
		if current_action.paint_trigger == PaintAction.PaintTrigger.RMB:
			current_action.revert()
			current_action = null
			return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		return
	
	if current_action == null:
		current_action = PaintAction.new(
				dock_scene.get_paint_mode(),
				dock_scene.get_paint_shape(),
				PaintAction.PaintTrigger.LMB,
				cell_under_mouse,
				flag_under_mouse,
				active_tilemap_layer,
				dock_scene.get_paint_terrain()
		)
	current_action.update()


func _handle_lmb_release() -> void:
	if current_action is PaintAction:
		if current_action.paint_trigger == PaintAction.PaintTrigger.LMB:
			current_action.commit(get_undo_redo())
	current_action = null


func _handle_rmb_press() -> void:
	if current_action is PaintAction:
		if current_action.paint_trigger == PaintAction.PaintTrigger.LMB:
			current_action.revert()
			current_action = null
			return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	
	if current_action == null:
		current_action = PaintAction.new(
				dock_scene.get_paint_mode(),
				dock_scene.get_paint_shape(),
				PaintAction.PaintTrigger.RMB,
				cell_under_mouse,
				flag_under_mouse,
				active_tilemap_layer,
				dock_scene.get_rmb_terrain()
		)
	current_action.update()


func _handle_rmb_release() -> void:
	if current_action is PaintAction:
		if current_action.paint_trigger == PaintAction.PaintTrigger.RMB:
			current_action.commit(get_undo_redo())
	current_action = null


func _handle_motion() -> void:
	if current_action == null:
		return
	current_action.set_current_cell(cell_under_mouse)
	current_action.set_current_flag(flag_under_mouse)
	current_action.update()


func _update_cell_and_flag_under_mouse() -> void:
	var mouse := active_tilemap_layer.get_local_mouse_position()
	var new_cell := active_tilemap_layer.local_to_map(mouse)
	var new_flag :TileGeometry.CellNeighbor
	match dock_scene.get_paint_mode():
		PaintMode.CELLS:
			new_flag = TileGeometry.CellNeighbor.SELF
		PaintMode.CORNERS:
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


class PaintAction:
	enum PaintMode {CELLS, CORNERS, PATH}
	enum PaintShape {POINT, LINE, RECTANGLE, FILL}
	enum PaintTrigger {NONE, LMB, RMB}
	var paint_mode: PaintMode
	var paint_shape: PaintShape
	var paint_trigger: PaintTrigger
	var current_cell: Vector2i
	var previous_cell: Vector2i
	var start_cell: Vector2i
	var changes := {}
	var terrain_id: int
	var current_flag: int
	var tile_map_layer: AdvancedTileMapLayer
	
	
	func _init(
			paint_mode: PaintMode,
			paint_shape: PaintShape,
			paint_trigger: PaintTrigger,
			start_cell: Vector2i,
			flag: int,
			tile_map_layer: AdvancedTileMapLayer,
			terrain_id: int
	) -> void:
		self.paint_mode = paint_mode
		self.paint_shape = paint_shape
		self.paint_trigger = paint_trigger
		self.start_cell = start_cell
		self.previous_cell = start_cell
		self.current_cell = start_cell
		self.current_flag = flag
		self.tile_map_layer = tile_map_layer
		self.terrain_id = terrain_id
	
	
	func set_current_cell(cell: Vector2i) -> void:
		previous_cell = current_cell
		current_cell = cell
	
	
	func set_current_flag(flag: int) -> void:
		current_flag = flag
	
	
	func add_changes(new_changes: Dictionary) -> void:
		for cell in new_changes:
			if changes.has(cell):
				changes[cell]["new"] = new_changes[cell]["new"]
			else:
				changes[cell] = new_changes[cell]
	
	
	func update() -> void:
		match paint_shape:
			PaintShape.POINT:
				match paint_mode:
					PaintMode.CELLS:
						add_changes(
								tile_map_layer.advanced_autotile_paint_cells(
									terrain_id,
									[current_cell]
								)
						)
					PaintMode.CORNERS:
						add_changes(
								tile_map_layer.advanced_autotile_paint_corners(
									terrain_id,
									[current_cell],
									[current_flag]
								)
						)
					PaintMode.PATH:
						add_changes(
								tile_map_layer.advanced_autotile_paint_path(
									terrain_id,
									[previous_cell, current_cell]
								)
						)
			PaintShape.LINE:
				revert()
				match paint_mode:
					PaintMode.CELLS:
						changes = tile_map_layer.advanced_autotile_paint_cells(
								terrain_id,
								Geometry2D.bresenham_line(start_cell, current_cell)
						)
					PaintMode.PATH:
						changes = tile_map_layer.advanced_autotile_paint_path(
								terrain_id,
								Geometry2D.bresenham_line(start_cell, current_cell)
						)
			PaintShape.RECTANGLE:
				revert()
				var cells := get_rect_cells(start_cell, current_cell)
				changes = tile_map_layer.advanced_autotile_paint_cells(
						terrain_id,
						cells
				)
			PaintShape.FILL:
				changes = tile_map_layer.advanced_autotile_flood_fill(
						current_cell, terrain_id
				)
	
	
	func commit(undo_redo: EditorUndoRedoManager) -> void:
		if changes.is_empty():
			return
		var terrain_name: String
		if terrain_id == -1:
			terrain_name = "Erase"
		else:
			terrain_name = tile_map_layer.advanced_tile_set.get_advanced_terrain_name(
					terrain_id
			)
		undo_redo.create_action(_commit_name(terrain_name))
		for cell in changes.keys():
			var old: AdvancedTileSet.TileKey = changes[cell]["old"]
			var new: AdvancedTileSet.TileKey = changes[cell]["new"]
			undo_redo.add_do_method(
					tile_map_layer,
					"set_cell",
					cell,
					new.source_id,
					new.coords,
					new.alternative_id
			)
			undo_redo.add_undo_method(
					tile_map_layer,
					"set_cell",
					cell,
					old.source_id,
					old.coords,
					old.alternative_id
			)
		undo_redo.commit_action(false)
	
	
	func revert() -> void:
		for cell in changes.keys():
			var old: AdvancedTileSet.TileKey = changes[cell]["old"]
			tile_map_layer.set_cell(
					cell,
					old.source_id,
					old.coords,
					old.alternative_id
			)
	
	
	func _commit_name(terrain_name: String) -> String:
		var verb: String
		if terrain_name == "Erase":
			verb = "Erase"
		else:
			verb = "Paint %s to" % terrain_name
		var noun: String
		match paint_mode:
			PaintMode.CORNERS:
				noun = "corners"
			PaintMode.PATH:
				match paint_shape:
					PaintShape.LINE:
						noun = "path line"
					_:
						noun = "path"
			_:
				match paint_shape:
					PaintShape.LINE:
						noun = "line"
					PaintShape.RECTANGLE:
						noun = "rectangle"
					PaintShape.FILL:
						noun = "fill region"
					_:
						noun = "cells"
		return "%s %s" % [verb, noun]
	
	
	static func get_rect_cells(
			start_cell: Vector2i,
			current_cell: Vector2i
	) -> Array[Vector2i]:
		var cells: Array[Vector2i] = []
		var rect := Rect2i(start_cell, Vector2i.ZERO)
		rect = rect.expand(current_cell)
		for x in range(rect.position.x, rect.end.x + 1):
			for y in range(rect.position.y, rect.end.y + 1):
				cells.append(Vector2i(x, y))
		return cells
