extends Node3D
@onready var spawner: Marker3D = $spawner

const BALL = preload("uid://dt543icjradca")
var ballInstance = BALL.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_new_ball()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_new_ball():
	if is_instance_valid(ballInstance):
		ballInstance.queue_free()

	ballInstance = BALL.instantiate()
	
	add_child(ballInstance)
	ballInstance.global_position = spawner.global_position

func _on_kill_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("Ball"):
		spawn_new_ball()
	if body.is_in_group("Blue"):
		print("hi blue")
