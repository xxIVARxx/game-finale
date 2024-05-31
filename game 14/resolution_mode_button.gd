extends Control

@onready var option_button = $HBoxContainer/OptionButton

const RESOLUTION_DICTIONARY : Dictionary = {
	"1152  X  648" : Vector2i(1152, 648),
	"1280  X  720" : Vector2i(1280, 720),
	"1920  X  1080": Vector2i(1920, 1080)
}
func _ready():
	option_button.item_selected.connect(on_resolution_selcted)
	add_resolution_item()

func add_resolution_item():
	for resolution_size_text  in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)
	
func on_resolution_selcted(index):
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
