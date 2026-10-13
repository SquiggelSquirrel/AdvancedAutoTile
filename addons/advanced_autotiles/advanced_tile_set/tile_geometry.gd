class_name TileGeometry
extends Object

const CENTER_FLAG_SHRINK := 0.6
## Reserved terrain_index values with special meaning
const FLAG_EMPTY := -1
const FLAG_IGNORE := -2
const _UP_TRIANGLE_NEIGHBOR_OFFSETS: Dictionary[TileGeometry.CellNeighbor, Vector2i] = {
	TileGeometry.CellNeighbor.TOP_COUNTERCLOCKWISE_CORNER:
		Vector2i(-1, -1),
	TileGeometry.CellNeighbor.TOP_CORNER:
		Vector2i(0, -1),
	TileGeometry.CellNeighbor.TOP_CLOCKWISE_CORNER:
		Vector2i(1, -1),
	TileGeometry.CellNeighbor.RIGHT_SIDE:
		Vector2i(1, 0),
	TileGeometry.CellNeighbor.BOTTOM_RIGHT_COUNTERCLOCKWISE_CORNER:
		Vector2i(2, 0),
	TileGeometry.CellNeighbor.BOTTOM_RIGHT_CORNER:
		Vector2i(2, 1),
	TileGeometry.CellNeighbor.BOTTOM_RIGHT_CLOCKWISE_CORNER:
		Vector2i(1, 1),
	TileGeometry.CellNeighbor.BOTTOM_SIDE:
		Vector2i(0, 1),
	TileGeometry.CellNeighbor.BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER:
		Vector2i(-1, 1),
	TileGeometry.CellNeighbor.BOTTOM_LEFT_CORNER:
		Vector2i(-2, 1),
	TileGeometry.CellNeighbor.BOTTOM_LEFT_CLOCKWISE_CORNER:
		Vector2i(-2, 0),
	TileGeometry.CellNeighbor.LEFT_SIDE:
		Vector2i(-1, 0),
}
static var _down_triangle_neighbor_offsets: Dictionary[TileGeometry.CellNeighbor, Vector2i] = {}
static var _left_triangle_neighbor_offsets: Dictionary[TileGeometry.CellNeighbor, Vector2i] = {}
static var _right_triangle_neighbor_offsets: Dictionary[TileGeometry.CellNeighbor, Vector2i] = {}
static var _triangle_offsets_setup := false
## Tile shapes suppored by advanced autotile plugin
enum Shape {
	SQUARE,
	ISOMETRIC,
	HALF_OFFSET_SQUARE,
	HEXAGON,
	TRIANGLE,
}
## Tile layouts supported by advanced autotile plugin
## (i.e. mapping from co-ordinates to position in grid)
## Some layouts only apply to some shapes, see [method get_tile_shape_layouts]
enum Layout {
	STACKED,
	STACKED_OFFSET,
	STAIRS_RIGHT,
	STAIRS_DOWN,
	DIAMOND_RIGHT,
	DIAMOND_DOWN,
}
## Tile layout axis (offset axis for hexagon or half-offset, orientations
## for triangle layouts) see [method get_tile_shape_axes]
enum Axis {
	HORIZONTAL, ## Horizontal half-offet, or triangles with a horizontal edge
	VERTICAL, ## Vertical half-offset, or triangles with a vertical edge
}
## Tile orientations (for triangle shapes only)
enum Orientation {
	UP, ## Bottom side and top corner
	DOWN, ## Top side and bottom corner
	LEFT, ## Right side and left corner
	RIGHT, ## Left side and right corner
}
## Terrain modes supported by Advanced Autotiles plugin depend on tile shape
## (see [method get_tile_shape_terrain_modes]). Diagonals-only mode is not
## supported for any shape, but is included for bitwise logic testing on the
## compound flags.
enum ConnectionMode {
	NONE = 0,
	CORNERS = 1,
	EDGES = 2,
	DIAGONALS = 4,
	CORNERS_AND_EDGES = 1 | 2,
	EDGES_AND_DIAGONALS = 2 | 4,
}
## Cell Neighbor flags, defined to support triangle layouts
## and bit-wise logic
enum CellNeighbor {
	SELF = 0,
	SIDE = 1,
	CORNER = 2,
	TOP = 4,
	RIGHT = 8,
	BOTTOM = 16,
	LEFT = 32,
	CLOCKWISE = 64,
	COUNTERCLOCKWISE = 128, # End of "core" flags
	TOP_SIDE = 1 | 4,
	RIGHT_SIDE = 1 | 8,
	BOTTOM_SIDE = 1 | 16,
	LEFT_SIDE = 1 | 32,
	TOP_RIGHT_SIDE = 1 | 4 | 8,
	BOTTOM_RIGHT_SIDE = 1 | 8 | 16,
	BOTTOM_LEFT_SIDE = 1 | 16 | 32,
	TOP_LEFT_SIDE = 1 | 32 | 4,
	TOP_CORNER = 2 | 4,
	RIGHT_CORNER = 2 | 8,
	BOTTOM_CORNER = 2 | 16,
	LEFT_CORNER = 2 | 32,
	TOP_RIGHT_CORNER = 2 | 4 | 8,
	BOTTOM_RIGHT_CORNER = 2 | 8 | 16,
	BOTTOM_LEFT_CORNER = 2 | 16 | 32,
	TOP_LEFT_CORNER = 2 | 32 | 4,
	TOP_CLOCKWISE_CORNER = 2 | 64 | 4,
	RIGHT_CLOCKWISE_CORNER = 2 | 64 | 8,
	BOTTOM_CLOCKWISE_CORNER = 2 | 64 | 16,
	LEFT_CLOCKWISE_CORNER = 2 | 64 | 32,
	TOP_RIGHT_CLOCKWISE_CORNER = 2 | 64 | 4 | 8,
	BOTTOM_RIGHT_CLOCKWISE_CORNER = 2 | 64 | 8 | 16,
	BOTTOM_LEFT_CLOCKWISE_CORNER = 2 | 64 | 16 | 32,
	TOP_LEFT_CLOCKWISE_CORNER = 2 | 64 | 32 | 4,
	TOP_COUNTERCLOCKWISE_CORNER = 2 | 128 | 4,
	RIGHT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 8,
	BOTTOM_COUNTERCLOCKWISE_CORNER = 2 | 128 | 16,
	LEFT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 32,
	TOP_RIGHT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 4 | 8,
	BOTTOM_RIGHT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 8 | 16,
	BOTTOM_LEFT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 16 | 32,
	TOP_LEFT_COUNTERCLOCKWISE_CORNER = 2 | 128 | 32 | 4,
}


