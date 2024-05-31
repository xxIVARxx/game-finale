extends CharacterBody3D

@onready var x = $CollisionShape3D/Area3D
@onready var area = $CollisionShape3D/Area3D

@onready var nav_agent = $NavigationAgent3D


var SPEED =3.0
func _process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = new_velocity
	move_and_slide()

func update_target_location(target_location):
	nav_agent.target_position= target_location

func _on_area_body_entered(): 
	for body in area.get_overlapping_bodies():
			if body.is_in_group("rope"):
				print("damage ")

