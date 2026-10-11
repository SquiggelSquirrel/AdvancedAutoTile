@tool
class_name AdvancedTileMapLayer
extends TileMapLayer


@export var advanced_tile_set: AdvancedTileSet:
	set(value):
		tile_set = value as AdvancedTileSet
	get:
		return tile_set as AdvancedTileSet
@export var hide_base_class_features := true:
	set(value):
		hide_base_class_features = value
		notify_property_list_changed()
var _incoming_terrains: Dictionary[Vector2i, int] = {}


func _validate_property(property: Dictionary) -> void:
	if property.name == "tile_set" and hide_base_class_features:
		property.usage &= ~ PROPERTY_USAGE_EDITOR


func advanced_autotile_paint_cells(
		terrain_id: int,
		cells: Array[Vector2i],
		preserve_surrounding_connections := true
) -> void:	
	assert(tile_set is AdvancedTileSet)
	if ! tile_set is AdvancedTileSet:
		return
	for cell in cells:
		_incoming_terrains[cell] = terrain_id
	var surrounding_cells:Array[Vector2i] = []
		
	for cell in cells:
		for neighbor in advanced_get_surrounding_cells(cell, true):
			if ! neighbor in cells and ! neighbor in surrounding_cells:
				surrounding_cells.append(neighbor)
		var tile := advanced_autotile_choose_tile(cell)
		set_cell(cell, tile.source_id, tile.coords, tile.alternative_id)
	
	for cell in surrounding_cells:
		var terrain := advanced_get_final_cell_terrain(cell)
		if terrain == -1:
			continue
		var preserve_flags: PackedInt32Array = []
		if preserve_surrounding_connections:
			for flag in advanced_get_existing_cell_mask(cell):
				var preserve_flag := true
				for adjacent in advanced_get_neighbor_cells_for_flag(
						cell,
						flag,
						advanced_tile_set.get_advanced_terrain_mode(terrain)
				):
					if adjacent in cells:
						preserve_flag = false
				if preserve_flag:
					preserve_flags.append(flag)
		var tile := advanced_autotile_choose_tile(
				cell,
				preserve_flags,
				preserve_flags
		)
		set_cell(cell, tile.source_id, tile.coords, tile.alternative_id)
	_incoming_terrains.clear()


func advanced_autotile_choose_tile(
		cell: Vector2i,
		deprioritize_flags: PackedInt32Array = [],
		preserve_flags: PackedInt32Array = []
) -> AdvancedTileSet.TileKey:
	var terrain := advanced_get_final_cell_terrain(cell)
	if terrain == -1:
		return AdvancedTileSet.TileKey.EMPTY
	var mode := advanced_tile_set.get_advanced_terrain_mode(terrain)
	var existing_mask := advanced_get_existing_cell_mask(cell)
	var max_priority := -1 * advanced_tile_set.get_tile_match_priority_bonus()
	var candidates: Array[AdvancedTileSet.TileKey] = []
	var cell_orientation := advanced_tile_set.get_advanced_cell_orientation(cell)
	for tile in advanced_tile_set.get_advanced_tiles():
		if advanced_tile_set.get_advanced_terrain(tile) != terrain:
			continue
		var tile_orientation := advanced_tile_set.get_advanced_orientation(tile)
		if tile_orientation != cell_orientation:
			continue
		var tile_priority := _tile_match_priority(
				cell,
				tile,
				mode,
				existing_mask,
				deprioritize_flags,
				preserve_flags
		)
		if tile_priority > max_priority:
			max_priority = tile_priority
			candidates = [tile]
		elif tile_priority == max_priority:
			candidates.append(tile)
	
	# Should only be empty if no tiles exist for the given terrain
	# (with the correct orientation)
	# - not sure what the best behaviour is, in this situation.
	if candidates.is_empty():
		return AdvancedTileSet.TileKey.EMPTY
	return _tile_select_random(candidates)