#region static methods defining tile/grid settings which depend on each other
# (e.g. terrain modes avaliable for a given shape)


static func advanced_neighbor_to_base_neighbor(
	advanced_neighbor: CellNeighbor
) -> TileSet.CellNeighbor:
	var advanced_key: String = CellNeighbor.find_key(advanced_neighbor)
	var target_key: String = "CELL_NEIGHBOR_" + advanced_key
	var keys := ClassDB.class_get_enum_constants("TileSet", "CellNeighbor")
	# (This approach depends on base class cell neighbors having
	# consecutive values, starting from 0)
	for i in keys.size():
		if keys[i] == target_key:
			return i
	assert(false, "Could not find match for " + target_key)
	return -1


static func shape_has_diagonals(shape: Shape) -> bool:
	match shape:
		Shape.SQUARE, Shape.ISOMETRIC, Shape.TRIANGLE:
			return true
		_:
			assert(shape in [Shape.HEXAGON, Shape.HALF_OFFSET_SQUARE])
			return false


## Returns an array of connection modes supported for the given shape
static func get_connection_modes(shape: Shape) -> Array[ConnectionMode]:
	if shape in [Shape.SQUARE, Shape.ISOMETRIC]:
		return [
			ConnectionMode.NONE,
			ConnectionMode.CORNERS,
			ConnectionMode.EDGES,
			ConnectionMode.CORNERS_AND_EDGES,
			ConnectionMode.EDGES_AND_DIAGONALS
		]
	else:
		return [
			ConnectionMode.NONE,
			ConnectionMode.CORNERS,
			ConnectionMode.EDGES,
			ConnectionMode.CORNERS_AND_EDGES
		]


