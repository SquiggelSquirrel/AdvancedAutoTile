@tool
extends Control

enum Mode {
	SETUP_TERRAIN = 0,
	SETUP_MASKS = 1,
	SETUP_ORIENTATION = 2,
}
var drag_start := Vector2.INF
var drag_scroll_start := Vector2.ZERO
var mode: Mode = Mode.SETUP_TERRAIN
var lmb_terrain_index: int = -1
var rmb_terrain_index: int = -1
var shift_lmb_terrain_index: int = -1
var paint_orientation: TileGeometry.Orientation
var tile_set: AdvancedTileSet:
	set(value):
		if value == tile_set:
			return
		if tile_set is AdvancedTileSet:
			if tile_set.changed.is_connected(_on_tile_set_changed):
				tile_set.changed.disconnect(_on_tile_set_changed)
		tile_set = value
		if tile_set is AdvancedTileSet:
			tile_set.changed.connect(_on_tile_set_changed)
		queue_redraw()
var source_id: int = -1:
	set(value):
		source_id = value
		queue_redraw()
var scroll := Vector2.ZERO
var zoom := 1.0
var tile_under_mouse: AdvancedTileSet.TileKey = null
var flag_under_mouse := TileGeometry.CellNeighbor.SELF


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
				match mode:
					Mode.SETUP_TERRAIN:
						_paint_terrain()
					Mode.SETUP_MASKS:
						_paint_mask()
					Mode.SETUP_ORIENTATION:
						_paint_orientation()
	elif event is InputEventMouseMotion:
		if drag_start.is_finite():
			scroll = drag_scroll_start + event.position - drag_start
			queue_redraw()
			return
		
		var new_tile_under_mouse := _get_tile_under_point(event.position)
		if new_tile_under_mouse == null or tile_under_mouse == null:
			tile_under_mouse = new_tile_under_mouse
			queue_redraw()
		elif ! new_tile_under_mouse.equals(tile_under_mouse):
			tile_under_mouse = new_tile_under_mouse
			queue_redraw()
			
		if mode == Mode.SETUP_TERRAIN:
			_paint_terrain()
			return
			
		var new_flag_under_mouse: TileGeometry.CellNeighbor
		if tile_under_mouse == null:
			new_flag_under_mouse = TileGeometry.CellNeighbor.SELF
		else:
			new_flag_under_mouse = _point_to_flag(event.position)
		
		if new_flag_under_mouse != flag_under_mouse:
			flag_under_mouse = new_flag_under_mouse
			queue_redraw()
		
		if mode == Mode.SETUP_MASKS:
			_paint_mask()


func _draw() -> void:
	if ! tile_set is AdvancedTileSet:
		return
	if ! tile_set.get_source(source_id) is TileSetAtlasSource:
		return
	_draw_non_editable_tiles()
	_draw_fadeout_overlay()
	_draw_editable_tiles()


func apply_settings(new_settings: Dictionary) -> void:
	mode = new_settings.mode
	lmb_terrain_index = new_settings.lmb_terrain
	rmb_terrain_index = new_settings.rmb_terrain
	shift_lmb_terrain_index = new_settings.shift_lmb_terrain
	paint_orientation = new_settings.orientation
	queue_redraw()


func _paint_terrain() -> void:
	if tile_under_mouse == null:
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
	tile_set.set_advanced_terrain(
			tile_under_mouse, terrain_index
	)
	queue_redraw()


func _paint_mask() -> void:
	if tile_under_mouse == null:
		return
	if flag_under_mouse == TileGeometry.CellNeighbor.SELF:
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
	tile_set.set_advanced_flag(tile_under_mouse, flag_under_mouse, terrain_index)
	queue_redraw()


func _paint_orientation() -> void:
	if tile_under_mouse == null:
		return
	tile_set.set_advanced_orientation(tile_under_mouse, paint_orientation)
	queue_redraw()


func _on_tile_set_changed() -> void:
	queue_redraw()


