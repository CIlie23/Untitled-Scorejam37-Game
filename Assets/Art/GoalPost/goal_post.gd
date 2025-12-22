extends Node3D

@onready var spawner := get_tree().get_first_node_in_group("Spawner")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Ball"):
		return

	if is_in_group("GoalBlue"):
		Global.blueScore += 1
		print(Global.blueScore, " score for blue")

	elif is_in_group("GoalRed"):
		Global.redScore += 1
		print(Global.redScore, " score for red")

	body.queue_free()
	spawner.spawn_new_ball()