## Returns an array of orientations supported for the given shape and axis
static func get_orientations(
		shape: Shape,
		axis: Axis
) -> Array[TileGeometry.Orientation]:
	if shape != Shape.TRIANGLE:
		return [Orientation.UP]
	if axis == Axis.HORIZONTAL:
		return [Orientation.UP, Orientation.DOWN]
	else:
		return [Orientation.LEFT, Orientation.RIGHT]


## Returns an array of autotile mask flags supported for the given terrain mode,
## tile shape, axis, and orientation
static func get_flags(
		mode: ConnectionMode,
		shape: Shape,
		axis: Axis,
		orientation: TileGeometry.Orientation
) -> PackedInt32Array:
	var CN := CellNeighbor #Convenient shorthand for this enum
	if mode == ConnectionMode.NONE:
		return []
	var corners: PackedInt32Array
	var sides: PackedInt32Array
	match shape:
		Shape.SQUARE:
			for direction in [CN.TOP, CN.RIGHT, CN.BOTTOM, CN.LEFT]:
				sides.append(direction | CN.SIDE)
			for v in [CN.TOP, CN.BOTTOM]:
				for h in [CN.RIGHT, CN.LEFT]:
					corners.append(v | h | CN.CORNER)
		Shape.ISOMETRIC:
			for direction in [CN.TOP, CN.RIGHT, CN.BOTTOM, CN.LEFT]:
				corners.append(direction | CN.CORNER)
			for v in [CN.TOP, CN.BOTTOM]:
				for h in [CN.RIGHT, CN.LEFT]:
					sides.append(v | h | CN.SIDE)
		Shape.HALF_OFFSET_SQUARE, Shape.HEXAGON:
			if axis == Axis.HORIZONTAL:
				corners = [
					CN.TOP_LEFT_CORNER,
					CN.TOP_CORNER,
					CN.TOP_RIGHT_CORNER,
					CN.BOTTOM_RIGHT_CORNER,
					CN.BOTTOM_CORNER,
					CN.BOTTOM_LEFT_CORNER,
				]
				sides = [
					CN.LEFT_SIDE,
					CN.TOP_LEFT_SIDE,
					CN.TOP_RIGHT_SIDE,
					CN.RIGHT_SIDE,
					CN.BOTTOM_RIGHT_SIDE,
					CN.BOTTOM_LEFT_SIDE,
				]
			else:
				corners = [
					CN.LEFT_CORNER,
					CN.TOP_LEFT_CORNER,
					CN.TOP_RIGHT_CORNER,
					CN.RIGHT_CORNER,
					CN.BOTTOM_RIGHT_CORNER,
					CN.BOTTOM_LEFT_CORNER,
				]
				sides = [
					CN.TOP_LEFT_SIDE,
					CN.TOP_SIDE,
					CN.TOP_RIGHT_SIDE,
					CN.BOTTOM_RIGHT_SIDE,
					CN.BOTTOM_SIDE,
					CN.BOTTOM_LEFT_SIDE,
				]
		Shape.TRIANGLE:
			if axis == Axis.HORIZONTAL:
				if orientation == Orientation.UP:
					corners = [
						CN.TOP_CORNER,
						CN.BOTTOM_RIGHT_CORNER,
						CN.BOTTOM_LEFT_CORNER,
					]
					sides = [
						CN.RIGHT_SIDE,
						CN.BOTTOM_SIDE,
						CN.LEFT_SIDE,
					]
				else: # Orientation should be DOWN
					corners = [
						CN.TOP_RIGHT_CORNER,
						CN.BOTTOM_CORNER,
						CN.TOP_LEFT_CORNER,
					]
					sides = [
						CN.TOP_SIDE,
						CN.RIGHT_SIDE,
						CN.LEFT_SIDE,
					]
			else: # Axis should be VERTICAL
				if orientation == Orientation.RIGHT:
					corners = [
						CN.RIGHT_CORNER,
						CN.BOTTOM_LEFT_CORNER,
						CN.TOP_LEFT_CORNER,
					]
					sides = [
						CN.TOP_SIDE,
						CN.BOTTOM_SIDE,
						CN.LEFT_SIDE,
					]
				else: # orientation should be LEFT
					corners = [
						CN.TOP_RIGHT_CORNER,
						CN.BOTTOM_RIGHT_CORNER,
						CN.LEFT_CORNER,
					]
					sides = [
						CN.TOP_SIDE,
						CN.RIGHT_SIDE,
						CN.BOTTOM_SIDE,
					]
	match mode:
		ConnectionMode.CORNERS:
			return corners
		ConnectionMode.EDGES:
			return sides
		_:
			return corners + sides
