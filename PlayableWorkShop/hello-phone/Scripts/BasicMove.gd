extends CharacterBody3D
@onready var ani_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var ani_tree: AnimationTree = $AnimationTree
const SPEED = 8.0
const JUMP_VELOCITY = 4.5
@onready var camera: Node3D = $CameraRig/Camera3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	turn_to(direction)
	
	var current_speed := velocity.length()
	var RUN_SPEED:= 3.5
	const BLEND_SPEED:= 0.2
	
	if not is_on_floor_only():
		ani_tree.set("parameters/movement/transition_request", "Fall") 
	elif current_speed > 4: 
		ani_tree.set("parameters/movement/transition_request", "Sprint") 
	elif current_speed > 0:
		ani_tree.set("parameters/movement/transition_request", "Walk") 
		var walk_speed:= lerpf(0.5, 1.75, current_speed / RUN_SPEED)
		ani_tree.set("parameters/walk_speed/scale", walk_speed)
	else:
		ani_tree.set("parameters/movement/transition_request", "Idel") 

func turn_to(direction: Vector3) -> void:
	if direction:
		var yaw:= atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, .25)
		rotation.y = yaw
		
	
