@tool
class_name AdvancedTileSet
extends TileSet
## Tile Set for use with Advanced Autotiles plugin
##
## An extension of Godot's built-in [TileSet] class, intended for use with an
## [AdvancedTileMapLayer] node. Adds support for triangle grid configuration
## and terrain setup for this plugin.
##
## Plugins cannot extend built-in methods or properties, so this class has
## a number of replacements, and the built-in class features are hidden in the
## editor unless [member hide_base_class_features] is disabled.
##
## Triangle grids are implemented using Godot's square grid with half the
## width/height for horizontal/vertical stacking, so triangles must have an
## even width/height (depending on axis).

## Emitted when the terrains setup changes. (Other changes use the
## [signal changed] signal.
signal terrains_changed


## Key used for storing per-tile plugin data on TileSet custom data layer
const DATA_LAYER_NAME := "_advanced_autotiles"


## Hide properties of the base [class TileSet] in the editor, if an
## Advanced Autotiles property is intended to replace.
## (Does not affect underlying API)
@export var hide_base_class_features := true:
	set(value):
		hide_base_class_features = value
		notify_property_list_changed()

@export_group("Grid properties", "advanced_")
## The tile shape used by the Advanced Autotiles plugin.
## Overwrites [member TileSet.tile_shape]
@export var advanced_shape := TileGeometry.Shape.SQUARE:
	set(value):
		if advanced_shape == value:
			return
		advanced_shape = value
		if _is_loaded:
			for tile in advanced_get_tiles():
				if advanced_get_tile_terrain(tile) > -1:
					advanced_clear_tile_mask(tile)
			_apply_base_overrides()
			_need_recalc = true
			notify_property_list_changed()
			_queue_signal(changed)
## The tile layout used by the Advanced Autotiles plugin.
## Overwrites [member TileSet.tile_layout]
@export var advanced_layout := TileGeometry.Layout.STACKED:
	set(value):
		if advanced_layout == value:
			return
		advanced_layout = value
		if _is_loaded:
			_apply_base_overrides()
			_queue_signal(changed)
## For half-offset shapes (isometric, hexagonal, half-offset square),
## determines the offset axis. For triangles, determines the stacking and
## allowed orientations.
@export var advanced_axis := TileGeometry.Axis.HORIZONTAL:
	set(value):
		if advanced_axis == value:
			return
		advanced_axis = value
		if _is_loaded:
			for tile in advanced_get_tiles():
				if advanced_get_tile_terrain(tile) > -1:
					advanced_clear_tile_mask(tile)
			advanced_tile_size = advanced_tile_size
			_apply_base_overrides()
			_queue_signal(changed)
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
			_queue_signal(changed)

@export_group("Autotiling")
## If true, calculate terrain properties automatically from bindings
@export var auto_priorities := true:
	set(value):
		if value == auto_priorities:
			return
		if _is_loaded and value:
			_need_recalc = true
		if _is_loaded and _need_recalc and not value:
			_recalc()
		auto_priorities = value
		notify_property_list_changed()

@export_subgroup("Empty tile", "empty_terrain_")
## If true, determine bindings for the "empty" terrain automatically.
@export var empty_terrain_auto_bindings := true:
	set(value):
		if value == empty_terrain_auto_bindings:
			return
		if _is_loaded and value:
			_need_recalc = true
		if _is_loaded and _need_recalc and not value:
			_recalc()
		empty_terrain_auto_bindings = value
		notify_property_list_changed()
## Bitmask of bindings for the "empty" terrain.
@export var empty_terrain_bindings: int = 0
## Priority of the "empty" terrain.
@export_range(1, 100, 1, "or_greater") var empty_terrain_priority: int = 0

@export_storage var _need_recalc := true
var _terrains: Array[Terrain] = []
var _is_loaded := false
var _queued_signals: Array[Signal] = []


#region Static functions for manipulating terrain binding bitmask
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
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "1,100,1,or_greater",
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
		"empty_terrain_priority":
			if auto_priorities:
				property.usage = PROPERTY_USAGE_STORAGE
		"tile_shape",\
		"tile_layout",\
		"tile_offset_axis",\
		"tile_size",\
		"terrain_sets":
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
		for tile in advanced_get_tiles():
			if advanced_get_tile_terrain(tile) >= value:
				# This tile was using a now-removed terrain,
				# set its terrain to empty
				advanced_set_tile_terrain(tile, -1)
				
			elif advanced_get_tile_terrain(tile) > -1:
				# This tile's terrain still exists, but it may have a mask
				# that uses a now-removed terrain. If so, clear the mask.
				for flag in advanced_get_tile_mask(tile).values():
					if flag >= value:
						advanced_clear_tile_mask(tile)
						break
		notify_property_list_changed()
		if _is_loaded:
			_queue_signal(terrains_changed)
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
					for tile in advanced_get_tiles():
						if advanced_get_tile_terrain(tile) == terrain_index:
							advanced_clear_tile_mask(tile)
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
					_need_recalc = true
		_terrains[terrain_index].set(terrain_property, value)
		if _is_loaded:
			_queue_signal(terrains_changed)
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


