extends CharacterBody3D

#ENEMY TANK
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var tank_body: CharacterBody3D = $"."
@onready var blue_goal = get_tree().get_first_node_in_group("GoalBlue")

var movementSpeed: float
@export var baseSpeed: float = 8.0
@export var boostedMovementSpeed: int = 10
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const JUMP_VELOCITY = 4.5

var ball: RigidBody3D = null
var target: Vector3

var canAccelerate: bool = false
var isAccelerating: bool = false

@export var maxBoost: float = 100
@export var currentBoost: float = maxBoost

var wander_timer: float = 0.0

const STRIKE_DISTANCE := 1.5
const PRESSURE_DISTANCE := 3.5
const ORBIT_RADIUS := 2.2


# STATES
enum tankStates {IDLE, WANDER, CHASE, ATTACK, DEAD}
var current_state = tankStates.IDLE

func _ready() -> void:
	randomize()
	movementSpeed = baseSpeed
	current_state = tankStates.WANDER
	ball = get_tree().get_first_node_in_group("Ball")

func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
		
	if not is_instance_valid(ball):
		ball = get_tree().get_first_node_in_group("Ball")
		return
		
	match current_state:
		tankStates.IDLE:
			print("Idling")
		
		tankStates.WANDER:
			wander_timer -= delta
			move_logic(delta)
			
			if wander_timer <= 0:
				current_state = tankStates.CHASE
			
		tankStates.CHASE:
			if not is_instance_valid(ball) or not blue_goal:
				ball = get_tree().get_first_node_in_group("Ball")
				#velocity = Vector3.ZERO
				return

			navigation_agent.target_position = compute_chase_target()
			move_logic(delta)

			if randf() < 0.0009: #stupid
				start_wandering()
				
		tankStates.ATTACK:
			print("Attacking!")
			#attackState()
		tankStates.DEAD:
			print("Dead")
			#deadState()
		
	tank_boost(delta)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		#colision check for the ball
		#this makes it pop
		if collider is RigidBody3D:
			var horizontal_dir = (collider.global_position - global_position)
			horizontal_dir.y = 0 
			horizontal_dir = horizontal_dir.normalized()
			
			var forward_power = movementSpeed * 0.06
			var upward_pop = 2.0 
						
			var final_impulse = (horizontal_dir * forward_power) + (Vector3.UP * upward_pop)
			
			collider.apply_central_impulse(final_impulse)

func move_logic(delta: float):
	if navigation_agent.is_navigation_finished():
		var fallback_dir = (ball.global_position - global_position)
		fallback_dir.y = 0
		fallback_dir = fallback_dir.normalized()

		velocity.x = fallback_dir.x * movementSpeed
		velocity.z = fallback_dir.z * movementSpeed
		move_and_slide()
		return

	var destination = navigation_agent.get_next_path_position()
	var direction = (destination - global_position)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * movementSpeed
	velocity.z = direction.z * movementSpeed

	# Rotation
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		var target_angle = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)

	move_and_slide()

func start_wandering():
	current_state = tankStates.WANDER
	wander_timer = randf_range(0.5, 1.0) #how long he's distracted
	
	var random_position := Vector3.ZERO
	random_position.x = randf_range(-0.5, 1.0)
	random_position.z = randf_range(-0.5, 1.0)
	navigation_agent.set_target_position(random_position)

# i should prolly learn oop
func tank_boost(delta: float):
	if isAccelerating:
		currentBoost -= 30 * delta
		movementSpeed = boostedMovementSpeed
			
		if currentBoost <= 0:
			currentBoost = 0
			isAccelerating = false
	else:
		movementSpeed = baseSpeed
			
		# Slowly recharge
		if currentBoost < maxBoost:
			currentBoost += 10 * delta
			
func try_jump_shot():
	if not ball: return
	var dist_to_ball = global_position.distance_to(ball.global_position)
	
	if dist_to_ball < 3.0 and is_on_floor():
		var forward = -global_transform.basis.z
		var dir_to_ball = (ball.global_position - global_position).normalized()
		
		if forward.dot(dir_to_ball) > 0.8 and isAccelerating:
			velocity.y = JUMP_VELOCITY * 1.5
			print("AI JUMPING NOW")
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self and currentBoost >= maxBoost:
		isAccelerating = true

func should_perform_action(chance: float):
	return randf() < chance
	
func _on_should_jump_timeout() -> void:
	should_perform_action(5)
	if should_perform_action(0.3):
		try_jump_shot()

func is_ball_stationary() -> bool:
	return ball.linear_velocity.length() < 0.2

func compute_chase_target() -> Vector3:
	var ball_pos = ball.global_position
	#calculating how far we are from the goal
	var attack_dir = (ball_pos - blue_goal.global_position)
	attack_dir.y = 0
	attack_dir = attack_dir.normalized()

	var dist_to_ball = global_position.distance_to(ball_pos)

	if dist_to_ball > PRESSURE_DISTANCE:
		return ball_pos + attack_dir * 3.0

	#if strike distance strike
	if dist_to_ball > STRIKE_DISTANCE:
		var side = sign(randf() - 0.5)
		var tangent = Vector3(-attack_dir.z, 0, attack_dir.x) * side
		return ball_pos + tangent * ORBIT_RADIUS

	return ball_pos - attack_dir * 1.2
