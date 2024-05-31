extends Node
@onready var player = $"test player"
@onready var red_player = $"red player"
var friend = Node3D

func _physics_process(delta):
	get_tree().call_group("enemy","update_target_location", player.global_transform.origin)
func set_friend():
	red_player = friend