## Set the orientation of a tile (only relevant for triangle tiles)
func advanced_set_tile_orientation(
	tile: TileKey, orientation: TileGeometry.Orientation
) -> void:
	var allowed := TileGeometry.get_orientations(
			advanced_shape, advanced_axis
	)
	assert(orientation in allowed,
			"Tile orientation not supported by tile set shape+axis")
	_set_advanced_tile_data(tile, "orientation", orientation)
	if advanced_get_tile_terrain(tile) > -1:
		advanced_clear_tile_mask(tile)
	_need_recalc = true
	_queue_signal(changed)


## Get the orientation of a tile
func advanced_get_tile_orientation(tile: TileKey) -> TileGeometry.Orientation:
	var orientation := _get_advanced_tile_data(tile, "orientation", -1)
	if orientation == -1:
		return TileGeometry.get_orientations(advanced_shape, advanced_axis)[0]
	return orientation


## Set the terrain index of a tile
func advanced_set_tile_terrain(tile: TileKey, terrain_index: int) -> void:
	assert(terrain_index < _terrains.size(),
			"Terrain index outside size of tile set terrains")
	assert(terrain_index >= -1,
			"Negative terrain index only allowed for -1 (No terrain)")
	_set_advanced_tile_data(tile, "terrain_index", terrain_index)
	if terrain_index == -1:
		_clear_advanced_tile_data(tile, "mask")
	else:
		advanced_clear_tile_mask(tile)
	_need_recalc = true
	_queue_signal(changed)


## Get the terrain index of a tile
func advanced_get_tile_terrain(tile: TileKey) -> int:
	return _get_advanced_tile_data(tile, "terrain_index", -1)


## Set a flag of the "Advanced Autotiles" mask of a tile
func advanced_set_tile_mask_flag(
		tile: TileKey, flag: TileGeometry.CellNeighbor, flag_value: int
) -> void:
	var terrain_index: int = advanced_get_tile_terrain(tile)
	assert(terrain_index > -1,
			"Cannot set autotile flag on tile without terrain")
	var expected_flags := TileGeometry.get_flags(
			_terrains[terrain_index].mode,
			advanced_shape,
			advanced_axis,
			advanced_get_tile_orientation(tile)
	)
	assert(flag in expected_flags, "Unsupported autotile flag for this tile")
	var mask := advanced_get_tile_mask(tile)
	mask[flag] = flag_value
	for expected_flag in expected_flags:
		if ! mask.has(expected_flag):
			mask[expected_flag] = TileGeometry.FLAG_EMPTY
	_set_advanced_tile_data(tile, "mask", mask)
	_need_recalc = true
	_queue_signal(changed)


## Clear the "Advanced Autotiles" mask of a tile (set all flags to "empty")
func advanced_clear_tile_mask(tile: TileKey) -> void:
	var terrain_index: int = advanced_get_tile_terrain(tile)
	assert(terrain_index > -1,
			"Cannot set autotile mask on tile without terrain")
	var flags := TileGeometry.get_flags(
			_terrains[terrain_index].mode,
			advanced_shape,
			advanced_axis,
			advanced_get_tile_orientation(tile)
	)
	var mask := {}
	for flag in flags:
		mask[flag] = TileGeometry.FLAG_EMPTY
	_set_advanced_tile_data(tile, "mask", mask)


## Get the "Advanced Autotiles" mask of a tile
func advanced_get_tile_mask(tile: TileKey) -> Dictionary:
	var terrain_index: int = advanced_get_tile_terrain(tile)
	var orientation: TileGeometry.Orientation
	orientation = advanced_get_tile_orientation(tile)
	var mask := _get_advanced_tile_data(
			tile,
			"mask",
			{}
	)
	if mask.is_empty():
		return get_terrain_empty_mask(
				_terrains[terrain_index].mode,
				orientation
		)
	return mask.duplicate()


## Returns an array of tile keys objects, for all tiles in all the atlas sources
## of this tile set.
func advanced_get_tiles() -> Array[TileKey]:
	var tiles: Array[TileKey] = []
	for source_index in get_source_count():
		var id := get_source_id(source_index)
		var source := get_source(id)
		if not source is TileSetAtlasSource:
			continue
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


## Return the [TileData] of a tile identified by a [TileKey]
func get_tile_data(tile: TileKey) -> TileData:
	return (
			get_source(tile.source_id) as TileSetAtlasSource
	).get_tile_data(tile.coords, tile.alternative_id)


