extends Node

signal tank_position_update

var tank_position: Vector3 = Vector3.ZERO:
	get:
		return tank_position
	set(value):
		emit_signal("tank_position_update")
		tank_position = value
