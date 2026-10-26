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


func advanced_local_to_map(local: Vector2) -> Vector2i:
	if advanced_tile_set.advanced_shape != TileGeometry.Shape.TRIANGLE:
		return local_to_map(local)
	var base := local_to_map(local)
	var orientation := advanced_tile_set.get_advanced_cell_orientation(base)
	var center := map_to_local(base)
	var in_cell := local - center
	match orientation:
		TileGeometry.Orientation.UP:
			if (in_cell.x * 2.0) + in_cell.y < 1.0:
				return base + Vector2i(-1, 0)
			if (in_cell.x * 2.0) - in_cell.y >= 1.0:
				return base + Vector2i(1, 0)
		TileGeometry.Orientation.DOWN:
			if (in_cell.x * 2.0) - in_cell.y < 0.0:
				return base + Vector2i(-1, 0)
			if (in_cell.x * 2.0) + in_cell.y >= 2.0:
				return base + Vector2i(1, 0)
		TileGeometry.Orientation.LEFT:
			if (in_cell.y * 2.0) + in_cell.x < 1.0:
				return base + Vector2i(0, -1)
			if (in_cell.y * 2.0) - in_cell.x >= 1.0:
				return base + Vector2i(0, 1)
		TileGeometry.Orientation.RIGHT:
			if (in_cell.y * 2.0) - in_cell.x < 0.0:
				return base + Vector2i(0, -1)
			if (in_cell.y * 2.0) + in_cell.x >= 2.0:
				return base + Vector2i(0, 1)
	return base


func advanced_autotile_paint_cells(
		terrain_id: int,
		cells: Array[Vector2i],
		preserve_surrounding_connections := true,
		dry_run := false
) -> Dictionary:
	var changes: Dictionary[Vector2i, Dictionary] = {}
	add_incoming_terrain(terrain_id, cells)

	for cell in cells:
		var change := advanced_autotile_choose_tile(cell)
		_merge_changes(changes, cell, change)
	
	var connection_mode := advanced_tile_set.get_advanced_terrain_mode(
			terrain_id
	)
	
	for cell in get_cells_surrounding_cells(cells, true):
		var prioritise_mask := {}
		
		if preserve_surrounding_connections:
			var orientation := advanced_tile_set.get_advanced_cell_orientation(
					cell
			)
			var existing_mask := advanced_get_existing_cell_mask(cell)
			for flag in advanced_get_existing_cell_mask(cell):
				if ! _cell_flag_touches_region(cell, flag, cells):
					prioritise_mask[flag] = existing_mask[flag]
					continue
		
		changes = _merge_changes(
				changes,
				cell,
				advanced_autotile_choose_tile(
					cell,
					prioritise_mask
				)
		)
	
	clear_incoming_terrains()
	return changes


func advanced_autotile_paint_path(
		terrain_id: int,
		path: Array[Vector2i],
		dry_run := false
) -> Dictionary:
	add_incoming_terrain(terrain_id, path)
	var changes := {}
	
	var connection_mode := advanced_tile_set.get_advanced_terrain_mode(
			terrain_id
	)
	var has_diagonals := bool(
			connection_mode & TileGeometry.ConnectionMode.DIAGONALS
	)
	var non_acute := has_diagonals and bool(
			connection_mode & TileGeometry.ConnectionMode.NON_ACUTE
	)
	for i in path.size():
		var cell := path[i]
		var is_first := bool(i == 0)
		var is_last := bool(i == path.size() - 1)
		
		var orientation := advanced_tile_set.get_advanced_cell_orientation(cell)
		var empty_mask := advanced_tile_set.get_terrain_empty_mask(
				terrain_id, orientation
		)
		var preserve_mask := advanced_get_existing_cell_mask(cell)
		for flag in empty_mask:
			if not preserve_mask.has(flag):
				preserve_mask[flag] = empty_mask[flag]
		
		var pathable_flags: PackedInt32Array
		if has_diagonals:
			pathable_flags = preserve_mask.keys()
		else:
			pathable_flags = preserve_mask.keys().filter(
				func(flag): return flag & TileGeometry.CellNeighbor.SIDE
			)
		if not is_first:
			_mask_apply_path(
					preserve_mask,
					cell,
					path[i-1],
					pathable_flags,
					non_acute,
					terrain_id
			)
		if not is_last:
			_mask_apply_path(
					preserve_mask,
					cell,
					path[i+1],
					pathable_flags,
					non_acute,
					terrain_id
			)
		var change := advanced_autotile_choose_tile(cell, preserve_mask)
		_merge_changes(changes, cell, change)
	
	for cell in get_cells_surrounding_cells(path, true):
		var preserve_mask := advanced_get_existing_cell_mask(cell)
		if non_acute:
			for diagonal_flag in preserve_mask.keys().filter(
				func(flag): return flag & TileGeometry.CellNeighbor.CORNER
			):
				var between_two_sides := true
				var count_path_neighbors := 0
				if advanced_get_neighbor_cell(cell, diagonal_flag) in path:
					count_path_neighbors += 1
				for side_flag in advanced_get_side_flags_for_diagonal(
						cell, diagonal_flag
				):
					if advanced_get_neighbor_cell(cell, side_flag) not in path:
						between_two_sides = false
					else:
						count_path_neighbors += 1
				if between_two_sides:
					for side_flag in advanced_get_side_flags_for_diagonal(
							cell, diagonal_flag
					):
						preserve_mask[side_flag] = TileGeometry.FLAG_EMPTY
				if count_path_neighbors > 1:
					preserve_mask[diagonal_flag] = TileGeometry.FLAG_EMPTY
		
		var change := advanced_autotile_choose_tile(cell, preserve_mask)
		_merge_changes(changes, cell, change)
	
	clear_incoming_terrains()
	return changes


