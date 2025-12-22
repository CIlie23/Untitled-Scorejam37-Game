extends Node3D

const SPEED = 40.0
@export var bullet_power: float = 15.0 # Adjust this to push the ball harder/softer
@onready var ray: RayCast3D = $RayCast3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

	if ray.is_colliding():
		var collider = ray.get_collider()

		if collider is RigidBody3D and collider.is_in_group("Ball"):
			var push_dir = -transform.basis.z.normalized()
			push_dir.y += 0.2 
			#Apply the force to the ball
			collider.apply_central_impulse(push_dir * bullet_power)
			
			if collider.has_method("hit"):
				collider.hit()

		mesh.visible = false
		ray.enabled = false

		set_process(false) 
		
		await get_tree().create_timer(1.0).timeout
		queue_free()
