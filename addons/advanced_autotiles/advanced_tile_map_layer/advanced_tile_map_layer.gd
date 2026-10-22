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
		preserve_surrounding_connections := true,
		dry_run := false
) -> Dictionary:
	if ! tile_set is AdvancedTileSet:
		return {}
	var changes := {}
	for cell in cells:
		_incoming_terrains[cell] = terrain_id
	var surrounding_cells:Array[Vector2i] = []
		
	for cell in cells:
		for neighbor in advanced_get_surrounding_cells(cell, true):
			if ! neighbor in cells and ! neighbor in surrounding_cells:
				surrounding_cells.append(neighbor)
		
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(cell)
		)
	
	for cell in surrounding_cells:
		var terrain := advanced_get_final_cell_terrain(cell)
		if terrain == -1:
			continue
		var existing_mask := advanced_get_existing_cell_mask(cell)
		var preserve_mask := {}
		if preserve_surrounding_connections:
			for flag in advanced_get_existing_cell_mask(cell):
				var preserve_flag := true
				for adjacent in advanced_get_neighbor_cells_for_flag(
						cell,
						flag,
						TileGeometry.ConnectionMode.CORNERS_AND_EDGES
				):
					if adjacent in cells:
						preserve_flag = false
						break
				if preserve_flag:
					preserve_mask[flag] = existing_mask[flag]
					
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(cell, preserve_mask)
		)
	_incoming_terrains.clear()
	return changes


func advanced_autotile_paint_corners(
		terrain: int,
		cells: Array[Vector2i],
		flags: Array[TileGeometry.CellNeighbor],
		dry_run := false
) -> Dictionary:
	var changes := {}
	
	# Determine which cells actually need updating,
	# and set up dictioary of unambiguous constraints
	var cells_to_update := cells.duplicate()
	var constraints: Dictionary[Vector2i, Dictionary] = {}
	for i in cells.size():
		var cell: Vector2i = cells[i]
		var flag: TileGeometry.CellNeighbor = flags[wrapi(i, 0, flags.size())]
		var control := _get_control_flag(cell, flag)
		constraints[control[0]] = constraints.get(control[0], {})
		constraints[control[0]][control[1]] = terrain
		for neighbor in advanced_get_neighbor_cells_for_flag(
				cell,
				flag,
				TileGeometry.ConnectionMode.CORNERS
		):
			if not neighbor in cells_to_update:
				cells_to_update.append(neighbor)
	
	# Actually update the cells
	for cell in cells_to_update:
		var cell_terrain := advanced_get_final_cell_terrain(cell)
		var mask := advanced_get_existing_cell_mask(cell)
		for flag in mask.keys():
			if not flag & TileGeometry.CellNeighbor.CORNER:
				continue
			var control := _get_control_flag(cell, flag)
			if constraints.get(control[0], {}).has(control[1]):
				mask[flag] = constraints[control[0]][control[1]]
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(cell, mask)
		)	
	return changes


func advanced_autotile_paint_path(
		terrain_id: int,
		path: Array[Vector2i],
		dry_run := false
) -> Dictionary:
	for cell in path:
		_incoming_terrains[cell] = terrain_id
		
	var surrounding_cells:Array[Vector2i] = []
	for cell in path:
		for neighbor in advanced_get_surrounding_cells(cell, true):
			if ! neighbor in path and ! neighbor in surrounding_cells:
				surrounding_cells.append(neighbor)
	
	var changes := {}
	
	var mode := advanced_tile_set.get_advanced_terrain_mode(terrain_id)
	for i in path.size():
		var cell := path[i]
		var orientation := advanced_tile_set.get_advanced_cell_orientation(cell)
		var preserve_mask := advanced_tile_set.get_terrain_empty_mask(
				terrain_id, orientation
		)
		var existing_mask := advanced_get_existing_cell_mask(cell)
		for flag in existing_mask:
			if preserve_mask.has(flag):
				preserve_mask[flag] = existing_mask[flag]
		if i > 0:
			for flag in preserve_mask.keys():
				if not (
						flag & TileGeometry.CellNeighbor.SIDE
						or (
							mode & TileGeometry.ConnectionMode.DIAGONALS
							and flag & TileGeometry.CellNeighbor.CORNER
						)
				):
					continue
				if path[i-1] == advanced_get_neighbor_cell(cell, flag):
					preserve_mask.erase(flag)
					break
		if i + 1 < path.size():
			for flag in preserve_mask.keys():
				if not (
						flag & TileGeometry.CellNeighbor.SIDE
						or (
							mode & TileGeometry.ConnectionMode.DIAGONALS
							and flag & TileGeometry.CellNeighbor.CORNER
						)
				):
					continue
				if path[i+1] == advanced_get_neighbor_cell(cell, flag):
					preserve_mask.erase(flag)
					break
		
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(cell, preserve_mask)
		)
	
	for cell in surrounding_cells:
		var preserve_mask := advanced_get_existing_cell_mask(cell)
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(cell, preserve_mask)
		)
	
	_incoming_terrains.clear()
	return changes


