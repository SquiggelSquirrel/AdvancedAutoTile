@tool
class_name AdvancedTileSet
extends TileSet

## Tile shapes suppored by advanced autotile plugin
enum AdvancedTileShape {
	SQUARE,
	ISOMETRIC,
	HALF_OFFSET_SQUARE,
	HEXAGON,
	TRIANGLE,
}
## Tile layouts supported by advanced autotile plugin
## (i.e. mapping from co-ordinates to position in grid)
## Some layouts only apply to some shapes, see [method get_tile_shape_layouts]
enum AdvancedTileLayout {
	STACKED,
	STACKED_OFFSET,
	STAIRS_RIGHT,
	STAIRS_DOWN,
	DIAMOND_RIGHT,
	DIAMOND_DOWN,
}
## Tile layout axis (offset axis for hexagon or half-offset, orientations
## for triangle layouts) see [method get_tile_shape_axes]
enum AdvancedTileLayoutAxis {
	HORIZONTAL,
	VERTICAL,
}
## Terrain modes supported by Advanced Autotiles plugin depend on tile shape
## (see [method get_tile_shape_terrain_modes]). Diagonals-only mode is not
## supported for any shape, but is included for bitwise logic testing on the
## compound flags.
enum AdvancedTerrainMode {
	NONE = 0,
	CORNERS = 1,
	EDGES = 2,
	DIAGONALS = 4,
	CORNERS_AND_EDGES = 3,
	EDGES_AND_DIAGONALS = 6,
}
## Cell Neighbor flags, defined to support triangle layouts
## and bit-wise logic
enum AdvancedCellNeighbor {
	SELF = 0,
	SIDE = 1,
	CORNER = 2,
	TOP = 4,
	RIGHT = 8,
	BOTTOM = 16,
	LEFT = 32,
	CLOCKWISE = 64,
	COUNTERCLOCKWISE = 128,
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
## Tile orientations (for triangle shapes only)
enum AdvancedTileOrientation {
	UP, ## Bottom side and top corner
	DOWN, ## Top side and bottom corner
	LEFT, ## Right side and left corner
	RIGHT, ## Left side and right corner
}

## Key used for storing per-tile plugin data on TileSet custom data layer
const DATA_LAYER_NAME := "Advanced Autotiles"
const FLAG_EMPTY := -1
const FLAG_IGNORE := -2

@export_group("Advanced Autotiles")
@export var advanced_tile_shape: AdvancedTileShape = AdvancedTileShape.SQUARE:
	set(value):
		if advanced_tile_shape == value:
			return
		advanced_tile_shape = value
		notify_property_list_changed()
		changed.emit()
@export var advanced_tile_layout: AdvancedTileLayout = AdvancedTileLayout.STACKED:
	set(value):
		if advanced_tile_layout == value:
			return
		advanced_tile_layout = value
		emit_changed()
@export var advanced_tile_layout_axis: AdvancedTileLayoutAxis = AdvancedTileLayoutAxis.HORIZONTAL:
	set(value):
		if advanced_tile_layout_axis == value:
			return
		advanced_tile_layout_axis = value
		emit_changed()
@export var advanced_terrains_auto_priorities := false:
	set(value):
		advanced_terrains_auto_priorities = value
		notify_property_list_changed()
@export var advanced_empty_flag_auto_bindings := true
@export var advanced_empty_flag_bindings: int = 0
@export_storage var _advanced_empty_flag_bindings_need_update := true
@export_storage var _advanced_auto_priorities_need_update := true
@export_storage var _bindings: PackedInt32Array = []
@export_storage var _priorities: PackedInt32Array = []
var _terrains: Array[Terrain] = []


#region static methods defining tile/grid settings which depend on each other
# (e.g. terrain modes avaliable for a given shape)

## Returns an array of autotile terrain modes supported for the given tile shape
static func get_tile_shape_terrain_modes(
		shape: AdvancedTileShape,
) -> Array[AdvancedTerrainMode]:
	if shape in [AdvancedTileShape.SQUARE, AdvancedTileShape.ISOMETRIC]:
		return [
			AdvancedTerrainMode.NONE,
			AdvancedTerrainMode.CORNERS,
			AdvancedTerrainMode.EDGES,
			AdvancedTerrainMode.CORNERS_AND_EDGES,
			AdvancedTerrainMode.EDGES_AND_DIAGONALS
		]
	else:
		return [
			AdvancedTerrainMode.NONE,
			AdvancedTerrainMode.CORNERS,
			AdvancedTerrainMode.EDGES,
			AdvancedTerrainMode.CORNERS_AND_EDGES
		]


## Returns an array of orientations supported for the given tile shape and
## layout axis
static func get_tile_orientations_for_shape_and_axis(
		shape: AdvancedTileShape,
		axis: AdvancedTileLayoutAxis
) -> Array[AdvancedTileOrientation]:
	if shape != AdvancedTileShape.TRIANGLE:
		return [AdvancedTileOrientation.UP]
	if axis == AdvancedTileLayoutAxis.HORIZONTAL:
		return [AdvancedTileOrientation.UP, AdvancedTileOrientation.DOWN]
	else:
		return [AdvancedTileOrientation.LEFT, AdvancedTileOrientation.RIGHT]


## Returns an array of autotile mask flags supported for the given terrain mode,
## tile shape, axis, and orientation
static func get_advanced_terrain_mask_flags(
		mode: AdvancedTerrainMode,
		shape: AdvancedTileShape,
		axis: AdvancedTileLayoutAxis,
		orientation: AdvancedTileOrientation
) -> PackedInt32Array:
	var CN := AdvancedCellNeighbor #Convenient shorthand for this enum
	if mode == AdvancedTerrainMode.NONE:
		return []
	var corners: PackedInt32Array
	var sides: PackedInt32Array
	match shape:
		AdvancedTileShape.SQUARE:
			for direction in [CN.TOP, CN.RIGHT, CN.BOTTOM, CN.LEFT]:
				sides.append(direction | CN.SIDE)
			for v in [CN.TOP, CN.BOTTOM]:
				for h in [CN.RIGHT, CN.LEFT]:
					corners.append(v | h | CN.CORNER)
		AdvancedTileShape.ISOMETRIC:
			for direction in [CN.TOP, CN.RIGHT, CN.BOTTOM, CN.LEFT]:
				corners.append(direction | CN.CORNER)
			for v in [CN.TOP, CN.BOTTOM]:
				for h in [CN.RIGHT, CN.LEFT]:
					sides.append(v | h | CN.SIDE)
		AdvancedTileShape.HALF_OFFSET_SQUARE, AdvancedTileShape.HEXAGON:
			if axis == AdvancedTileLayoutAxis.HORIZONTAL:
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
		AdvancedTileShape.TRIANGLE:
			if axis == AdvancedTileLayoutAxis.HORIZONTAL:
				if orientation == AdvancedTileOrientation.UP:
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
				if orientation == AdvancedTileOrientation.RIGHT:
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
		AdvancedTerrainMode.CORNERS:
			return corners
		AdvancedTerrainMode.EDGES:
			return sides
		_:
			return corners + sides


static func terrain_mode_has_edge_flags(mode: AdvancedTerrainMode) -> bool:
	return mode in [
			AdvancedTerrainMode.EDGES,
			AdvancedTerrainMode.CORNERS_AND_EDGES,
			AdvancedTerrainMode.EDGES_AND_DIAGONALS]


static func terrain_mode_has_corner_flags(mode: AdvancedTerrainMode) -> bool:
	return mode in [
			AdvancedTerrainMode.CORNERS,
			AdvancedTerrainMode.CORNERS_AND_EDGES,
			AdvancedTerrainMode.EDGES_AND_DIAGONALS]
#endregion


## Get outline polygon for given tile shape, axis, and orientation
## For tile size(1.0, 1.0) - scale as needed.
## (n.b. half-offset squares get 6 points, to guarantee every polygon has
## (one point per corner flag. It just makes things easier.)
static func get_advanced_tile_shape_polygon(
		shape: AdvancedTileShape,
		axis: AdvancedTileLayoutAxis,
		orientation: AdvancedTileOrientation
) -> PackedVector2Array:
	# Get polygon for HORIZONTAL first, then transpose if VERTICAL.
	var polygon: PackedVector2Array
	match shape:
		AdvancedTileShape.HEXAGON:
			polygon = [
				Vector2(0.5, 0.0),
				Vector2(1.0, 0.25),
				Vector2(1.0, 0.75),
				Vector2(0.5, 1.0),
				Vector2(0.0, 0.75),
				Vector2(0.0, 0.25),
			]
		AdvancedTileShape.HALF_OFFSET_SQUARE:
			# We don't *need* mid-points on the top and bottom edges for
			# every purpose, but it's useful for mask shape generation
			polygon = [
				Vector2(0.0, 0.0),
				Vector2(0.5, 0.0),
				Vector2(1.0, 0.0),
				Vector2(1.0, 1.0),
				Vector2(0.5, 1.0),
				Vector2(0.0, 1.0),
			]
		AdvancedTileShape.ISOMETRIC:
			polygon = [
					Vector2(0.5, 0.0),
					Vector2(1.0, 0.5),
					Vector2(0.5, 1.0),
					Vector2(0.0, 0.5)]
		AdvancedTileShape.TRIANGLE:
			# Start by assuming axis is HORIZONTAL, orientation is UP
			# If axis is VERTICAL, polygon will be transposed, UP becomes LEFT
			# For DOWN or RIGHT, mirror the polygon vertically first
			polygon = [
				Vector2(0.0, 1.0),
				Vector2(0.5, 0.0),
				Vector2(1.0, 1.0),
			]
			if orientation in [
				AdvancedTileOrientation.DOWN,
				AdvancedTileOrientation.RIGHT,
			]:
				for i in polygon.size():
					polygon[i] = Vector2(polygon[i].x, 1.0 - polygon[i].y)
		_:
			assert(shape == AdvancedTileShape.SQUARE)
			polygon = [
					Vector2(0.0, 0.0),
					Vector2(1.0, 0.0),
					Vector2(1.0, 1.0),
					Vector2(0.0, 1.0)]
	
