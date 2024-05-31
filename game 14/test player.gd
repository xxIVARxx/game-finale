extends CharacterBody3D
@onready var camera = $Head/Camera3D
@onready var A = $Marker3D
@onready var B = $"../red player/Marker3D"
@onready var ray = $Head/Camera3D/obj_picker/RayCast3D
@onready var marker = $Head/Camera3D/obj_picker/Marker3D
@onready var joint_3d = $Head/Camera3D/obj_picker/Generic6DOFJoint3D
@onready var body_3d = $Head/Camera3D/obj_picker/body3d
@onready var head = $Head

var picked_obj 
var pull_power = 20
var locked = false
var rot_power = 0.05
var hook_target_position : Vector3
var source_posiition = Node3D
var hookNode: Node3D
var friend = null
const SPEED = 10
const JUMP_VELOCITY = 4.5
var _hook_target_normal: Vector3
const HookScene = preload("res://scenes/hook.tscn")

var mouse_sense = 0.15
var isHoldingObject = false
var heldObject = null
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
func _unhandled_input(event):

	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	# Add the gravity.
	if Input.is_action_just_pressed("hold and drop"):
		if picked_obj == null:
			pick_object()
		elif picked_obj != null:
			drop_obj()
	if picked_obj != null:
		var a = picked_obj.global_transform.origin
		var b = marker.global_transform.origin
		picked_obj.set_linear_velocity((b-a)*pull_power)
		
	hookNode = HookScene.instantiate()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("interact"):
		interactWithDoor()
	maintainInteraction()
	if Input.is_action_just_pressed("hit"):
		handle_hook()
	if Input.is_action_just_pressed("free"):
		handle_hook2()
	# Handle jump.
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

	move_and_slide()

func handle_hook():
	hookNode = HookScene.instantiate()
	add_child(hookNode)
	hook_target_position = B.global_position
	source_posiition = A.global_position
	hookNode.extend_from_to(source_posiition, hook_target_position, _hook_target_normal)
func handle_hook2():
	hookNode = HookScene.instantiate()
	add_child(hookNode)
	hook_target_position = A.global_position
	source_posiition = B.global_position
	hookNode.extend_from_to(source_posiition, hook_target_position, _hook_target_normal)
	
	

	
func interactWithDoor():
	if !isHoldingObject: 
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("Door"):
				isHoldingObject = true
				heldObject = collider
	elif isHoldingObject:
		isHoldingObject = false
		heldObject = null
		
func maintainInteraction():
	if isHoldingObject and heldObject != null:
		var forceDirection = marker.global_transform.origin - heldObject.global_transform.origin
		forceDirection = forceDirection.normalized()
		heldObject.apply_central_force(forceDirection * 5)
func head_rot(event):
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
func rot_obj(event):
	if picked_obj != null:
		if event is InputEventMouseMotion:
			body_3d.rotate_x(deg_to_rad(event.relative.y * rot_power))
			body_3d.rotate_y(deg_to_rad(event.relative.x * rot_power))

func pick_object():
	var coll = ray.get_collider()
	if coll != null and coll.is_in_group("INT"):
		picked_obj = coll
		joint_3d.set_node_b(picked_obj.get_path())
func drop_obj():
	if picked_obj != null:
		picked_obj = null
		joint_3d.set_node_b(joint_3d.get_path())
