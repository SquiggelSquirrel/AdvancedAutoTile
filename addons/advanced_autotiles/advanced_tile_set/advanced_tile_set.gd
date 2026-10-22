@tool
class_name AdvancedTileSet
extends TileSet

## Key used for storing per-tile plugin data on TileSet custom data layer
const DATA_LAYER_NAME := "_advanced_autotiles"

## If enabled, properties of the base [class TileSet] will not show in the
## editor if intended to be replaced by Advanced Autotiles properties.
## (Note that this only affects the inspector and not the underlying API)
@export var hide_base_class_features := true:
	set(value):
		hide_base_class_features = value
		notify_property_list_changed()
@export_group("Grid properties", "advanced_")
## The tile shape used by the Advanced Autotiles plugin.
## In most cases, this is the same as the base [member tile_shape],
## but triangles are supported (and will use square shape on the base class)
@export var advanced_shape := TileGeometry.Shape.SQUARE:
	set(value):
		if advanced_shape == value:
			return
		advanced_shape = value
		if _is_loaded:
			for tile in get_advanced_tiles():
				if get_advanced_terrain(tile) > -1:
					clear_advanced_mask(tile)
			_apply_base_overrides()
			_need_recalc = true
			notify_property_list_changed()
			changed.emit()
## The tile layout used by the Advanced Autotiles plugin.
## Currently just a mirror of the base [member tile_layout]
@export var advanced_layout := TileGeometry.Layout.STACKED:
	set(value):
		if advanced_layout == value:
			return
		advanced_layout = value
		if _is_loaded:
			_apply_base_overrides()
			changed.emit()
## For half-offset shapes (isometric, hexagonal, half-offset square),
## determines the offset axis. For triangles, determines the allowed
## orientations
@export var advanced_axis := TileGeometry.Axis.HORIZONTAL:
	set(value):
		if advanced_axis == value:
			return
		advanced_axis = value
		if _is_loaded:
			for tile in get_advanced_tiles():
				if get_advanced_terrain(tile) > -1:
					clear_advanced_mask(tile)
			advanced_tile_size = advanced_tile_size
			_apply_base_overrides()
			changed.emit()
## The size, in pixels, of the minumum rectangle that fully encompasses
## one cell. Triangles must have even width if horizontal, or height if vertical
## (due to implementation limitations).
@export var advanced_tile_size := Vector2i(16, 16):
	set(value):
		if advanced_shape == TileGeometry.Shape.TRIANGLE:
			if advanced_axis == TileGeometry.Axis.HORIZONTAL:
				if value.x > advanced_tile_size.x:
					value.x = 2 * ceili(value.x * 0.5)
				else:
					value.x = 2 * floori(value.x * 0.5)
			else:
				if value.y > advanced_tile_size.y:
					value.y = 2 * ceil(value.y * 0.5)
				else:
					value.y = 2 * floori(value.y * 0.5)
		advanced_tile_size = value
		if _is_loaded:
			_apply_base_overrides()
			changed.emit()

@export_group("Autotiling")
@export var auto_priorities := false:
	set(value):
		if value == auto_priorities:
			return
		if value:
			_need_recalc = true
		elif _need_recalc:
			_recalc()
		auto_priorities = value
		notify_property_list_changed()
@export_subgroup("Empty tile", "empty_terrain_")
@export var empty_terrain_auto_bindings := true:
	set(value):
		if value and not empty_terrain_auto_bindings:
			_need_recalc = true
		empty_terrain_auto_bindings = value
		notify_property_list_changed()
@export var empty_terrain_bindings: int = 0
@export var empty_terrain_priority := 0
@export_storage var _tile_match_priority_bonus := 0
@export_storage var _need_recalc := true
var _is_loaded := false
var _terrains: Array[Terrain] = []


#region Editor/Inspector logic
func _init() -> void:
	_set_is_loaded.call_deferred()


func _set_is_loaded() -> void:
	_is_loaded = true