func _tile_match_priority(
		cell: Vector2i,
		tile: AdvancedTileSet.TileKey,
		mode: TileGeometry.ConnectionMode,
		existing_mask: Dictionary,
		deprioritize_flags: PackedInt32Array,
		preserve_flags: PackedInt32Array
) -> int:
	var tile_is_match := true
	var tile_priority := 0
	var mask: Dictionary = advanced_tile_set.get_advanced_mask(tile)
	for flag in mask.keys():
		var flag_priority := advanced_tile_set.get_advanced_terrain_priority(mask[flag])
		if flag in preserve_flags and mask[flag] == existing_mask.get(flag, -1):
			tile_priority += flag_priority
			continue
		if ! _flag_matches_neighbors(cell, mask, flag, mode):
			tile_is_match = false
			tile_priority -= flag_priority
		elif flag in deprioritize_flags:
			tile_priority -= flag_priority
		else:
			tile_priority += flag_priority
	if tile_is_match:
		tile_priority += advanced_tile_set.get_tile_match_priority_bonus()
	return tile_priority


func _flag_matches_neighbors(
		cell: Vector2i,
		mask: Dictionary,
		flag: int,
		mode: TileGeometry.ConnectionMode
) -> bool:
	for neighbor in advanced_get_neighbor_cells_for_flag(
			cell, flag, mode
	):
		var neighbor_terrain := advanced_get_final_cell_terrain(neighbor)
		if ! advanced_tile_set.get_advanced_terrain_binds_to(
				mask[flag], neighbor_terrain
		):
			return false
	return true


func _tile_select_random(
		tiles: Array[AdvancedTileSet.TileKey]
) -> AdvancedTileSet.TileKey:
	var sum_probability := 0.0
	for tile in tiles:
		sum_probability += advanced_tile_set.get_tile_data(tile).probability
	var r := randf()
	for tile in tiles:
		r -= (
				advanced_tile_set.get_tile_data(tile).probability
				/ sum_probability
		)
		if r < 0.0 or is_zero_approx(r):
			return tile
	# Should not be reachable, float rounding error?
	return tiles[0]


func advanced_get_final_cell_terrain(cell: Vector2i) -> int:
	var incoming := _incoming_terrains.get(cell, TileGeometry.FLAG_IGNORE)
	if incoming != TileGeometry.FLAG_IGNORE:
		return incoming
	var source_id := get_cell_source_id(cell)
	var atlas_coords := get_cell_atlas_coords(cell)
	var alternative_id := get_cell_alternative_tile(cell)
	var tile := AdvancedTileSet.TileKey.new(source_id, atlas_coords, alternative_id)
	return advanced_tile_set.get_advanced_terrain(tile)


func advanced_get_existing_cell_mask(cell: Vector2i) -> Dictionary:
	var cell_orientation := advanced_tile_set.get_advanced_cell_orientation(cell)
	var source_id := get_cell_source_id(cell)
	var atlas_coords := get_cell_atlas_coords(cell)
	var alternative_id := get_cell_alternative_tile(cell)
	var tile := AdvancedTileSet.TileKey.new(
			source_id, atlas_coords, alternative_id
	)
	if advanced_tile_set.get_advanced_orientation(tile) != cell_orientation:
		return {}
	return advanced_tile_set.get_advanced_mask(tile)


func advanced_get_surrounding_cells(
		coords: Vector2i,
		include_diagonals := false
) -> Array[Vector2i]:
	var mode := (
			TileGeometry.ConnectionMode.CORNERS_AND_EDGES
			if include_diagonals and TileGeometry.shape_has_diagonals(advanced_tile_set.advanced_shape)
			else TileGeometry.ConnectionMode.EDGES
	)
	var orientation := advanced_tile_set.get_advanced_cell_orientation(coords)
	var flags := TileGeometry.get_flags(
			mode,
			advanced_tile_set.advanced_shape,
			advanced_tile_set.advanced_axis,
			orientation,
	)
	var cells: Array[Vector2i] = []
	for flag in flags:
		cells.append(advanced_get_neighbor_cell(coords, flag))
		if (
				advanced_tile_set.advanced_shape == TileGeometry.Shape.TRIANGLE
				and
				bool(flag & TileGeometry.CellNeighbor.CORNER)
		):
			cells.append(advanced_get_neighbor_cell(
					coords,
					flag | TileGeometry.CellNeighbor.COUNTERCLOCKWISE
			))
			cells.append(advanced_get_neighbor_cell(
					coords,
					flag | TileGeometry.CellNeighbor.CLOCKWISE
			))
	return cells


