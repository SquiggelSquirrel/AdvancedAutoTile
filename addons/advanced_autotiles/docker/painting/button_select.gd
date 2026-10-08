@tool
extends HBoxContainer

signal item_selected(index: int)

@export var button_group: ButtonGroup


func _ready() -> void:
	button_group.pressed.connect(_on_button_group_pressed.unbind(1))


func _on_button_group_pressed() -> void:
	item_selected.emit(button_group.get_pressed_button().get_index())