func _get_property_list() -> Array[Dictionary]:
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
				"hint_string": _get_enum_hint_string(
						TileGeometry.ConnectionMode,
						TileGeometry.get_connection_modes(advanced_shape)
				),
			}, {
				"name": "advanced_terrain_%d/priority" % i,
				"type": TYPE_INT,
				"usage": (
						PROPERTY_USAGE_STORAGE if auto_priorities
						else PROPERTY_USAGE_DEFAULT
				),
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
					PROPERTY_USAGE_STORAGE if _terrains[i].auto_binding
					else PROPERTY_USAGE_DEFAULT
			),
		})
	return properties


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"advanced_layout", "advanced_axis":
			if advanced_shape == TileGeometry.Shape.SQUARE:
				property.usage |= PROPERTY_USAGE_READ_ONLY
		"empty_terrain_auto_bindings":
			if _terrains.size() == 0:
				property.usage = PROPERTY_USAGE_STORAGE
		"empty_terrain_bindings":
			if empty_terrain_auto_bindings or _terrains.size() == 0:
				property.usage = PROPERTY_USAGE_STORAGE
			else:
				property.hint = PROPERTY_HINT_FLAGS
				property.hint_string = _get_bindings_hint_string()
		"tile_shape", "tile_layout", "tile_offset_axis", "tile_size", "terrain_sets":
			if hide_base_class_features:
				property.usage &= ~ PROPERTY_USAGE_EDITOR


func _set(property: StringName, value: Variant) -> bool:
	if property == "advanced_terrain_count":
		if value < _terrains.size():
			_need_recalc = true
		_terrains.resize(value)
		for i in _terrains.size():
			if not _terrains[i] is Terrain:
				var color := Color.INDIAN_RED
				color.h = wrapf(i * 0.05, 0.0, 1.0)
				_terrains[i] = Terrain.new(
						"Terrain %s" % i,
						color)
		for tile in get_advanced_tiles():
			if get_advanced_terrain(tile) >= value:
				# This tile was using a now-removed terrain,
				# set its terrain to empty
				set_advanced_terrain(tile, -1)
				
			elif get_advanced_terrain(tile) > -1:
				# This tile's terrain still exists, but it may have a mask
				# that uses a now-removed terrain. If so, clear the mask.
				for flag in get_advanced_mask(tile).values():
					if flag >= value:
						clear_advanced_mask(tile)
						break
		notify_property_list_changed()
		if _is_loaded:
			changed.emit()
		return true
	elif property.begins_with("advanced_terrain_"):
		var parts: PackedStringArray = property.trim_prefix(
				"advanced_terrain_").split("/")
		var terrain_index := parts[0].to_int()
		var terrain_property := parts[1]
		if _terrains[terrain_index].get(terrain_property) == value:
			return true
		if _is_loaded:
			match terrain_property:
				"mode":
					for tile in get_advanced_tiles():
						if get_advanced_terrain(tile) == terrain_index:
							clear_advanced_mask(tile)
							_need_recalc = true
				"auto_binding":
					# If we are enabling manual bindings,
					# Apply automatic bindings before switching
					if _need_recalc and ! value:
						_recalc()
					elif value:
						_need_recalc = true
					notify_property_list_changed()
				"bindings":
					# (Only priorities really need recalc, should cache be
					# more granular?)
					_recalc()
		_terrains[terrain_index].set(terrain_property, value)
		if _is_loaded:
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


func _get_enum_hint_string(
		enum_dict: Dictionary,
		values: PackedInt32Array = []
) -> String:
	var hint_strings: PackedStringArray = []
	if values.is_empty():
		for key: String in enum_dict.keys():
			hint_strings.append(
				"%s:%s" % [key.capitalize(), enum_dict[key]])
	else:
		for value in values:
			hint_strings.append(
				"%s:%s" % [
					enum_dict.find_key(value).capitalize(),
					value
				]
			)
	return ",".join(hint_strings)
#endregion


## Set the orientation of a tile
func set_advanced_orientation(
	tile: TileKey, orientation: TileGeometry.Orientation
) -> void:
	var allowed := TileGeometry.get_orientations(
			advanced_shape, advanced_axis
	)
	assert(orientation in allowed,
			"Tile orientation not supported by tile set shape+axis")
	_set_advanced_tile_data(tile, "orientation", orientation)
	if get_advanced_terrain(tile) > -1:
		clear_advanced_mask(tile)
	_need_recalc = true


## Get the orientation of a tile
func get_advanced_orientation(tile: TileKey) -> TileGeometry.Orientation:
	var orientation := _get_advanced_tile_data(tile, "orientation", -1)
	if orientation == -1:
		return TileGeometry.get_orientations(advanced_shape, advanced_axis)[0]
	return orientation


## Set the terrain index of a tile
func set_advanced_terrain(tile: TileKey, terrain_index: int) -> void:
	assert(terrain_index < _terrains.size(),
			"Terrain index outside size of tile set terrains")
	assert(terrain_index >= -1,
			"Negative terrain index only allowed for -1 (No terrain)")
	_set_advanced_tile_data(tile, "terrain_index", terrain_index)
	if terrain_index == -1:
		_clear_advanced_tile_data(tile, "mask")
	else:
		clear_advanced_mask(tile)
	_need_recalc = true