## Get the number of "Advanced Autotile" terrains defined for this tileset.
func advanced_get_terrains_count() -> int:
	return _terrains.size()


## Add a new "Advanced Autotile" terrain. Returns the index of the new terrain.
func advanced_add_terrain(
		terrain_name: String,
		terrain_mode: TileGeometry.ConnectionMode
) -> int:
	var new_index := advanced_get_terrains_count()
	_set(&"advanced_terrain_count", new_index + 1)
	return new_index


## Get the name of the "Advanced Autotile" terrain at this index.
func advanced_get_terrain_name(terrain_index: int) -> String:
	return _terrains[terrain_index].name


## Set the name of an "Advanced Autotile" terrain
func advanced_set_terrain_name(terrain_index: int, name: String) -> void:
	_terrains[terrain_index].name = name


## Get the color assigned to an "Advanced Autotile" terrain (for use in editor)
func advanced_get_tile_terrain_color(terrain_index: int) -> Color:
	return _terrains[terrain_index].color


## Set the color assigned to an "Advanced Autotile" terrain (for use in editor)
func advanced_set_tile_terrain_color(terrain_index: int, color: Color) -> void:
	_terrains[terrain_index].color = color


## Get the connection mode of an "Advanced Autotile" terrain
func advanced_get_terrain_mode(
		terrain_index: int
) -> TileGeometry.ConnectionMode:
	return _terrains[terrain_index].mode


## Set the connection mode of an "Advanced Autotile" terrain
func advanced_set_terrain_mode(
		terrain_index: int,
		mode: TileGeometry.ConnectionMode
) -> void:
	_set("advanced_terrain_%d/mode" % terrain_index, mode)


## If true, binding will be determined automatically for the specified
## "Advanced Autotile" terrain
func advanced_get_terrain_auto_binding(terrain_index: int) -> bool:
	return _terrains[terrain_index].auto_binding


## Set whether binding should be determined automatically for the specified
## "Advanced Autotile" terrain.
func advanced_set_terrain_auto_binding(
		terrain_index: int,
		auto_binding: bool
) -> void:
	_set("advanced_terrain_%d/auto_binding" % terrain_index, auto_binding)


## Test whether a given terrain binds to another terrain (Advanced Autotiles)
func advanced_get_terrain_binds_to(
		terrain_index: int,
		other_index: int
) -> bool:
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


## Set whether a given terrain binds to another terrain (Advanced Autotiles)
func advanced_set_terrain_binds_to(
		terrain_index: int,
		other_index: int,
		binds: bool
) -> void:
	assert(
			not _terrains[terrain_index].auto_binding,
			"Cannot set a binding if auto-binding is enabled"
	)
	_set(
			"advanced_terrain_%d/bindings" % terrain_index,
			_binding_set_terrain_index(
				_terrains[terrain_index].bindings, other_index, binds
			)
	)


## Get the priority of the specified "Advanced Autotile" terrain
func advanced_get_terrain_priority(terrain_index: int) -> int:
	if _need_recalc:
		_recalc()
	if terrain_index == TileGeometry.FLAG_EMPTY:
		return empty_terrain_priority
	return _terrains[terrain_index].priority


## Set the priority of the specified "Advanced Autotile" terrain
func advanced_set_terrain_priority(terrain_index: int, priority: int) -> void:
	assert(
			not auto_priorities,
			"Cannot set a priority if auto-priorities are enabled"
	)
	_set(
			"advanced_terrain_%d/priority" % terrain_index,
			priority
	)


## Test whether the specified "Advanced Autotile" terrain has any tiles
## assigned to it.
func advanced_get_terrain_has_tiles(terrain_id: int) -> bool:
	for tile in advanced_get_tiles():
		if advanced_get_tile_terrain(tile) == terrain_id:
			return true
	return false


## Get an empty tile mask for the given connection mode and tile orientation
func get_terrain_empty_mask(
		mode: TileGeometry.ConnectionMode,
		orientation: TileGeometry.Orientation
) -> Dictionary:
	var flags: PackedInt32Array = TileGeometry.get_flags(
			mode,
			advanced_shape,
			advanced_axis,
			orientation
	)
	var mask := {}
	for flag in flags:
		mask[flag] = TileGeometry.FLAG_EMPTY
	return mask


# Re-calc terrain bindings (and priorities, if auto-priorities enabled)
func _recalc() -> void:
	_advanced_terrain_update_auto_bindings()
	if auto_priorities:
		_advanced_terrain_update_priorities()
	_need_recalc = false