func _mask_apply_path(
		mask: Dictionary,
		cell: Vector2i,
		neighbor_cell:Vector2i,
		pathable_flags: Array[TileGeometry.CellNeighbor],
		non_acute: bool,
		terrain_id: int
) -> void:
	var connection_flag := TileGeometry.CellNeighbor.SELF
	for flag in pathable_flags:
		if advanced_get_neighbor_cell(cell, flag) == neighbor_cell:
			connection_flag = flag
			break
	if connection_flag == TileGeometry.CellNeighbor.SELF:
		return
	mask[connection_flag] = terrain_id
	if not non_acute:
		return
	if bool(connection_flag & TileGeometry.CellNeighbor.CORNER):
		for side_flag in advanced_get_side_flags_for_diagonal(
				cell, connection_flag
		):
			mask[side_flag] = TileGeometry.FLAG_EMPTY
	else:
		for diagonal_flag in TileGeometry.get_corners_of_side(
				connection_flag,
				advanced_tile_set.advanced_shape,
				advanced_tile_set.advanced_axis,
				advanced_tile_set.get_advanced_cell_orientation(cell)
		):
			mask[diagonal_flag] = TileGeometry.FLAG_EMPTY


func advanced_autotile_paint_corners(
		terrain_id: int,
		cells: Array[Vector2i],
		flags: Array[TileGeometry.CellNeighbor],
		dry_run := false
) -> Dictionary:
	var changes: Dictionary[Vector2i, Dictionary] = {}
	var constraints := ConstraintSet.new(
			advanced_tile_set.advanced_shape,
			advanced_tile_set.advanced_axis
	)
	for i in cells.size():
		var connection_mode := advanced_tile_set.get_advanced_terrain_mode(
				advanced_get_final_cell_terrain(cells[i])
		)
		constraints.add_constraint(
				self,
				cells[i],
				flags[wrapi(i, 0, flags.size())],
				connection_mode,
				terrain_id
		)
	
	for cell in _get_cells_around_constraints(constraints):
		var connection_mode := advanced_tile_set.get_advanced_terrain_mode(
				advanced_get_final_cell_terrain(cell)
		)
		var mask := advanced_get_existing_cell_mask(cell)
		for flag in mask.keys().filter(
				func(flag): return flag & TileGeometry.CellNeighbor.CORNER
		):
			if constraints.has_constraint(
					self,
					cell,
					flag,
					connection_mode
			):
				mask[flag] = constraints.get_constraint(
						self,
						cell,
						flag,
						connection_mode
				)
		
		var change = advanced_autotile_choose_tile(cell, mask)
		_merge_changes(changes, cell, change)
	return changes


func add_incoming_terrain(terrain_id: int, cells: Array[Vector2i]) -> void:
	for cell in cells:
		_incoming_terrains[cell] = terrain_id


func clear_incoming_terrains() -> void:
	_incoming_terrains.clear()


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
	var max_priority := TilePriority.new()
	max_priority.matching_tile = false
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
		match tile_priority.compare(max_priority):
			TilePriority.Comparison.OTHER_IS_LESSER:
				max_priority = tile_priority
				candidates = [tile]
			TilePriority.Comparison.EQUAL:
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