func advanced_get_neighbor_cell(
		coords: Vector2i,
		neighbor: TileGeometry.CellNeighbor
) -> Vector2i:
	var CN := TileGeometry.CellNeighbor
	var OR := TileGeometry.Orientation
	if advanced_tile_set.advanced_shape != TileGeometry.Shape.TRIANGLE:
		var base_neighbor := TileGeometry.advanced_neighbor_to_base_neighbor(neighbor)
		return get_neighbor_cell(coords, base_neighbor)
	var orientation := advanced_tile_set.get_advanced_cell_orientation(coords)
	return TileGeometry.get_triangle_neighbor_cell(coords, neighbor, orientation)


func advanced_get_neighbor_cells_for_flag(
		cell: Vector2i,
		flag: TileGeometry.CellNeighbor,
		mode: TileGeometry.ConnectionMode
) -> Array[Vector2i]:
	var result_cells: Array[Vector2i] = []
	for neighbor_flag in advanced_get_neighbor_flags_for_flag(cell, flag, mode):
		result_cells.append(advanced_get_neighbor_cell(cell, neighbor_flag))
	return result_cells


func advanced_get_neighbor_flags_for_flag(
		cell: Vector2i,
		flag: TileGeometry.CellNeighbor,
		mode: TileGeometry.ConnectionMode
) -> Array[TileGeometry.CellNeighbor]:
	var CN := TileGeometry.CellNeighbor
	var CM := TileGeometry.ConnectionMode
	
	# For every mode excpe match-corners, and every flag that isn't a corner
	# flag, the neighbor flag is just the same as the mask flag.
	if not (flag & CN.CORNER and mode & CM.CORNERS):
		return [flag]
	
	# ====
	# NB. from here it must be a corner flag in corner connections mode
	
	# The same flag but as a side instead of a corner
	var side_flag := (flag | CN.SIDE) & ~ CN.CORNER
	
	match advanced_tile_set.advanced_shape:
		TileGeometry.Shape.SQUARE:
			# One side can be found by stripping horizontal component,
			# the other by stripping vertical
			return [
				side_flag & ~ (CN.LEFT | CN.RIGHT),
				flag,
				side_flag & ~ (CN.TOP | CN.BOTTOM),
			]
		TileGeometry.Shape.ISOMETRIC:
			if flag & (CN.TOP | CN.BOTTOM):
				# TOP or BOTTOM corner flag, sides are TL/TR or BL/BR
				return [
					side_flag | CN.LEFT,
					flag,
					side_flag | CN.RIGHT,
				]
			return [
				side_flag | CN.TOP,
				flag,
				side_flag | CN.BOTTOM,
			]
		TileGeometry.Shape.TRIANGLE:
			if not (flag & (CN.TOP | CN.BOTTOM)):
				# Flag does not have a vertical component
				# (e.g. LEFT -> TL, LCC, L, LC, BL)
				return [
					CN.TOP_SIDE,
					flag | CN.COUNTERCLOCKWISE,
					flag,
					flag | CN.CLOCKWISE,
					CN.BOTTOM_SIDE,
				]
			if not (flag & (CN.LEFT | CN.RIGHT)):
				# Flag does not have a horizontal component
				return [
					CN.LEFT_SIDE,
					flag | CN.COUNTERCLOCKWISE,
					flag,
					flag | CN.CLOCKWISE,
					CN.RIGHT_SIDE,
				]
			return [
				side_flag & ~ (CN.LEFT | CN.RIGHT),
				flag | CN.COUNTERCLOCKWISE,
				flag,
				flag | CN.CLOCKWISE,
				side_flag & ~ (CN.TOP | CN.BOTTOM),
			]
		_:
			assert(advanced_tile_set.advanced_shape in [
					TileGeometry.Shape.HALF_OFFSET_SQUARE,
					TileGeometry.Shape.HEXAGON
			])
			if advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
				if not (flag & (CN.TOP | CN.BOTTOM)):
					return [
						side_flag | CN.TOP,
						side_flag | CN.BOTTOM,
					]
				return [
					side_flag,
					side_flag & ~ (CN.LEFT | CN.RIGHT),
				]
			else:
				assert(advanced_tile_set.advanced_axis == TileGeometry.Axis.HORIZONTAL)
				if not (flag & (CN.LEFT | CN.RIGHT)):
					return [
						side_flag | CN.LEFT,
						side_flag | CN.RIGHT,
					]
				return [
					side_flag,
					side_flag & ~ (CN.TOP | CN.BOTTOM),
				]