func _draw_non_editable_tiles() -> void:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var size := atlas.get_atlas_grid_size()
	for x in size.x:
		for y in size.y:
			var coords := Vector2i(x, y)
			if atlas.get_tile_at_coords(coords) != Vector2i(-1, -1):
				continue
			var src_rect := Rect2(
					_coords_to_src_px(coords), _tile_size_to_src_px(Vector2i.ONE)
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
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var size := atlas.get_atlas_grid_size()
	draw_rect(
			_src_rect_to_local_rect(Rect2(
					Vector2.ZERO,
					_tile_size_to_src_px(size),
			)),
			Color(0,0,0,0.5),
	)


func _get_editable_tiles() -> Array[AdvancedTileSet.TileKey]:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var size := atlas.get_atlas_grid_size()
	var tiles: Array[AdvancedTileSet.TileKey] = []
	for x in size.x:
		for y in size.y:
			var coords := Vector2i(x,y)
			if atlas.get_tile_at_coords(coords) == coords:
				tiles.append(
						AdvancedTileSet.TileKey.new(
								source_id, coords, 0
						)
				)
	return tiles


func _get_tile_local_transform(tile: AdvancedTileSet.TileKey) -> Transform2D:
	const ROTATION := 0
	const SKEW := 0
	var atlas: TileSetAtlasSource = tile_set.get_source(tile.source_id)
	var position := Vector2(_coords_to_src_px(tile.coords)) * zoom + scroll
	var scale := _tile_size_to_src_px(atlas.get_tile_size_in_atlas(tile.coords)) * zoom
	return Transform2D(ROTATION, scale, SKEW, position)


func _draw_editable_tiles() -> void:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	for tile in _get_editable_tiles():
		var local_transform := _get_tile_local_transform(tile)
		var src_rect := _get_tile_src_rect(tile)
		var local_rect := local_transform * Rect2(Vector2.ZERO, Vector2.ONE)
		var outline := _get_tile_outline(tile)
		var center_shape: PackedVector2Array = TileGeometry.get_flag_polygons(
				tile_set.advanced_shape,
				tile_set.advanced_axis,
				TileGeometry.ConnectionMode.NONE,
				tile_set.get_advanced_orientation(tile)
		)[TileGeometry.CellNeighbor.SELF]
		draw_texture_rect_region(atlas.texture, local_rect, src_rect)
		if tile.equals(tile_under_mouse) and mode in [
				Mode.SETUP_TERRAIN,
				Mode.SETUP_ORIENTATION
		]:
			draw_rect(local_rect, Color(1.0, 0.9, 0.0, 0.5), false, 3.0)
		else:
			draw_rect(local_rect, Color(1.0, 1.0, 1.0, 0.5), false, 1.0)
		
		draw_polyline(local_transform * _polygon_to_polyline(outline),
				Color(1.0, 0.5, 0.5, 0.5)
		)
		
		var terrain_index: int = tile_set.get_advanced_terrain(tile)
		if terrain_index != -1:
			draw_colored_polygon(
					local_transform * center_shape,
					tile_set.get_advanced_terrain_color(terrain_index),
			)
			if mode == Mode.SETUP_MASKS:
				var flag_polygons := _get_tile_flag_polygons(tile)
				var mask := tile_set.get_advanced_mask(tile)
				for flag_key in flag_polygons.keys():
					var polygon: PackedVector2Array = flag_polygons[flag_key]
					var scaled_polygon := local_transform * polygon
					var flag_value := mask.get(flag_key, TileGeometry.FLAG_EMPTY)
					if flag_value != TileGeometry.FLAG_EMPTY:
						draw_colored_polygon(
								scaled_polygon,
								tile_set.get_advanced_terrain_color(flag_value),
						)
					if tile.equals(tile_under_mouse) and flag_under_mouse == flag_key:
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
				local_transform * _polygon_to_polyline(center_shape),
				Color(1.0, 1.0, 1.0, 0.5)
		)