# Re-calc terrain bindings
func _advanced_terrain_update_auto_bindings() -> void:
	if empty_terrain_auto_bindings:
		# Initialise empty bindings to self only
		empty_terrain_bindings = _binding_set_terrain_index(0, -1, true)
		
		# Bind empty to any terrain with connection mode "NONE"
		for index in _terrains.size():
			if _terrains[index].mode == TileGeometry.ConnectionMode.NONE:
				empty_terrain_bindings = _binding_set_terrain_index(
						empty_terrain_bindings,
						index,
						true
				)
	
	## Initialise binding to self only
	for index in _terrains.size():
		if _terrains[index].auto_binding:
			_terrains[index].bindings = _binding_set_terrain_index(
					0, index, true
			)
	
	# Bindings based on tiles
	for tile in advanced_get_tiles():
		var tile_terrain_index: int = advanced_get_tile_terrain(tile)
		if tile_terrain_index == -1:
			continue
		var mask := advanced_get_tile_mask(tile)
		for flag in mask:
			var flag_terrain_index: int = mask[flag]
			if flag_terrain_index == TileGeometry.FLAG_EMPTY:
				if empty_terrain_auto_bindings:
					empty_terrain_bindings = _binding_set_terrain_index(
						empty_terrain_bindings,
						tile_terrain_index,
						true
					)
			elif _terrains[flag_terrain_index].auto_binding:
				var flag_terrain: Terrain = _terrains[flag_terrain_index]
				flag_terrain.bindings = _binding_set_terrain_index(
						flag_terrain.bindings,
						tile_terrain_index,
						true
				)


# Re-calculate terrain priorities, based on bindings
func _advanced_terrain_update_priorities() -> void:
	var graph := DirectedGraph.new()
	graph.add_node()
	for i in _terrains.size():
		graph.add_node()
	for i in _binding_get_matched_terrains(empty_terrain_bindings):
		if i != TileGeometry.FLAG_EMPTY:
			graph.add_edge(0, i + 1)
	for i in _terrains.size():
		for j in _binding_get_matched_terrains(_terrains[i].bindings):
			if i == j:
				continue
			elif j == TileGeometry.FLAG_EMPTY:
				graph.add_edge(i + 1, 0)
			else:
				graph.add_edge(i + 1, j + 1)
	graph.sort()
	for i in graph.t_sort.size():
		if graph.t_sort[i] == 0:
			empty_terrain_priority = i + 1
		else:
			_terrains[graph.t_sort[i] - 1].priority = i + 1


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


# Retrieve any per-tile data used by the Advanced Autotile plugin,
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


# Clear per-tile data used by the Advanced Autotile plugin
func _clear_advanced_tile_data(tile: TileKey, key: String) -> void:
	var layer_index: int = get_custom_data_layer_by_name(DATA_LAYER_NAME)
	if layer_index == -1:
		return
	var tile_data := (
			get_source(tile.source_id) as TileSetAtlasSource
			).get_tile_data(tile.coords, tile.alternative_id)
	var custom_data: Dictionary = tile_data.get_custom_data(DATA_LAYER_NAME)
	custom_data.erase(key)


# Overwrite base properties as needed, depending on Advanced Autotile properties
func _apply_base_overrides() -> void:
	tile_shape = TileGeometry.BaseOverrides.get_tile_shape(advanced_shape)
	tile_layout = TileGeometry.BaseOverrides.get_tile_layout(advanced_layout)
	tile_offset_axis = \
			TileGeometry.BaseOverrides.get_tile_offset_axis(advanced_axis)
	tile_size = TileGeometry.BaseOverrides.get_tile_size(
			advanced_shape,
			advanced_axis,
			advanced_tile_size,
	)


# Get hint string for bindings as exported property
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


# Get hint string for exporting an enum type
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


# Queue a signal to be called at end of frame (if not already queued)
func _queue_signal(signal_object: Signal) -> void:
	if ! signal_object in _queued_signals:
		_queued_signals.append(signal_object)
		_emit_queued_signals.call_deferred()


func _emit_queued_signals() -> void:
	for signal_object in _queued_signals:
		signal_object.emit()
	_queued_signals.clear()


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
	
	
	## Test if this key identifies the same tile as another key
	func equals(other_tile: TileKey) -> bool:
		if other_tile == null:
			return false
		return (
				source_id == other_tile.source_id
				and coords == other_tile.coords
				and alternative_id == other_tile.alternative_id
		)


## Class for storing a single terrain (intended only for internal use
## by [AdvancedTileSet] class.
class Terrain:
	var name := ""
	var color := Color.INDIAN_RED
	var mode: TileGeometry.ConnectionMode
	var auto_binding := true
	var bindings: int = 0 #(bitmask)
	var priority: int = 0
	
	
	func _init(init_name: String, init_color: Color) -> void:
		name = init_name
		color = init_color
