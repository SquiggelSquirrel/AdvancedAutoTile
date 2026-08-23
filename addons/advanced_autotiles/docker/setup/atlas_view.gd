@tool
extends Control

const CENTER_FLAG_SHRINK := 0.6
enum Mode {
	SETUP_TERRAIN = 0,
	SETUP_MASKS = 1,
}
var drag_start := Vector2.INF
var drag_scroll_start := Vector2.ZERO
var mode: Mode = Mode.SETUP_TERRAIN
var lmb_terrain_index: int = -1
var rmb_terrain_index: int = -1
var shift_lmb_terrain_index: int = -1
var tile_set: AdvancedTileSet:
	set(value):
		if tile_set is AdvancedTileSet:
			if tile_set.changed.is_connected(_on_tile_set_changed):
				tile_set.changed.disconnect(_on_tile_set_changed)
		tile_set = value
		if tile_set is AdvancedTileSet:
			tile_set.changed.connect(_on_tile_set_changed)
		queue_redraw()
var source_index: int = -1:
	set(value):
		source_index = value
		queue_redraw()
var scroll := Vector2.ZERO
var zoom := 1.0
var tile_under_mouse := Vector2i(-1, -1)
var flag_under_mouse := AdvancedTileSet.AdvancedCellNeighbor.SELF

var mouse_position := Vector2.ZERO
var cursor_coords := Vector2i(-1, -1)


func _process(delta: float) -> void:
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				zoom += 0.05
				queue_redraw()
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= 0.05
				queue_redraw()
			MOUSE_BUTTON_MIDDLE when event.pressed:
				drag_start = event.position
				drag_scroll_start = scroll
			MOUSE_BUTTON_MIDDLE:
				drag_start = Vector2.INF
			_:
				var coords := _point_to_coords(event.position)
				if coords != Vector2i(-1, -1):
					_paint_terrain()
	if event is InputEventMouseMotion:
		var new_tile_under_mouse := _point_to_coords(event.position)
		if mode == Mode.SETUP_MASKS:
			pass
		
		mouse_position = event.position
		var new_cursor_coords := _point_to_coords(mouse_position)
		if new_cursor_coords != cursor_coords:
			cursor_coords = new_cursor_coords
			queue_redraw()
		
		if drag_start.is_finite():
			scroll = drag_scroll_start + event.position - drag_start
			queue_redraw()
		elif mode == Mode.SETUP_TERRAIN:
			_paint_terrain()
		elif mode == Mode.SETUP_MASKS:
			_paint_mask()


func _draw() -> void:
	if ! tile_set is AdvancedTileSet:
		return
	if ! tile_set.get_source(source_index) is TileSetAtlasSource:
		return
	_draw_non_editable_tiles()
	_draw_fadeout_overlay()
	_draw_editable_tiles()


func apply_settings(new_settings: Dictionary) -> void:
	mode = new_settings.mode
	lmb_terrain_index = new_settings.lmb_terrain
	rmb_terrain_index = new_settings.rmb_terrain
	shift_lmb_terrain_index = new_settings.shift_lmb_terrain
	queue_redraw()


func _paint_terrain() -> void:
	if cursor_coords == Vector2i(-1, -1):
		return
	var terrain_index: int
	match Input.get_mouse_button_mask():
		MOUSE_BUTTON_MASK_LEFT when Input.is_key_pressed(KEY_SHIFT):
			terrain_index = shift_lmb_terrain_index
		MOUSE_BUTTON_MASK_LEFT:
			terrain_index = lmb_terrain_index
		MOUSE_BUTTON_MASK_RIGHT:
			terrain_index = rmb_terrain_index
		_:
			return
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var tile_coords := atlas.get_tile_at_coords(cursor_coords)
	if tile_coords == Vector2i(-1, -1):
		return
	var tile := AdvancedTileSet.TileKey.new(
			source_index, tile_coords, 0
	)
	tile_set.set_advanced_tile_terrain_index(
			tile, terrain_index
	)
	queue_redraw()