## Get the terrain index of a tile
func get_advanced_terrain(tile: TileKey) -> int:
	return _get_advanced_tile_data(tile, "terrain_index", -1)


## Set a flag of the "Advanced Autotiles" mask of a tile
func set_advanced_flag(
		tile: TileKey, flag: TileGeometry.CellNeighbor, flag_value: int
) -> void:
	var terrain_index: int = get_advanced_terrain(tile)
	assert(terrain_index > -1,
			"Cannot set autotile flag on tile without terrain")
	var expected_flags := TileGeometry.get_flags(
			_terrains[terrain_index].mode,
			advanced_shape,
			advanced_axis,
			get_advanced_orientation(tile)
	)
	assert(flag in expected_flags, "Unsupported autotile flag for this tile")
	var mask := get_advanced_mask(tile)
	mask[flag] = flag_value
	for expected_flag in expected_flags:
		if ! mask.has(expected_flag):
			mask[expected_flag] = TileGeometry.FLAG_EMPTY
	_set_advanced_tile_data(tile, "mask", mask)
	_need_recalc = true


func clear_advanced_mask(tile: TileKey) -> void:
	var terrain_index: int = get_advanced_terrain(tile)
	assert(terrain_index > -1,
			"Cannot set autotile mask on tile without terrain")
	var flags := TileGeometry.get_flags(
			_terrains[terrain_index].mode,
			advanced_shape,
			advanced_axis,
			get_advanced_orientation(tile)
	)
	var mask := {}
	for flag in flags:
		mask[flag] = TileGeometry.FLAG_EMPTY
	_set_advanced_tile_data(tile, "mask", mask)


## Get the autotile mask of a tile
func get_advanced_mask(tile: TileKey) -> Dictionary:
	var terrain_index: int = get_advanced_terrain(tile)
	var orientation: TileGeometry.Orientation = get_advanced_orientation(tile)
	var mask := _get_advanced_tile_data(
			tile,
			"mask",
			{}
	)
	if mask.is_empty():
		return get_terrain_empty_mask(terrain_index, orientation)
	return mask.duplicate()


## Returns an array of tile keys in all the atlas sources of this tile set.
func get_advanced_tiles() -> Array[TileKey]:
	var tiles: Array[TileKey] = []
	for source_index in get_source_count():
		var id := get_source_id(source_index)
		var source := get_source(id)
		if source is TileSetAtlasSource:
			var size: Vector2 = source.get_atlas_grid_size()
			for x in size.x:
				for y in size.y:
					var coords := Vector2i(x, y)
					if source.get_tile_at_coords(coords) != coords:
						continue
					for alternative_id in source.get_alternative_tiles_count(coords):
						tiles.append(TileKey.new(
								id, coords, alternative_id
						))
	return tiles


func get_tile_data(tile: TileKey) -> TileData:
	return (
			get_source(tile.source_id) as TileSetAtlasSource
	).get_tile_data(tile.coords, tile.alternative_id)


func get_advanced_terrains_count() -> int:
	return _terrains.size()


func get_advanced_terrain_name(terrain_index: int) -> String:
	return _terrains[terrain_index].name


func get_advanced_terrain_color(terrain_index: int) -> Color:
	return _terrains[terrain_index].color


func get_advanced_terrain_mode(terrain_index: int) -> TileGeometry.ConnectionMode:
	return _terrains[terrain_index].mode


func get_advanced_terrain_auto_binding(terrain_index: int) -> bool:
	return _terrains[terrain_index].auto_binding


func get_advanced_terrain_binds_to(terrain_index: int, other_index: int) -> bool:
	if _need_recalc:
		_recalc()
	
	if terrain_index == TileGeometry.FLAG_EMPTY:
		return _binding_matches_terrain_index(
				empty_terrain_bindings, other_index
		)
	else:
		return _binding_matches_terrain_index(
				_terrains[terrain_index].bindings, other_index
		)


func get_advanced_terrain_priority(terrain_index: int) -> int:
	if _need_recalc:
		_recalc()
	if terrain_index == TileGeometry.FLAG_EMPTY:
		return empty_terrain_priority
	return _terrains[terrain_index].priority


func get_advanced_cell_orientation(coords: Vector2i) -> TileGeometry.Orientation:
	if advanced_shape == TileGeometry.Shape.TRIANGLE:
		if advanced_axis == TileGeometry.Axis.HORIZONTAL:
			if (coords.x ^ coords.y) & 1 == 1:
				return TileGeometry.Orientation.UP
			else:
				return TileGeometry.Orientation.DOWN
		else:
			if (coords.x ^ coords.y) & 1 == 1:
				return TileGeometry.Orientation.LEFT
			else:
				return TileGeometry.Orientation.RIGHT
	else:
		return TileGeometry.Orientation.UP