#endregion


static func get_tile_outline_points(
		shape: Shape,
		axis: Axis,
		orientation: TileGeometry.Orientation
) -> Dictionary[CellNeighbor, Vector2]:
	# Get polygon for HORIZONTAL first, then transpose if VERTICAL.
	var points :Dictionary[CellNeighbor, Vector2] = {}
	match shape:
		Shape.HEXAGON:
			points = {
				CellNeighbor.TOP_CORNER: Vector2(0.5, 0.0),
				CellNeighbor.TOP_RIGHT_CORNER: Vector2(1.0, 0.25),
				CellNeighbor.BOTTOM_RIGHT_CORNER: Vector2(1.0, 0.75),
				CellNeighbor.BOTTOM_CORNER: Vector2(0.5, 1.0),
				CellNeighbor.BOTTOM_LEFT_CORNER: Vector2(0.0, 0.75),
				CellNeighbor.TOP_LEFT_CORNER: Vector2(0.0, 0.25),
			}
		Shape.HALF_OFFSET_SQUARE:
			# We don't *need* mid-points on the top and bottom edges for
			# every purpose, but it's useful for mask shape generation
			points = {
				CellNeighbor.TOP_LEFT_CORNER: Vector2(0.0, 0.0),
				CellNeighbor.TOP_CORNER: Vector2(0.5, 0.0),
				CellNeighbor.TOP_RIGHT_CORNER: Vector2(1.0, 0.0),
				CellNeighbor.BOTTOM_RIGHT_CORNER: Vector2(1.0, 1.0),
				CellNeighbor.BOTTOM_CORNER: Vector2(0.5, 1.0),
				CellNeighbor.BOTTOM_LEFT_CORNER: Vector2(0.0, 1.0),
			}
		Shape.ISOMETRIC:
			points = {
				CellNeighbor.TOP_CORNER: Vector2(0.5, 0.0),
				CellNeighbor.RIGHT_CORNER: Vector2(1.0, 0.5),
				CellNeighbor.BOTTOM_CORNER: Vector2(0.5, 1.0),
				CellNeighbor.LEFT_CORNER: Vector2(0.0, 0.5),
			}
		Shape.TRIANGLE:
			# Start by assuming axis is HORIZONTAL, orientation is UP
			# If axis is VERTICAL, polygon will be transposed, UP becomes LEFT
			# For DOWN or RIGHT, mirror the polygon vertically first
			points = {
				CellNeighbor.BOTTOM_LEFT_CORNER: Vector2(0.0, 1.0),
				CellNeighbor.TOP_CORNER: Vector2(0.5, 0.0),
				CellNeighbor.BOTTOM_RIGHT_CORNER: Vector2(1.0, 1.0),
			}
			if orientation in [
				Orientation.DOWN,
				Orientation.RIGHT,
			]:
				var mirrored_points: Dictionary[CellNeighbor, Vector2] = {}
				for flag in points.keys():
					mirrored_points[
							cell_neighbor_flip_v(flag)
							] = Vector2(points[flag].x, 1.0 - points[flag].y)
				points = mirrored_points
		_:
			assert(shape == Shape.SQUARE)
			points = {
				CellNeighbor.TOP_LEFT_CORNER: Vector2(0.0, 0.0),
				CellNeighbor.TOP_RIGHT_CORNER: Vector2(1.0, 0.0),
				CellNeighbor.BOTTOM_RIGHT_CORNER: Vector2(1.0, 1.0),
				CellNeighbor.BOTTOM_LEFT_CORNER: Vector2(0.0, 1.0),
			}
	
	# Transpose axes if VERTICAL.
	if axis == Axis.VERTICAL:
		var transposed_points: Dictionary[CellNeighbor, Vector2] = {}
		for flag in points.keys():
			transposed_points[
					cell_neighbor_transpose(flag)
					] = Vector2(points[flag].y, points[flag].x)
		points = transposed_points
	
	return points
	