func _paint_mask() -> void:
	if cursor_coords == Vector2i(-1, -1):
		return
	var terrain_index: int
	match Input.get_mouse_button_mask():
		MOUSE_BUTTON_MASK_LEFT when Input.is_key_pressed(KEY_SHIFT):
			terrain_index = shift_lmb_terrain_index
		MOUSE_BUTTON_MASK_LEFT:
			terrain_index = lmb_terrain_index
		MOUSE_BUTTON_MASK_RIGHT:
			terrain_index = rmb_terrain_index
		_:
			return
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var tile_coords := atlas.get_tile_at_coords(cursor_coords)
	if tile_coords == Vector2i(-1, -1):
		return


func _on_tile_set_changed() -> void:
	queue_redraw()


func _draw_non_editable_tiles() -> void:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var size := atlas.get_atlas_grid_size()
	for x in size.x:
		for y in size.y:
			var coords := Vector2i(x, y)
			if atlas.get_tile_at_coords(coords) != Vector2i(-1, -1):
				continue
			var src_rect := Rect2(
					_coords_to_src_px(coords), _tile_size_to_px(Vector2i.ONE)
			)
			var local_rect := _src_rect_to_local_rect(src_rect)
			draw_texture_rect_region(
					atlas.texture, local_rect, src_rect
			)
			draw_rect(
					local_rect,
					Color(1.0, 1.0, 1.0, 0.5),
					false,
			)


func _draw_fadeout_overlay() -> void:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var size := atlas.get_atlas_grid_size()
	draw_rect(
			_src_rect_to_local_rect(Rect2(
					Vector2.ZERO,
					_tile_size_to_px(size),
			)),
			Color(0,0,0,0.5),
	)


func _get_editable_tile_coords() -> Array[Vector2i]:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var size := atlas.get_atlas_grid_size()
	var tiles_coords: Array[Vector2i] = []
	for x in size.x:
		for y in size.y:
			var coords := Vector2i(x,y)
			if atlas.get_tile_at_coords(coords) == coords:
				tiles_coords.append(coords)
	return tiles_coords


func _draw_editable_tiles() -> void:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var coords_under_mouse := atlas.get_tile_at_coords(cursor_coords)
	for coords in _get_editable_tile_coords():
		var src_aab := _get_tile_aab(coords)
		var local_aab := _src_rect_to_local_rect(src_aab)
		var polyline_transform := Transform2D(
				0.0, local_aab.size, 0.0, local_aab.position
		)
		
		var outline := _get_tile_outline(coords)
		var center_point := _points_average(outline)
		var center_shape := _shrink_polygon(
				outline, center_point, CENTER_FLAG_SHRINK
		)
		
		draw_texture_rect_region(atlas.texture, local_aab, src_aab)
		if coords_under_mouse == coords and mode == Mode.SETUP_TERRAIN:
			draw_rect(local_aab, Color(1.0, 0.9, 0.0, 0.5), false, 3.0)
		else:
			draw_rect(local_aab, Color(1.0, 1.0, 1.0, 0.5), false, 1.0)
		draw_polyline(polyline_transform * _polygon_to_polyline(outline),
				Color(1.0, 0.5, 0.5, 0.5)
		)
		
		var terrain := _get_tile_terrain(coords)
		if terrain != null:
			draw_colored_polygon(
					polyline_transform * center_shape,
					terrain.color
			)
			if mode == Mode.SETUP_MASKS:
				var flag_polygons := _get_tile_flag_polygons(coords)
				for polygon: PackedVector2Array in flag_polygons.values():
					var scaled_polygon := polyline_transform * polygon
					draw_circle(mouse_position, 2, Color.MAGENTA)
					if Geometry2D.is_point_in_polygon(mouse_position, scaled_polygon):
						draw_polyline(
								_polygon_to_polyline(scaled_polygon),
								Color(1.0, 0.9, 0.0, 0.5),
								4.0
						)
					else:
						draw_polyline(
								_polygon_to_polyline(scaled_polygon),
								Color(1.0, 1.0, 1.0, 0.5)
						)
		
		# Finally, draw center outline
		draw_polyline(
				polyline_transform
				* _polygon_to_polyline(center_shape),
				Color(1.0, 1.0, 1.0, 0.5)
		)


