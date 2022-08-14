@tool
extends Node3D

@onready var boom: SpringArm3D = $CameraBoom

@export var camera_rot: float = 0 :
	get:
		return rotation.x
	set(value):
		rotation.x = value

@export var camera_distance: float = 10.0 :
	get:
		if boom:
			return boom.spring_length
		else:
			return 10.0
	set(value):
		if boom:
			boom.spring_length = value