func _cell_flag_touches_region(
		cell: Vector2i,
		flag: TileGeometry.CellNeighbor,
		region: Array[Vector2i]
) -> bool:
	for adjacent in advanced_get_neighbor_cells_for_flag(
			cell,
			flag,
			TileGeometry.ConnectionMode.CORNERS_AND_EDGES
	):
		if adjacent in region:
			return true
	return false


func _get_cells_around_constraints(
		constraints: ConstraintSet
) -> Array[Vector2i]:
	#n.b. support for side constraint not implemented
	var cells: Array[Vector2i] = []
	for i in constraints.get_count():
		var cell := constraints.get_cell(i)
		if cell not in cells:
			cells.append(cell)
		var flag := constraints.get_flag(i)
		for neighbor in advanced_get_neighbor_cells_for_flag(
				cell,
				flag,
				TileGeometry.ConnectionMode.CORNERS
		):
			if neighbor not in cells:
				cells.append(neighbor)
	return cells


func _tile_match_priority(
		cell: Vector2i,
		tile: AdvancedTileSet.TileKey,
		priotitize_mask: Dictionary
) -> TilePriority:
	var terrain := advanced_tile_set.get_advanced_terrain(tile)
	var mode := advanced_tile_set.get_advanced_terrain_mode(terrain)
	var tile_priority := TilePriority.new()
	var mask: Dictionary = advanced_tile_set.get_advanced_mask(tile)
	for flag in mask.keys():
		var flag_priority := advanced_tile_set.get_advanced_terrain_priority(
				mask[flag]
		)
		
		if not _flag_matches_neighbors(cell, mask, flag, mode):
			tile_priority.matching_tile = false
			tile_priority.add_priorty(-1 * flag_priority)
		elif (
				priotitize_mask.has(flag)
				and priotitize_mask[flag] != mask[flag]
		):
			tile_priority.add_priorty(-1 * flag_priority)
		elif (
				flag & TileGeometry.CellNeighbor.CORNER
				and
				mode & TileGeometry.ConnectionMode.NON_ACUTE
				and not
				priotitize_mask.has(flag)
				and not
				_flag_matches_one_neighbor(cell, mask, flag)
		):
			tile_priority.add_priorty(-1 * flag_priority)
		else:
			tile_priority.add_priorty(flag_priority)
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


func _flag_matches_one_neighbor(
		cell: Vector2i,
		mask: Dictionary,
		flag: int
) -> bool:
	var matches := 0
	for neighbor in advanced_get_neighbor_cells_for_flag(
			cell, flag, TileGeometry.ConnectionMode.CORNERS_AND_EDGES
	):
		var neighbor_terrain := advanced_get_final_cell_terrain(neighbor)
		if advanced_tile_set.get_advanced_terrain_binds_to(
				mask[flag], neighbor_terrain
		):
			matches += 1
	return bool(matches == 1)


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


func get_cells_surrounding_cells(
		cells: Array[Vector2i],
		include_diagonals := false
) -> Array[Vector2i]:
	var surrounding_cells:Array[Vector2i] = []
	for cell in cells:
		for neighbor in advanced_get_surrounding_cells(cell, include_diagonals):
			if ! neighbor in cells and ! neighbor in surrounding_cells:
				surrounding_cells.append(neighbor)
	return surrounding_cells


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


func advanced_get_side_flags_for_diagonal(
		cell: Vector2i,
		diagonal_flag: TileGeometry.CellNeighbor
) -> Array[TileGeometry.CellNeighbor]:
	return advanced_get_neighbor_flags_for_flag(
			cell, diagonal_flag, TileGeometry.ConnectionMode.CORNERS
	).filter(
		func(flag): return flag != diagonal_flag
	)


func _merge_changes(
		changes: Dictionary, cell: Vector2i, change: Dictionary
) -> Dictionary:
	if change.is_empty():
		return changes
	else:
		changes[cell] = change
		return changes