func get_tile_match_priority_bonus() -> int:
	if _need_recalc:
		_recalc()
	return _tile_match_priority_bonus


func get_advanced_terrain_has_tiles(terrain_id: int) -> bool:
	for tile in get_advanced_tiles():
		if get_advanced_terrain(tile) == terrain_id:
			return true
	return false


func _recalc() -> void:
	_advanced_terrain_update_auto_bindings()
	if auto_priorities:
		_advanced_terrain_update_priorities()
	_need_recalc = false


func _advanced_terrain_update_auto_bindings() -> void:
	# Re-calculate terrain auto bindings
	if empty_terrain_auto_bindings:
		empty_terrain_bindings = _binding_set_terrain_index(0, -1, true)
	for index in _terrains.size():
		if _terrains[index].auto_binding:
			_terrains[index].bindings = 0
	for tile in get_advanced_tiles():
		var center_terrain_index: int = get_advanced_terrain(tile)
		if center_terrain_index < 0:
			continue
		var mask := get_advanced_mask(tile)
		for flag in mask:
			var flag_terrain_index: int = mask[flag]
			if ! _terrains[flag_terrain_index].auto_binding:
				continue
			if flag_terrain_index == TileGeometry.FLAG_EMPTY:
				if empty_terrain_auto_bindings:
					empty_terrain_bindings = _binding_set_terrain_index(
						empty_terrain_bindings,
						center_terrain_index,
						true
					)
				continue
			var flag_terrain: Terrain = _terrains[flag_terrain_index]
			flag_terrain.bindings = _binding_set_terrain_index(
					flag_terrain.bindings,
					center_terrain_index,
					true
			)


func _advanced_terrain_update_priorities() -> void:
	# Re-calculate terrain priorities, based on bindings
	var graph := DirectedGraph.new()
	for i in _terrains.size():
		graph.add_node()
	var empty_node_index := graph.add_node()
	for i in _binding_get_matched_terrains(empty_terrain_bindings):
		if i != TileGeometry.FLAG_EMPTY:
			graph.add_edge(empty_node_index, i)
	for i in _terrains.size():
		for j in _binding_get_matched_terrains(_terrains[i].bindings):
			if i == j:
				continue
			elif j == TileGeometry.FLAG_EMPTY:
				graph.add_edge(i, empty_node_index)
			else:
				graph.add_edge(i, j)
	graph.sort()
	for i in graph.t_sort.size():
		if graph.t_sort[i] == empty_node_index:
			empty_terrain_priority = i + 1
		else:
			_terrains[graph.t_sort[i]].priority = i + 1
	_tile_match_priority_bonus = (graph.t_sort.size() + 1) * 16


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
	var custom_data: Dictionary = tile_data.get_custom_data(DATA_LAYER_NAME)
	custom_data[key] = value


# Retrieve any per-tile data used by the AdvancedTileSet plugin,
# requires a default value
func _get_advanced_tile_data(
		tile: TileKey,
		key: String,
		default: Variant
) -> Variant:
	if tile.source_id == -1:
		return default
	var layer_index: int = get_custom_data_layer_by_name(DATA_LAYER_NAME)
	if layer_index == -1:
		add_custom_data_layer()
		layer_index = get_custom_data_layers_count() - 1
		set_custom_data_layer_name(layer_index, DATA_LAYER_NAME)
		set_custom_data_layer_type(layer_index, TYPE_DICTIONARY)
	var tile_data := (
			get_source(tile.source_id) as TileSetAtlasSource
			).get_tile_data(tile.coords, tile.alternative_id)
	return tile_data.get_custom_data(DATA_LAYER_NAME).get(key, default)


func _clear_advanced_tile_data(tile: TileKey, key: String) -> void:
	var layer_index: int = get_custom_data_layer_by_name(DATA_LAYER_NAME)
	if layer_index == -1:
		return
	var tile_data := (
			get_source(tile.source_id) as TileSetAtlasSource
			).get_tile_data(tile.coords, tile.alternative_id)
	var custom_data: Dictionary = tile_data.get_custom_data(DATA_LAYER_NAME)
	custom_data.erase(key)


func _apply_base_overrides() -> void:
	tile_shape = BaseOverrides.get_tile_shape(advanced_shape)
	tile_layout = BaseOverrides.get_tile_layout(advanced_layout)
	tile_offset_axis = BaseOverrides.get_tile_offset_axis(advanced_axis)
	tile_size = BaseOverrides.get_tile_size(
			advanced_shape,
			advanced_axis,
			advanced_tile_size,
	)


