extends Node2D


func _ready() -> void:
	var atml := (get_parent() as AdvancedTileMapLayer)
	atml.advanced_autotile_paint_cells(
		2, [Vector2i(0,0)]
	)
