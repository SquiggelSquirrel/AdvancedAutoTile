@tool
extends PanelContainer


const TILESET_META_KEY := "_AdvancedAutotile"

var tile_set: AdvancedTileSet = null:
	set(value):
		tile_set = value
		if ! is_node_ready():
			await ready
		%Setup.tile_set = tile_set
		#%Painting.tile_set = tile_set