func get_terrain_empty_mask(
		terrain_index: int,
		orientation: TileGeometry.Orientation
) -> Dictionary:
	if terrain_index == TileGeometry.FLAG_EMPTY:
		return {}
	var flags: PackedInt32Array = TileGeometry.get_flags(
			_terrains[terrain_index].mode,
			advanced_shape,
			advanced_axis,
			orientation
	)
	var mask := {}
	for flag in flags:
		mask[flag] = TileGeometry.FLAG_EMPTY
	return mask


#region Functions for manipulating terrain binding bitmask
static func _binding_set_terrain_index(
		binding: int, terrain_index: int, value: bool
) -> int:
	var mask := _binding_get_terrain_mask(terrain_index)
	if value:
		return binding | mask
	else:
		return binding & ~ mask


static func _binding_matches_terrain_index(
		binding: int, terrain_index: int
) -> bool:
	var mask := _binding_get_terrain_mask(terrain_index)
	return (binding & mask == mask)


static func _binding_get_terrain_mask(terrain_index: int) -> int:
	return 1 << (terrain_index + 1)


static func _binding_get_matched_terrains(binding: int) -> PackedInt32Array:
	var terrains: PackedInt32Array = []
	var mask := 1
	var i := -1
	while mask <= binding:
		if binding & mask:
			terrains.append(i)
		mask <<= 1
		i += 1
	return terrains
#endregion


## Class TileKey contains all fields needed to identify a Tile in a TileSet
class TileKey:
	static var EMPTY := TileKey.new(-1, Vector2i(-1, -1), 0)
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
	var mode: TileGeometry.ConnectionMode
	var auto_binding := true
	var bindings: int = 0 #(bitmask)
	var priority: int = 0
	var has_tiles := false
	
	
	func _init(init_name: String, init_color: Color) -> void:
		name = init_name
		color = init_color


class BaseOverrides:
	static func get_tile_shape(
			advanced_shape: TileGeometry.Shape
	) -> TileSet.TileShape:
		match advanced_shape:
			TileGeometry.Shape.SQUARE, TileGeometry.Shape.TRIANGLE:
				return TileSet.TileShape.TILE_SHAPE_SQUARE
			TileGeometry.Shape.ISOMETRIC:
				return TileSet.TileShape.TILE_SHAPE_ISOMETRIC
			TileGeometry.Shape.HALF_OFFSET_SQUARE:
				return TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE
			_:
				assert(advanced_shape == TileGeometry.Shape.HEXAGON)
				return TileSet.TileShape.TILE_SHAPE_HEXAGON
	
	
	static func get_tile_layout(
			advanced_layout: TileGeometry.Layout
	) -> TileSet.TileLayout:
		match advanced_layout:
			TileGeometry.Layout.STACKED_OFFSET:
				return TileSet.TILE_LAYOUT_STACKED_OFFSET
			TileGeometry.Layout.STAIRS_RIGHT:
				return TileSet.TILE_LAYOUT_STAIRS_RIGHT
			TileGeometry.Layout.STAIRS_DOWN:
				return TileSet.TILE_LAYOUT_STAIRS_DOWN
			TileGeometry.Layout.DIAMOND_RIGHT:
				return TileSet.TILE_LAYOUT_DIAMOND_RIGHT
			TileGeometry.Layout.DIAMOND_DOWN:
				return TileSet.TILE_LAYOUT_DIAMOND_DOWN
			_:
				assert(advanced_layout == TileGeometry.Layout.STACKED)
				return TileSet.TILE_LAYOUT_STACKED
	
	
	static func get_tile_offset_axis(
			advanced_axis: TileGeometry.Axis
	) -> TileSet.TileOffsetAxis:
		match advanced_axis:
			TileGeometry.Axis.HORIZONTAL:
				return TileSet.TILE_OFFSET_AXIS_HORIZONTAL
			_:
				assert(advanced_axis == TileGeometry.Axis.VERTICAL)
				return TileSet.TILE_OFFSET_AXIS_VERTICAL
	
	
	static func get_tile_size(
			advanced_shape: TileGeometry.Shape,
			advanced_axis: TileGeometry.Axis,
			advanced_size: Vector2i
	) -> Vector2i:
		if advanced_shape != TileGeometry.Shape.TRIANGLE:
			return advanced_size
		if advanced_axis == TileGeometry.Axis.HORIZONTAL:
			return Vector2i(Vector2(advanced_size) * Vector2(0.5, 1.0))
		else:
			return Vector2i(Vector2(advanced_size) * Vector2(1.0, 0.5))
