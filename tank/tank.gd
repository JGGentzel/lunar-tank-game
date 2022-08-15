extends VehicleBody3D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("accelerate"):
		var force = mass * 2
		engine_force = force
	else:
		engine_force = 0
	if Input.is_action_pressed("brake"):
		brake = 1.0
	else:
		brake = 0.0
	var axis = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	steering = axis * 45.0
