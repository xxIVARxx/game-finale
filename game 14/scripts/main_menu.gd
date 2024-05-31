class_name MainMenu
extends Node

@onready var main = $main



@onready var start_button = $"main/MarginContainer/HBoxContainer/VBoxContainer/single player" as Button
@onready var exit = $main/MarginContainer/HBoxContainer/VBoxContainer/exit as Button
@onready var host = $main/MarginContainer/HBoxContainer/VBoxContainer/host as Button
@onready var address_entry = $"main/MarginContainer/HBoxContainer/VBoxContainer/join via ip" 
@onready var join = $main/MarginContainer/HBoxContainer/VBoxContainer/join as Button
@onready var options = $main/MarginContainer/HBoxContainer/VBoxContainer/options as Button
@onready var options_menu = $main/options_Menu as OptionsMenu
@onready var margin_container = $main/MarginContainer as MarginContainer

@onready var health_bar = $HUD/HealthBar
@onready var hud = $HUD



@onready var start_level = preload("res://single player.tscn") as PackedScene
@onready var terrain = preload("res://environment.tscn") as PackedScene
const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	handle_connecting_signals()
func on_start_pressed():
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed():
	get_tree().quit()
	
	

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()



func _on_join_button_pressed():
	main.hide()
	hud.show()
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer


func _on_host_button_pressed():
	main.hide()
	print("start")
	hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
func _on_option_pressed():
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func update_health_bar(health_value):
	health_bar.value = health_value

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
		
func on_exit_options_menu():
	margin_container.visible = true
	options_menu.visible = false

func handle_connecting_signals():
	start_button.button_down.connect(on_start_pressed)
	host.button_down.connect(_on_host_button_pressed)
	join.button_down.connect(_on_join_button_pressed)
	options.button_down.connect(_on_option_pressed)
	exit.button_down.connect(on_exit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