func _get_tile_flag_polygons(coords: Vector2i) -> Dictionary:
	var terrain := _get_tile_terrain(coords)
	var orientation := tile_set.get_advanced_tile_orientation(
			AdvancedTileSet.TileKey.new(source_index, coords, 0)
	)
	return _get_flag_polygons(
			tile_set.advanced_tile_shape,
			tile_set.advanced_tile_layout_axis,
			terrain.mode,
			orientation
	)
	


func _get_tile_terrain(coords: Vector2i) -> AdvancedTileSet.Terrain:
	var tile_key := AdvancedTileSet.TileKey.new(
			source_index, coords, 0
	)
	var terrain_index: int = tile_set.get_advanced_tile_terrain_index(
			tile_key
	)
	if terrain_index == -1:
		return null
	return tile_set.terrains[terrain_index]
	


func _get_tile_outline(coords: Vector2i) -> PackedVector2Array:
	var shape: AdvancedTileSet.AdvancedTileShape = tile_set.advanced_tile_shape
	var axis: AdvancedTileSet.AdvancedTileLayoutAxis = tile_set.advanced_tile_layout_axis
	var orientation := tile_set.get_advanced_tile_orientation(
			AdvancedTileSet.TileKey.new(source_index, coords, 0)
	)
	return AdvancedTileSet.get_advanced_tile_shape_polygon(
			shape, axis, orientation
	)


func _get_tile_aab(coords: Vector2i) -> Rect2:
	var atlas := tile_set.get_source(source_index)
	return Rect2(
			_coords_to_src_px(coords),
			_tile_size_to_px(atlas.get_tile_size_in_atlas(coords))
	)


func _shrink_polygon(
		polygon: PackedVector2Array, center: Vector2, ratio: float
) -> PackedVector2Array:
	var points := polygon.duplicate()
	for i in points.size():
		points[i] = points[i].lerp(center, ratio)
	return points


func _polygon_to_polyline(polygon: PackedVector2Array) -> PackedVector2Array:
	var out := polygon.duplicate()
	out.append(polygon[0])
	return out


func _coords_to_src_px(coords: Vector2i) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	return (
			coords
			* (atlas.texture_region_size + atlas.separation)
			+ atlas.margins
	)


func _tile_size_to_px(size: Vector2i) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	return (
			size
			* (atlas.texture_region_size + atlas.separation)
			- atlas.separation
	)


func _src_rect_to_local_rect(src_rect: Rect2i) -> Rect2:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	return Rect2(
			(src_rect.position - atlas.margins) * zoom + scroll,
			src_rect.size * zoom,
	)


func _point_to_coords(point: Vector2) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var size := atlas.texture_region_size * zoom
	var separation := atlas.separation * zoom
	var coord := Vector2i((point - scroll) / (size + separation))
	return coord


func _point_to_cell_local(point: Vector2) -> Vector2:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var size := atlas.texture_region_size * zoom
	var separation := atlas.separation * zoom
	return point.posmodv(
		Vector2(size + separation)
	)


func _get_tile_under_point(point: Vector2) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var point_coords := _point_to_coords(point)
	return atlas.get_tile_at_coords(point_coords)


func _point_to_flag(point: Vector2) -> AdvancedTileSet.AdvancedCellNeighbor:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_index)
	var tile_coords := _get_tile_under_point(point)
	if tile_coords == Vector2i(-1, -1):
		return AdvancedTileSet.AdvancedCellNeighbor.SELF
	var shape := tile_set.advanced_tile_shape
	var axis := tile_set.advanced_tile_layout_axis
	var tile_key := AdvancedTileSet.TileKey.new(
			source_index, tile_coords, 0
	)
	var terrain_index := tile_set.get_advanced_tile_terrain_index(tile_key)
	var mode := tile_set.terrains[terrain_index].mode
	var orientation := tile_set.get_advanced_tile_orientation(tile_key)
	var flag_polygons := _get_flag_polygons(
			shape,
			axis,
			mode,
			orientation
	)
	var local := _point_to_cell_local(point)
	for flag in flag_polygons:
		if Geometry2D.is_point_in_polygon(local, flag_polygons[flag]):
			return flag
	return AdvancedTileSet.AdvancedCellNeighbor.SELF


