extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D
@onready var anim_player = $"Root Scene/AnimationPlayer"
@onready var hitbox = $Camera3D/hitbox
@onready var raycast = $RayCast3D


var melee_dmg = 3




var running = false
var health = 3
var walking_speed = 3.0
var running_speed = 9.0
var SPEED = 9.0
const JUMP_VELOCITY = 7.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = true

	
	
	if Input.is_action_just_pressed("swoard") :
		if anim_player.current_animation != "RedTeam_swoardMen_Armature|Attack_TwoHandSwodsMen":
			melee2.rpc()
			hitx.rpc()



func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		runx.rpc()
	#idle animation
	#else:
		#hitbox.monitoring = false
	#	anim_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")

	move_and_slide()


@rpc("call_local","any_peer")
func hitx():
	anim_player.play("RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen")


@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)




@rpc("call_local","any_peer")
func runx():
	anim_player.play("RedTeam_SwordsMen_Armature|Running_TwoHandSwordsMen")

#RedTeam_swoardMen_Armature|Atack_TwoHandSwodsMen
@rpc("call_local","any_peer")
func melee():
			for body in hitbox.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					print("collison detected")
					body.health-=melee_dmg
				else:
					print("not found")


func _on_collision_shape_3d_child_entered_tree(node):
	print("detection")
@rpc("any_peer","call_local")
func melee2():
	if raycast.is_colliding():
		var hit_player = raycast.get_collider()
		hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

#func _on_area_3d_body_entered(body):
#	print("dettect")