func _get_tile_flag_polygons(tile: AdvancedTileSet.TileKey) -> Dictionary:
	var terrain_index: int = tile_set.get_advanced_terrain(tile)
	var orientation := tile_set.get_advanced_orientation(tile)
	return TileGeometry.get_flag_polygons(
			tile_set.advanced_shape,
			tile_set.advanced_axis,
			tile_set.get_advanced_terrain_mode(terrain_index),
			orientation,
	)


func _get_tile_outline(tile: AdvancedTileSet.TileKey) -> PackedVector2Array:
	var shape: TileGeometry.Shape
	shape = tile_set.advanced_shape
	var axis: TileGeometry.Axis
	axis = tile_set.advanced_axis
	var orientation := tile_set.get_advanced_orientation(tile)
	return TileGeometry.get_tile_polygon(
			shape, axis, orientation
	)


func _get_tile_src_rect(tile: AdvancedTileSet.TileKey) -> Rect2:
	var atlas := tile_set.get_source(tile.source_id)
	return Rect2(
			_coords_to_src_px(tile.coords),
			_tile_size_to_src_px(atlas.get_tile_size_in_atlas(tile.coords))
	)


func _polygon_to_polyline(polygon: PackedVector2Array) -> PackedVector2Array:
	var out := polygon.duplicate()
	out.append(polygon[0])
	return out


func _coords_to_src_px(coords: Vector2i) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	return (
			coords
			* (atlas.texture_region_size + atlas.separation)
			+ atlas.margins
	)


func _tile_size_to_src_px(size: Vector2i) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	return (
			size
			* (atlas.texture_region_size + atlas.separation)
			- atlas.separation
	)


func _src_rect_to_local_rect(src_rect: Rect2i) -> Rect2:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	return Rect2(
			(src_rect.position - atlas.margins) * zoom + scroll,
			src_rect.size * zoom,
	)


func _point_to_coords(point: Vector2) -> Vector2i:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var size := atlas.texture_region_size * zoom
	var separation := atlas.separation * zoom
	var coord := Vector2i((point - scroll) / (size + separation))
	return coord


func _point_to_tile_local(
		point: Vector2, tile: AdvancedTileSet.TileKey
) -> Vector2:
	var transform := _get_tile_local_transform(tile)
	return transform.affine_inverse() * point


func _get_tile_under_point(point: Vector2) -> AdvancedTileSet.TileKey:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var point_coords := _point_to_coords(point)
	var tile_coords := atlas.get_tile_at_coords(point_coords)
	if tile_coords == Vector2i(-1, -1):
		return null
	return AdvancedTileSet.TileKey.new(
			source_id,
			tile_coords,
			0
	)


func _point_to_flag(point: Vector2) -> TileGeometry.CellNeighbor:
	var atlas: TileSetAtlasSource = tile_set.get_source(source_id)
	var tile: AdvancedTileSet.TileKey = _get_tile_under_point(point)
	if tile == null:
		return TileGeometry.CellNeighbor.SELF
	var terrain_index := tile_set.get_advanced_terrain(tile)
	if terrain_index == -1:
		return TileGeometry.CellNeighbor.SELF
	var shape := tile_set.advanced_shape
	var axis := tile_set.advanced_axis
	var mode := tile_set.get_advanced_terrain_mode(terrain_index)
	var orientation := tile_set.get_advanced_orientation(tile)
	var flag_polygons := TileGeometry.get_flag_polygons(
			shape,
			axis,
			mode,
			orientation
	)
	var local := _point_to_tile_local(point, tile)
	for flag in flag_polygons:
		if Geometry2D.is_point_in_polygon(local, flag_polygons[flag]):
			return flag
	return TileGeometry.CellNeighbor.SELF



# Return the average point from an array of points
static func _points_average(points: PackedVector2Array) -> Vector2:
	var sum := Vector2.ZERO
	for point in points:
		sum += point
	return sum / points.size()
