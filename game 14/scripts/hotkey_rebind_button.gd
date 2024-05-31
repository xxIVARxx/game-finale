class_name  HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button 

@export var action_name : String = "up"




func _ready():
	set_process_unhandled_input(false)
	set_text_for_key()
	set_action_name()
func set_action_name():
	label.text = "unassigned"
	
	match  action_name:
		"up" :
			label.text = "up"
		"down":
			label.text = "down"
		"left":
			label.text = "left"
		"right":
			label.text = "right"
		"jump":
			label.text = "jump"
		"run":
			label.text = "run"
		"hit":
			label.text = "hit"
		"interact":
			label.text = "interact"
		"hold and drop":
			label.text = "hold and drop"
			
			
func set_text_for_key():
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]        
		if action_event is InputEventKey:
			var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
			button.text = "%s" % action_keycode
		else:
			button.text = "Invalid Key"
	else:
		button.text = "No Key Assigned"


func _on_button_toggled(button_pressed ):
	if button_pressed:
		button.text = "press any key.."
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group ("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.button_pressed = false
				i.set_process_unhandled_key_input(false)
				
	else:
		set_text_for_key()
	
	
func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
func rebind_action_key(event):
#	InputMap.action_erase_events(action_name)
#	InputMap.action_add_event(action_name, event)
#	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
