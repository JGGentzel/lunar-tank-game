extends VehicleBody3D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("accelerate"):
		var force = mass * 2
		engine_force = force
	else:
		engine_force = 0
	if Input.is_action_pressed("brake"):
		brake = mass * .005
	else:
		brake = 0
	if Input.is_action_just_pressed("steer_left"):
		steering = -45
	if Input.is_action_just_pressed("steer_right"):
		steering = 45