## Get outline polygon for given tile shape, axis, and orientation
## For tile size(1.0, 1.0) - scale as needed.
## (n.b. half-offset squares get 6 points, to guarantee every polygon has
## (one point per corner flag. It just makes things easier.)
static func get_tile_polygon(
		shape: Shape,
		axis: Axis,
		orientation: TileGeometry.Orientation
) -> PackedVector2Array:
	return get_tile_outline_points(shape, axis, orientation).values()


static func _setup_triangle_offsets() -> void:
	for neighbor in _UP_TRIANGLE_NEIGHBOR_OFFSETS.keys():
		var offset: Vector2i = _UP_TRIANGLE_NEIGHBOR_OFFSETS[neighbor]
		_down_triangle_neighbor_offsets[
				TileGeometry.cell_neighbor_flip_v(neighbor)
				] = Vector2i(offset.x, - offset.y)
		_left_triangle_neighbor_offsets[
				TileGeometry.cell_neighbor_transpose(neighbor)
				] = Vector2i(offset.y, offset.x)
		_right_triangle_neighbor_offsets[
				TileGeometry.cell_neighbor_flip_h(
					TileGeometry.cell_neighbor_transpose(neighbor)
				)] = Vector2i(- offset.y, offset.x)
	_triangle_offsets_setup = true


static func cell_neighbor_flip_h(neighbor_in: CellNeighbor) -> CellNeighbor:
	var neighbor_out := neighbor_in & (
			CellNeighbor.SIDE
			| CellNeighbor.CORNER
			| CellNeighbor.TOP
			| CellNeighbor.BOTTOM
	)
	neighbor_out |= (
			((neighbor_in & CellNeighbor.RIGHT) << 2)
			| ((neighbor_in & CellNeighbor.LEFT) >> 2)
			| ((neighbor_in & CellNeighbor.CLOCKWISE) << 1)
			| ((neighbor_in & CellNeighbor.COUNTERCLOCKWISE) >> 1)
	)
	return neighbor_out


static func cell_neighbor_flip_v(neighbor_in: CellNeighbor) -> CellNeighbor:
	var neighbor_out := neighbor_in & (
			CellNeighbor.SIDE
			| CellNeighbor.CORNER
			| CellNeighbor.LEFT
			| CellNeighbor.RIGHT
	)
	neighbor_out |= (
			((neighbor_in & CellNeighbor.TOP) << 2)
			| ((neighbor_in & CellNeighbor.BOTTOM) >> 2)
			| ((neighbor_in & CellNeighbor.CLOCKWISE) << 1)
			| ((neighbor_in & CellNeighbor.COUNTERCLOCKWISE) >> 1)
	)
	return neighbor_out