func _get_control_flag(cell: Vector2i, flag: int) -> Array:
	var CN := TileGeometry.CellNeighbor
	match advanced_tile_set.advanced_shape:
		TileGeometry.Shape.SQUARE:
			return [
					cell + {
						CN.TOP_LEFT_CORNER: Vector2i(0,0),
						CN.TOP_RIGHT_CORNER: Vector2i(1,0),
						CN.BOTTOM_LEFT_CORNER: Vector2i(0, 1),
						CN.BOTTOM_RIGHT_CORNER: Vector2i(1, 1)
					}[flag],
					CN.TOP_LEFT_CORNER,
			]
		TileGeometry.Shape.ISOMETRIC:
			return [
					advanced_get_neighbor_cell(cell, {
						CN.TOP_CORNER: CN.SELF,
						CN.RIGHT_CORNER: CN.BOTTOM_RIGHT_SIDE,
						CN.BOTTOM_CORNER: CN.BOTTOM_CORNER,
						CN.LEFT_CORNER: CN.BOTTOM_LEFT_SIDE,
					}[flag]),
					CN.TOP_CORNER,
			]
		TileGeometry.Shape.HALF_OFFSET_SQUARE, TileGeometry.Shape.HEXAGON:
			if advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
				flag = TileGeometry.cell_neighbor_transpose(flag)
			var return_flag: TileGeometry.CellNeighbor
			var neighbor_flag: TileGeometry.CellNeighbor
			match flag:
				CN.TOP_CORNER, CN.TOP_LEFT_CORNER:
					return_flag = flag
					neighbor_flag = CN.SELF
				CN.TOP_RIGHT_CORNER:
					return_flag = CN.TOP_LEFT_CORNER
					neighbor_flag = CN.RIGHT_SIDE
				CN.BOTTOM_RIGHT_SIDE:
					return_flag = CN.TOP_CORNER
					neighbor_flag = CN.BOTTOM_RIGHT_SIDE
				CN.BOTTOM_CORNER:
					return_flag = CN.TOP_LEFT_CORNER
					neighbor_flag = CN.BOTTOM_RIGHT_SIDE
				CN.BOTTOM_LEFT_CORNER:
					return_flag = CN.TOP_CORNER
					neighbor_flag = CN.BOTTOM_LEFT_SIDE
			if advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
				return_flag = TileGeometry.cell_neighbor_transpose(return_flag)
				neighbor_flag = TileGeometry.cell_neighbor_transpose(neighbor_flag)
			return [
					advanced_get_neighbor_cell(cell, neighbor_flag),
					return_flag,
			]
		TileGeometry.Shape.TRIANGLE:
			var return_flag := CN.TOP_CORNER
			if advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
				flag = TileGeometry.cell_neighbor_transpose(flag)
				return_flag = TileGeometry.cell_neighbor_transpose(return_flag)
			var neighbor_flag: TileGeometry.CellNeighbor
			match flag:
				CN.TOP_CORNER:
					neighbor_flag = CN.SELF
				CN.TOP_RIGHT_CORNER:
					neighbor_flag = CN.RIGHT_SIDE
				CN.BOTTOM_RIGHT_CORNER:
					neighbor_flag = CN.BOTTOM_RIGHT_CLOCKWISE_CORNER
				CN.BOTTOM_CORNER:
					neighbor_flag = CN.BOTTOM_CORNER
				CN.BOTTOM_LEFT_CORNER:
					neighbor_flag = CN.BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER
				CN.TOP_LEFT_CORNER:
					neighbor_flag = CN.LEFT_SIDE
			if advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
				neighbor_flag = TileGeometry.cell_neighbor_transpose(neighbor_flag)
			return [
					advanced_get_neighbor_cell(cell, neighbor_flag),
					return_flag,
			]
	assert(false, "Invalid tile shape")
	return [cell, flag]