class TilePriority:
	enum Comparison {OTHER_IS_LESSER, EQUAL, OTHER_IS_GREATER}
	var matching_tile := true
	var priorities := {}
	
	func add_priorty(priority: int) -> void:
		if priorities.has(priority):
			priorities[priority] += 1
		else:
			priorities[priority] = 1
	
	
	func compare(other: TilePriority) -> Comparison:
		if matching_tile and not other.matching_tile:
			return Comparison.OTHER_IS_LESSER
		if other.matching_tile and not matching_tile:
			return Comparison.OTHER_IS_GREATER
		
		var my_priority_list := PackedInt32Array(priorities.keys())
		my_priority_list.sort()
		my_priority_list.reverse()
		var other_list := PackedInt32Array(other.priorities.keys())
		other_list.sort()
		other_list.reverse()
		for i in maxi(my_priority_list.size(), other_list.size()):
			if i >= my_priority_list.size():
				return Comparison.OTHER_IS_GREATER
			if i >= other_list.size():
				return Comparison.OTHER_IS_LESSER
			if my_priority_list[i] > other_list[i]:
				return Comparison.OTHER_IS_LESSER
			if my_priority_list[i] < other_list[i]:
				return Comparison.OTHER_IS_GREATER
			var key := my_priority_list[i]
			if priorities[key] > other.priorities[key]:
				return Comparison.OTHER_IS_LESSER
			if priorities[key] < other.priorities[key]:
				return Comparison.OTHER_IS_GREATER
		
		return Comparison.EQUAL