	# Transpose axes if VERTICAL.
	if axis == AdvancedTileLayoutAxis.VERTICAL:
		for i in polygon.size():
			polygon[i] = Vector2(polygon[i].y, polygon[i].x)
	
	return polygon


#region property list and getter/setter built-in methods
func _get_property_list() -> Array[Dictionary]:
#	var properties: Array[Dictionary] = [
#		_property_dictionary_advanced_tile_layout(),
#		_property_dictionary_advanced_layout_axis(),
#	]
	var properties: Array[Dictionary] = []
	properties.append({
		"name": "advanced_terrain_count",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_ARRAY | PROPERTY_USAGE_DEFAULT,
		"class_name": "Terrains,advanced_terrain_,static",
		"hint": PROPERTY_HINT_NONE,
	})
	for i in _terrains.size():
		properties.append_array([
			{
				"name": "advanced_terrain_%d/name" % i,
				"type": TYPE_STRING,
			}, {
				"name": "advanced_terrain_%d/color" % i,
				"type": TYPE_COLOR,
			}, {
				"name": "advanced_terrain_%d/mode" % i,
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": _get_mode_hint_string(),
			}, {
				"name": "advanced_terrain_%d/auto_binding" % i,
				"type": TYPE_BOOL,
			}])
		properties.append({
			"name": "advanced_terrain_%d/bindings" % i,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": _get_bindings_hint_string(),
			"usage": (
					PROPERTY_USAGE_STORAGE
					if _terrains[i].auto_binding
					else PROPERTY_USAGE_DEFAULT
			),
		})
		properties.append({
			"name": "advanced_terrain_%d/priority" % i,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0, 100, or_greater",
			"usage": (
				PROPERTY_USAGE_STORAGE
				if advanced_terrains_auto_priorities
				else PROPERTY_USAGE_EDITOR
			),
		})
	return properties


func _validate_property(property: Dictionary) -> void:
	match property:
		"advanced_tile_layout", "advanced_tile_layout_axis":
			if advanced_tile_shape == AdvancedTileShape.SQUARE:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"advanced_empty_flag_bindings":
			if advanced_empty_flag_auto_bindings or _terrains.size() == 0:
				property.usage = PROPERTY_USAGE_STORAGE
			else:
				property.hint = PROPERTY_HINT_FLAGS
				property.hint_string = _get_bindings_hint_string(false)


func _set(property: StringName, value: Variant) -> bool:
	if property == "advanced_terrain_count":
		_terrains.resize(value)
		for i in _terrains.size():
			if not _terrains[i] is Terrain:
				var color := Color.INDIAN_RED
				color.h = wrapf(i * 0.05, 0.0, 1.0)
				_terrains[i] = Terrain.new(
						"Terrain %s" % i,
						color)
		notify_property_list_changed()
		changed.emit()
		return true
	elif property.begins_with("advanced_terrain_"):
		var parts: PackedStringArray = property.trim_prefix(
				"advanced_terrain_").split("/")
		var i := parts[0].to_int()
		_terrains[i].set(parts[1], value)
		# Bit of a hack - should this be a list of specific
		# properties that require a property list refresh,
		# rather than just "anything boolean"?
		# (It *is* just all the booleans right now though.)
		if value is bool:
			notify_property_list_changed()
		changed.emit()
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == "advanced_terrain_count":
		return _terrains.size()
	elif property.begins_with("advanced_terrain_"):
		var parts: PackedStringArray = property.trim_prefix(
				"advanced_terrain_").split("/")
		var i := parts[0].to_int()
		return _terrains[i].get(parts[1])
	return null
#endregion


## Set the orientation of a tile
func set_advanced_tile_orientation(
	tile: TileKey, orientation: AdvancedTileOrientation
) -> void:
	_set_advanced_tile_data(tile, "orientation", orientation)
	_set_advanced_tile_data(tile, "mask", {})


## Get the orientation of a tile
func get_advanced_tile_orientation(tile: TileKey) -> AdvancedTileOrientation:
	var orientation := _get_advanced_tile_data(
			tile, "orientation", AdvancedTileOrientation.UP)
	var allowed := get_tile_orientations_for_shape_and_axis(
			advanced_tile_shape, advanced_tile_layout_axis
	)
	if orientation in allowed:
		return orientation
	return allowed[0]


## Set the terrain index of a tile
func set_advanced_tile_terrain_index(tile: TileKey, terrain_index: int) -> void:
	if terrain_index == _get_advanced_tile_data(tile, "terrain_index", -1):
		return
	_set_advanced_tile_data(tile, "terrain_index", terrain_index)
	var orientation := get_advanced_tile_orientation(tile)
	var default_mask := {}
	if terrain_index > -1:
		var terrain := _terrains[terrain_index]
		for flag in get_advanced_terrain_mask_flags(
				terrain.mode,
				advanced_tile_shape,
				advanced_tile_layout_axis,
				orientation
		):
			default_mask[flag] = -1
	_set_advanced_tile_data(tile, "mask", default_mask)
	if advanced_empty_flag_auto_bindings:
		_advanced_empty_flag_bindings_need_update = true
	if advanced_terrains_auto_priorities:
		_advanced_auto_priorities_need_update


## Get the terrain index of a tile
func get_advanced_tile_terrain_index(tile: TileKey) -> int:
	var stored := _get_advanced_tile_data(tile, "terrain_index", -1)
	if stored <= _terrains.size():
		return stored
	return -1


## Set a flag of the "Advanced Autotiles" mask of a tile
func set_advanced_tile_flag(
		tile: TileKey, flag: AdvancedCellNeighbor, flag_value: int
) -> void:
	var terrain_index := get_advanced_tile_terrain_index(tile)
	var mask := get_advanced_tile_mask(tile)
	var old_value: int = mask[flag]
	if flag_value == old_value:
		return
	mask[flag] = flag_value
	_set_advanced_tile_data(tile, "mask", mask)
	# Expire cached values as needed
	var some_bindings_need_update := false
	for affected in [old_value, flag_value]:
		match affected:
			-2:
				# Do nothing (ignore flags don't affect bindings or priorities)
				pass
			-1:
				if advanced_empty_flag_auto_bindings:
					_advanced_empty_flag_bindings_need_update = true
				some_bindings_need_update = true
			_:
				if _terrains[affected].auto_binding:
					_terrains[affected].bindings_need_update = true
				some_bindings_need_update = true
	if some_bindings_need_update and advanced_terrains_auto_priorities:
		_advanced_auto_priorities_need_update = true


## Get the autotile mask of a tile
func get_advanced_tile_mask(tile: TileKey) -> Dictionary:
	var stored_mask := _get_advanced_tile_data(tile, "mask", {})
	var terrain_index := get_advanced_tile_terrain_index(tile)
	if terrain_index == -1:
		return {}
	var terrain := _terrains[terrain_index]
	var orientation := get_advanced_tile_orientation(tile)
	var return_mask := {}
	for flag in get_advanced_terrain_mask_flags(
			terrain.mode,
			advanced_tile_shape,
			advanced_tile_layout_axis,
			orientation,
	):
		return_mask[flag] = stored_mask.get(flag, -1)
	return return_mask


## Returns an array of tile keys in all the atlas sources of this tile set.
func get_advanced_tiles() -> Array[TileKey]:
	var tiles: Array[TileKey] = []
	for source_index in get_source_count():
		var id := get_source_id(source_index)
		var source := get_source(id)
		if source is TileSetAtlasSource:
			var size: Vector2 = source.get_atlas_grid_size()
			for x in size:
				for y in size:
					var coords := Vector2(x, y)
					if source.get_tile_size_in_atlas(coords) != coords:
						continue
					for alternative_id in source.get_alternative_tiles_count(coords):
						tiles.append(TileKey.new(
								id, coords, alternative_id
						))
	return tiles


func get_advanced_terrain_name(terrain_index: int) -> String:
	return _terrains[terrain_index].name


func get_advanced_terrain_color(terrain_index: int) -> Color:
	return _terrains[terrain_index].color


func get_advanced_terrain_mode(terrain_index: int) -> AdvancedTerrainMode:
	return _terrains[terrain_index].mode


func get_advanced_terrain_auto_binding(terrain_index: int) -> bool:
	return _terrains[terrain_index].auto_binding


func get_advanced_terrain_binds_to(terrain_index: int, other_index: int) -> bool:
	if _terrains[terrain_index].bindings_need_update:
		_advanced_terrain_update_auto_bindings()
	return _binding_get_terrain_index(
			_terrains[terrain_index].bindings, other_index
	)


func get_advanced_terrain_priority(terrain_index: int) -> int:
	if terrain_index == FLAG_IGNORE:
		return 0
	if _advanced_auto_priorities_need_update:
		_advanced_terrain_update_priorities()
	return _priorities[terrain_index]


func _advanced_terrain_update_priorities() -> void:
	#TODO - lookup algorith for strongly linked groups
	#TODO - does Godot have a built-in data model for DAGs?
	pass


func get_advanced_terrain_auto_priority(terrain_index: int) -> bool:
	return _terrains[terrain_index].auto_priority


# Set any per-tile data used by the AdvancedTileSet plugin
func _set_advanced_tile_data(
		tile: TileKey, key: String, value: Variant) -> void:
	var layer_index: int = get_custom_data_layer_by_name(DATA_LAYER_NAME)
	if layer_index == -1:
		add_custom_data_layer()
		layer_index = get_custom_data_layers_count() - 1
		set_custom_data_layer_name(layer_index, DATA_LAYER_NAME)
		set_custom_data_layer_type(layer_index, TYPE_DICTIONARY)
	var tile_data := (
			get_source(tile.source_id) as TileSetAtlasSource
			).get_tile_data(tile.coords, tile.alternative_id)
	var data: Dictionary = tile_data.get_custom_data(DATA_LAYER_NAME)
	data[key] = value


# Retrieve any per-tile data used by the AdvancedTileSet plugin,
# requires a default value
func _get_advanced_tile_data(
		tile: TileKey, key: String, default: Variant) -> Variant:
	var layer_index: int = get_custom_data_layer_by_name(DATA_LAYER_NAME)
	if layer_index == -1:
		add_custom_data_layer()
		layer_index = get_custom_data_layers_count() - 1
		set_custom_data_layer_name(layer_index, DATA_LAYER_NAME)
		set_custom_data_layer_type(layer_index, TYPE_DICTIONARY)
	var data := (
			get_source(tile.source_id) as TileSetAtlasSource
			).get_tile_data(tile.coords, tile.alternative_id)
	return data.get_custom_data(DATA_LAYER_NAME).get(key, default)


#region private methods used by _get_property_list
# For use in _get_property_list. Hint string for manual terrain bindings
func _get_bindings_hint_string(include_empty := true) -> String:
	var names: PackedStringArray = []
	if include_empty:
		var name := "Empty"
		var mask := _binding_get_terrain_mask(-1)
		var hint := "%s:%d" % [name, mask]
		names.append(hint)
	for terrain_index in _terrains.size():
		var name := _terrains[terrain_index].name
		var mask := _binding_get_terrain_mask(terrain_index)
		var hint := "%s:%d" % [name, mask]
		names.append(hint)
	return ",".join(names)


func _advanced_terrain_update_auto_bindings() -> void:
	for tile in get_advanced_tiles():
		var center_index := get_advanced_tile_terrain_index(tile)
		if center_index < 0:
			continue
		var mask := get_advanced_tile_mask(tile)
		for flag in mask:
			var flag_index: int = mask[flag]
			if flag_index < 0:
				continue
			var flag_terrain := _terrains[flag_index]
			if ! flag_terrain.bindings_need_update:
				continue
			flag_terrain.bindings = _binding_set_terrain_index(
					flag_index,
					center_index,
					true,
			)


# For use in _get_property_list. Hint string for terrain modes
func _get_mode_hint_string() -> String:
	get_tile_shape_terrain_modes(advanced_tile_shape)
	var hint_strings: PackedStringArray = []
	for key: String in AdvancedTerrainMode.keys():
		hint_strings.append(
			"%s:%s" % [key.capitalize(), AdvancedTerrainMode[key]])
	return ",".join(hint_strings)
#endregion


static func _binding_set_terrain_index(
		binding: int, terrain_index: int, value: bool
) -> int:
	var mask := _binding_get_terrain_mask(terrain_index)
	if value:
		return binding | mask
	else:
		return binding & ~ mask


static func _binding_get_terrain_index(binding: int, terrain_index: int) -> bool:
	var mask := _binding_get_terrain_mask(terrain_index)
	return (binding & mask == mask)


static func _binding_get_terrain_mask(terrain_index: int) -> int:
	return 1 << (terrain_index + 1)


## Class TileKey contains all fields needed to identify a Tile in a TileSet
class TileKey:
	var source_id: int
	var coords: Vector2i
	var alternative_id: int
	
	func _init(source_id: int, coords: Vector2i, alternative_id: int):
		self.source_id = source_id
		self.coords = coords
		self.alternative_id = alternative_id
	
	
	func equals(other_tile: TileKey) -> bool:
		if other_tile == null:
			return false
		return (
				source_id == other_tile.source_id
				and coords == other_tile.coords
				and alternative_id == other_tile.alternative_id
		)


## Class for storing a single terrain.
class Terrain:
	var name := ""
	var color := Color.INDIAN_RED
	var mode: AdvancedTileSet.AdvancedTerrainMode
	var auto_binding := true
	var bindings: int = 0 #(bitmask)
	var bindings_need_update := true
	var priority: int = 0
	
	
	func _init(init_name: String, init_color: Color) -> void:
		name = init_name
		color = init_color