func advanced_autotile_choose_tile(
		cell: Vector2i,
		prioritize_mask: Dictionary = {},
		dry_run := false
) -> Dictionary:
	var existing := advanced_get_existing_tile(cell)
	var terrain := advanced_get_final_cell_terrain(cell)
	if terrain == -1:
		if existing.equals(AdvancedTileSet.TileKey.EMPTY):
			return {}
		else:
			if ! dry_run:
				set_cell(cell, -1)
			return {
					"old": existing,
					"new": AdvancedTileSet.TileKey.EMPTY
			}
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
				prioritize_mask
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
		if ! dry_run:
			set_cell(cell, -1)
		return {
				"old": existing,
				"new": AdvancedTileSet.TileKey.EMPTY
		}
	var new := _tile_select_random(candidates)
	if new.equals(existing):
		return {}
	else:
		if ! dry_run:
			set_cell(cell, new.source_id, new.coords, new.alternative_id)
		return {
				"old": existing,
				"new": new
		}


func _tile_match_priority(
		cell: Vector2i,
		tile: AdvancedTileSet.TileKey,
		priotitize_mask: Dictionary,
) -> int:
	var terrain := advanced_tile_set.get_advanced_terrain(tile)
	var mode := advanced_tile_set.get_advanced_terrain_mode(terrain)
	var tile_is_match := true
	var tile_priority := 0
	var mask: Dictionary = advanced_tile_set.get_advanced_mask(tile)
	for flag in mask.keys():
		var flag_priority := advanced_tile_set.get_advanced_terrain_priority(mask[flag])
		if not _flag_matches_neighbors(cell, mask, flag, mode):
			tile_is_match = false
			tile_priority -= flag_priority
		elif (
				flag in priotitize_mask.keys()
				and priotitize_mask[flag] != mask[flag]
		):
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
	if _incoming_terrains.has(cell):
		return _incoming_terrains[cell]
	var source_id := get_cell_source_id(cell)
	var atlas_coords := get_cell_atlas_coords(cell)
	var alternative_id := get_cell_alternative_tile(cell)
	var tile := AdvancedTileSet.TileKey.new(source_id, atlas_coords, alternative_id)
	return advanced_tile_set.get_advanced_terrain(tile)


func advanced_get_existing_cell_mask(
		cell: Vector2i
) -> Dictionary:
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
	if neighbor == TileGeometry.CellNeighbor.SELF:
		return coords
	var CN := TileGeometry.CellNeighbor
	var OR := TileGeometry.Orientation
	if advanced_tile_set.advanced_shape != TileGeometry.Shape.TRIANGLE:
		var base_neighbor := TileGeometry.advanced_neighbor_to_base_neighbor(neighbor)
		return get_neighbor_cell(coords, base_neighbor)
	var orientation := advanced_tile_set.get_advanced_cell_orientation(coords)
	return TileGeometry.get_triangle_neighbor_cell(coords, neighbor, orientation)


func advanced_get_existing_tile(cell: Vector2i) -> AdvancedTileSet.TileKey:
	var source_id := get_cell_source_id(cell)
	if source_id == -1:
		return AdvancedTileSet.TileKey.EMPTY
	return AdvancedTileSet.TileKey.new(
			source_id,
			get_cell_atlas_coords(cell),
			get_cell_alternative_tile(cell)
	)


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


func _merge_changes(
		changes: Dictionary, cell: Vector2i, change: Dictionary
) -> Dictionary:
	if change.is_empty():
		return changes
	else:
		changes[cell] = change
		return changes