static func cell_neighbor_transpose(neighbor_in: CellNeighbor) -> CellNeighbor:
	var neighbor_out := neighbor_in & (CellNeighbor.SIDE | CellNeighbor.CORNER)
	neighbor_out |= (
			( (neighbor_in & CellNeighbor.TOP) << 3 )
			|
			( (neighbor_in
				& (CellNeighbor.RIGHT | CellNeighbor.CLOCKWISE)
				) << 1 )
			|
			( (neighbor_in
				& (CellNeighbor.BOTTOM | CellNeighbor.COUNTERCLOCKWISE)
				) >> 1 )
			|
			( (neighbor_in & CellNeighbor.LEFT) >> 3 )
	)
	return neighbor_out


static func get_triangle_neighbor_cell(
		coords: Vector2i,
		neighbor: TileGeometry.CellNeighbor,
		orientation: TileGeometry.Orientation
) -> Vector2i:
	if ! _triangle_offsets_setup:
		_setup_triangle_offsets()
	var CN := TileGeometry.CellNeighbor
	var OR := TileGeometry.Orientation
	var offsets: Dictionary[TileGeometry.CellNeighbor, Vector2i]
	match orientation:
		OR.UP:
			offsets = _UP_TRIANGLE_NEIGHBOR_OFFSETS
		OR.DOWN:
			offsets = _down_triangle_neighbor_offsets
		OR.LEFT:
			offsets = _left_triangle_neighbor_offsets
		OR.RIGHT:
			offsets = _right_triangle_neighbor_offsets
	assert(
			offsets.has(neighbor),
			"Invalid neighbor flag from cell %s %s" % [coords, neighbor]
	)
	return coords + offsets[neighbor]


static func get_flag_polygons(
		shape: TileGeometry.Shape,
		axis: TileGeometry.Axis,
		mode: TileGeometry.ConnectionMode,
		orientation: TileGeometry.Orientation,
) -> Dictionary:
	var outline := TileGeometry.get_tile_polygon(
			shape, axis, orientation
	)
	var center_point := _points_average(outline)
	var polygons: Dictionary[TileGeometry.CellNeighbor, PackedVector2Array]
	polygons = {
		TileGeometry.CellNeighbor.SELF: _shrink_polygon(
				outline, center_point, CENTER_FLAG_SHRINK
		)
	}
	match mode:
		TileGeometry.ConnectionMode.NONE:
			pass
		TileGeometry.ConnectionMode.CORNERS:
			for i in outline.size():
				var point := outline[i]
				var previous := outline[i - 1]
				var next := outline[wrapi(i + 1, 0.0, outline.size())]
				var key := _point_to_corner(outline[i])
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
		TileGeometry.ConnectionMode.EDGES:
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
				var corner_key := _point_to_corner(outline[i])
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


# Return the flag of the side between the points
static func _side_between_points(
		point1 :Vector2, point2 :Vector2
) -> TileGeometry.CellNeighbor:
	var CN := TileGeometry.CellNeighbor
	var sum := point1 + point2
	var key := CN.SIDE
	
	if sum.y < 0.999:
		key |= CN.TOP
	elif sum.y > 1.001:
		key |= CN.BOTTOM
	
	if sum.x < 0.999:
		key |= CN.LEFT
	elif sum.x > 1.001:
		key |= CN.RIGHT
	
	return key


static func _point_to_corner(
		point: Vector2
) -> TileGeometry.CellNeighbor:
	var CN := TileGeometry.CellNeighbor
	var key := TileGeometry.CellNeighbor.CORNER
	if point.y < 0.4:
		key |= CN.TOP
	elif point.y > 0.6:
		key |= CN.BOTTOM
	if point.x > 0.6:
		key |= CN.RIGHT
	elif point.x < 0.4:
		key |= CN.LEFT
	return key


# Return the average point from an array of points
static func _points_average(points: PackedVector2Array) -> Vector2:
	var sum := Vector2.ZERO
	for point in points:
		sum += point
	return sum / points.size()


static func _shrink_polygon(
		polygon: PackedVector2Array, center: Vector2, ratio: float
) -> PackedVector2Array:
	var points := polygon.duplicate()
	for i in points.size():
		points[i] = points[i].lerp(center, ratio)
	return points