class ConstraintSet:
	const CN := TileGeometry.CellNeighbor
	enum FlagType {CORNER, SIDE, DIAGONAL_POS, DIAGONAL_NEG}
	var shape: TileGeometry.Shape
	var axis: TileGeometry.Axis
	var data: Dictionary[String, int] = {}
	
	
	func _init(
			shape: TileGeometry.Shape,
			axis: TileGeometry.Axis
	):
		self.shape = shape
		self.axis = axis
	
	
	func add_constraint(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: TileGeometry.CellNeighbor,
			mode: TileGeometry.ConnectionMode,
			terrain_id: int
	) -> void:
		var key := _get_key(
				tilemap,
				cell,
				flag,
				mode
		)
		data[key] = terrain_id
	
	
	func has_constraint(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: TileGeometry.CellNeighbor,
			mode: TileGeometry.ConnectionMode
	) -> bool:
		var key := _get_key(
				tilemap,
				cell,
				flag,
				mode
		)
		return data.has(key)
	
	
	func get_constraint(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: TileGeometry.CellNeighbor,
			mode: TileGeometry.ConnectionMode
	) -> int:
		var key := _get_key(
				tilemap,
				cell,
				flag,
				mode
		)
		return data[key]
	
	
	func get_count() -> int:
		return data.size()
	
	
	func get_cell(index: int) -> Vector2i:
		var parts: PackedStringArray = data.keys()[index].split(":")
		return Vector2i(
				parts[0].to_int(),
				parts[1].to_int()
		)
	
	
	func get_flag(index: int) -> TileGeometry.CellNeighbor:
		var parts: PackedStringArray = data.keys()[index].split(":")
		return parts[2].to_int()
	
	
	func get_is_diagonal(index: int) -> bool:
		var parts: PackedStringArray = data.keys()[index].split(":")
		return parts[3] == "true"
	
	
	func _get_key(
			tilemap: AdvancedTileMapLayer,
			in_cell: Vector2i,
			in_flag: TileGeometry.CellNeighbor,
			mode: TileGeometry.ConnectionMode
	) -> String:
		var is_diagonal := mode & TileGeometry.ConnectionMode.DIAGONALS
		var constraint := _get_constraint_cell_and_flag(
				tilemap,
				in_cell,
				in_flag,
				is_diagonal
		)
		var key_cell: Vector2i = constraint[0]
		var key_flag: TileGeometry.CellNeighbor = constraint[1]
		return "%s:%s:%s:%s" % [key_cell.x, key_cell.y, key_flag, is_diagonal]


	func _get_constraint_cell_and_flag(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: int,
			is_diagonal: bool
	) -> Array:
		if flag & TileGeometry.CellNeighbor.SIDE:
			return _get_side_constraint_cell_and_flag(tilemap, cell, flag)
		elif is_diagonal:
			return _get_diagonal_constraint_cell_and_flag(tilemap, cell, flag)
		else:
			return _get_corner_constraint_cell_and_flag(tilemap, cell, flag)
	
	
	func _get_diagonal_constraint_cell_and_flag(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: TileGeometry.CellNeighbor
	) -> Array:
		var CN := TileGeometry.CellNeighbor
		if flag in [CN.TOP_LEFT_CORNER, CN.TOP_RIGHT_CORNER]:
			return [cell, flag]
		return [
				tilemap.advanced_get_neighbor_cell(cell, flag),
				TileGeometry.cell_neighbor_flip_h(
					TileGeometry.cell_neighbor_flip_v(flag)
				)
		]


	func _get_corner_constraint_cell_and_flag(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: int
	) -> Array:
		var CN := TileGeometry.CellNeighbor
		match tilemap.advanced_tile_set.advanced_shape:
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
						tilemap.advanced_get_neighbor_cell(
								cell,
								{
									CN.TOP_CORNER: CN.SELF,
									CN.RIGHT_CORNER: CN.BOTTOM_RIGHT_SIDE,
									CN.BOTTOM_CORNER: CN.BOTTOM_CORNER,
									CN.LEFT_CORNER: CN.BOTTOM_LEFT_SIDE,
								}[flag]
						),
						CN.TOP_CORNER,
				]
			TileGeometry.Shape.HALF_OFFSET_SQUARE, TileGeometry.Shape.HEXAGON:
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
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
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
					return_flag = TileGeometry.cell_neighbor_transpose(return_flag)
					neighbor_flag = TileGeometry.cell_neighbor_transpose(neighbor_flag)
				return [
						tilemap.advanced_get_neighbor_cell(cell, neighbor_flag),
						return_flag,
				]
			TileGeometry.Shape.TRIANGLE:
				var return_flag := CN.TOP_CORNER
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
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
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
					neighbor_flag = TileGeometry.cell_neighbor_transpose(neighbor_flag)
				return [
						tilemap.advanced_get_neighbor_cell(cell, neighbor_flag),
						return_flag,
				]
		assert(false, "Invalid tile shape")
		return [cell, flag]


	func _get_side_constraint_cell_and_flag(
			tilemap: AdvancedTileMapLayer,
			cell: Vector2i,
			flag: int
	) -> Array:
		var CN := TileGeometry.CellNeighbor
		match tilemap.advanced_tile_set.advanced_shape:
			TileGeometry.Shape.SQUARE, TileGeometry.Shape.TRIANGLE:
				var return_flag: TileGeometry.CellNeighbor
				var neighbor_flag: TileGeometry.CellNeighbor
				match flag:
					CN.TOP_SIDE, CN.LEFT_SIDE:
						return [cell, flag]
					CN.RIGHT_SIDE:
						return_flag = CN.LEFT_SIDE
						neighbor_flag = CN.RIGHT_SIDE
					CN.BOTTOM_SIDE:
						return_flag = CN.TOP_SIDE
						neighbor_flag = CN.BOTTOM_SIDE
				return [
						tilemap.advanced_get_neighbor_cell(cell, neighbor_flag),
						return_flag,
				]
			TileGeometry.Shape.ISOMETRIC:
				var return_flag: TileGeometry.CellNeighbor
				var neighbor_flag: TileGeometry.CellNeighbor
				match flag:
					CN.TOP_RIGHT_SIDE, CN.TOP_LEFT_SIDE:
						return [cell, flag]
					CN.BOTTOM_RIGHT_SIDE:
						return_flag = CN.TOP_LEFT_SIDE
						neighbor_flag = CN.BOTTOM_RIGHT_SIDE
					CN.BOTTOM_LEFT_SIDE:
						return_flag = CN.TOP_RIGHT_SIDE
						neighbor_flag = CN.BOTTOM_LEFT_SIDE
				return [
						tilemap.advanced_get_neighbor_cell(cell, neighbor_flag),
						return_flag,
				]
			TileGeometry.Shape.HALF_OFFSET_SQUARE, TileGeometry.Shape.HEXAGON:
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
					flag = TileGeometry.cell_neighbor_transpose(flag)
				var return_flag: TileGeometry.CellNeighbor
				var neighbor_flag: TileGeometry.CellNeighbor
				match flag:
					CN.TOP_LEFT_SIDE, CN.BOTTOM_LEFT_SIDE, CN.LEFT_SIDE:
						return_flag = flag
						neighbor_flag = CN.SELF
					_:
						return_flag = TileGeometry.cell_neighbor_flip_h(
								TileGeometry.cell_neighbor_flip_v(
									flag
								)
						)
						neighbor_flag = flag
				if tilemap.advanced_tile_set.advanced_axis == TileGeometry.Axis.VERTICAL:
					return_flag = TileGeometry.cell_neighbor_transpose(return_flag)
					neighbor_flag = TileGeometry.cell_neighbor_transpose(neighbor_flag)
				return [
						tilemap.advanced_get_neighbor_cell(cell, neighbor_flag),
						return_flag,
				]
		assert(false, "Invalid tile shape")
		return [cell, flag]