static func _get_flag_polygons(
		shape: AdvancedTileSet.AdvancedTileShape,
		axis: AdvancedTileSet.AdvancedTileLayoutAxis,
		mode: AdvancedTileSet.AdvancedTerrainMode,
		orientation: AdvancedTileSet.AdvancedTileOrientation,
) -> Dictionary:
	var polygons := {}
	var outline := AdvancedTileSet.get_advanced_tile_shape_polygon(
			shape, axis, orientation
	)
	var center_point := _points_average(outline)
	match mode:
		AdvancedTileSet.AdvancedTerrainMode.CORNERS:
			for i in outline.size():
				var point := outline[i]
				var previous := outline[i - 1]
				var next := outline[wrapi(i + 1, 0.0, outline.size())]
				var key := _polygon_point_to_corner_key(outline[i])
				polygons[key] = [
					previous.lerp(point, 0.5),
					point,
					point.lerp(next, 0.5),
					point.lerp(next, 0.5).lerp(
						center_point, CENTER_FLAG_SHRINK),
					point.lerp(
						center_point, CENTER_FLAG_SHRINK),
					previous.lerp(point, 0.5).lerp(
						center_point, CENTER_FLAG_SHRINK),
				]
		AdvancedTileSet.AdvancedTerrainMode.EDGES:
			for i in outline.size():
				var point := outline[i]
				var previous := outline[i - 1]
				var key := _side_between_points(previous, point)
				polygons[key] = [
					previous,
					point,
					point.lerp(
						center_point, CENTER_FLAG_SHRINK),
					previous.lerp(
						center_point, CENTER_FLAG_SHRINK),
				]
		_:
			for i in outline.size():
				var point := outline[i]
				var previous := outline[i - 1]
				var next := outline[wrapi(i + 1, 0.0, outline.size())]
				var corner_key := _polygon_point_to_corner_key(outline[i])
				var side_key := _side_between_points(previous, point)
				polygons[corner_key] = [
					previous.lerp(point, 0.75),
					point,
					point.lerp(next, 0.25),
					point.lerp(next, 0.25).lerp(
						center_point, CENTER_FLAG_SHRINK),
					point.lerp(
						center_point, CENTER_FLAG_SHRINK),
					previous.lerp(point, 0.75).lerp(
						center_point, CENTER_FLAG_SHRINK),
				]
				polygons[side_key] = [
					previous.lerp(point, 0.25),
					previous.lerp(point, 0.75),
					previous.lerp(point, 0.75).lerp(
						center_point, CENTER_FLAG_SHRINK),
					previous.lerp(point, 0.25).lerp(
						center_point, CENTER_FLAG_SHRINK),
				]
	return polygons


static func _polygon_point_to_corner_key(
		point: Vector2
) -> AdvancedTileSet.AdvancedCellNeighbor:
	var CN := AdvancedTileSet.AdvancedCellNeighbor
	var key := AdvancedTileSet.AdvancedCellNeighbor.CORNER
	if point.y < 0.4:
		key |= CN.TOP
	elif point.y > 0.6:
		key |= CN.BOTTOM
	if point.x > 0.6:
		key |= CN.RIGHT
	elif point.x < 0.4:
		key |= CN.LEFT
	return key


static func _side_between_points(
		point1 :Vector2, point2 :Vector2
) -> AdvancedTileSet.AdvancedCellNeighbor:
	var CN := AdvancedTileSet.AdvancedCellNeighbor
	var sum := point1 + point2
	var key := CN.SIDE
	if sum.y < 0.9:
		key |= CN.TOP
	elif sum.y > 1.1:
		key |= CN.BOTTOM
	if sum.x < 0.9:
		key |= CN.LEFT
	if sum.y > 1.0:
		key |= CN.RIGHT
	return key


static func _points_average(points: PackedVector2Array) -> Vector2:
	var sum := Vector2.ZERO
	for point in points:
		sum += point
	return sum / points.size()
