extends CharacterBody3D


# SPACE for jump, hold SPACE for super jump
# hold SHIFT for movementSpeed up
#@onready var muzzle: Node3D = $pivot
@onready var muzzle: MeshInstance3D = $pivot/muzzle
#@onready var barrel: RayCast3D = $pivot/muzzle/barrel
@onready var barrel: RayCast3D = $pivot/muzzle/barrel


@onready var tankBody: Node3D = $blockbench_export
@onready var accelerate_bar: ProgressBar = $CanvasLayer/Control/AccelerateBar

const SHELL = preload("uid://cui5wr0adk0gn")
var instance

var movementSpeed: int = 10
const boostedMovementSpeed: int = 15

var JUMP_VELOCITY = 4.5
const MUZZLE_TURN_SPEED = 0.003

@export var turret_movementSpeed: float = 10.0
@export var playerHealth = 100

@export var maxBoost: float = 100
@export var currentBoost: float = maxBoost

var canAccelerate: bool = false
var isAccelerating: bool = false
var last_direction = Vector3.FORWARD
@export var rotation_movementSpeed = 2

func _ready():
	print(movementSpeed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fireTurret"):
		print("boom")
		instance = SHELL.instantiate()
		instance.position = barrel.global_position
		instance.transform.basis = barrel.global_transform.basis
		get_parent().add_child(instance)
		
	accelerate_bar.value = currentBoost
	
	if maxBoost >= 100:
		canAccelerate = true
	else:
		canAccelerate = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		muzzle.rotate_y(-event.relative.x * MUZZLE_TURN_SPEED)
		
func _physics_process(delta: float) -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var direction = (collider.global_position - global_position).normalized()
			# making it jump a lil
			direction.y += 0.6 
			
			var power = movementSpeed * 0.06
			collider.apply_central_impulse(direction * power)
		
	if canAccelerate and isAccelerating:
		currentBoost -= 30 * delta
		movementSpeed = boostedMovementSpeed
		print("zooming rn " + str(movementSpeed))
		if currentBoost <= 0:
			isAccelerating = false
			canAccelerate = false
			currentBoost = 0
	else:
		movementSpeed = 10
		
		if currentBoost < maxBoost: #regen the bar
			currentBoost += 10 * delta
			
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY 
	
	if Input.is_action_just_pressed("accelerate") and currentBoost >= maxBoost:
		isAccelerating = true
		canAccelerate = true
		
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	var mouse_pos = get_mouse_world_pos()
	
	# Make the turret look at mouse
	if mouse_pos:
		var dir_to_mouse = mouse_pos - muzzle.global_position
		var target_turret_angle = atan2(dir_to_mouse.x, dir_to_mouse.z)
		muzzle.rotation.y = lerp_angle(muzzle.rotation.y, target_turret_angle, delta * turret_movementSpeed)
		
	if direction:
		#last_direction = direction
		velocity.x = direction.x * movementSpeed
		velocity.z = direction.z * movementSpeed
		
		var target_angle = atan2(velocity.x, velocity.z)
		tankBody.rotation.y = lerp_angle(tankBody.rotation.y, target_angle, delta * rotation_movementSpeed)
		
		#if velocity.length() > 0.1:
			#var target_angle = atan2(velocity.x, velocity.z)
			#tankBody.rotation.y = lerp_angle(tankBody.rotation.y, target_angle, delta * 1.0)
	else:
		velocity.x = move_toward(velocity.x, 0, movementSpeed)
		velocity.z = move_toward(velocity.z, 0, movementSpeed)
	
	move_and_slide()
	
func get_mouse_world_pos():
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var plane = Plane(Vector3.UP, 0) 
	var world_pos = plane.intersects_ray(from, to)
	
	return world_pos
