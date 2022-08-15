extends Node3D

@export var tank_scene: PackedScene
@export var seed: int = 0
@export var octaves: int = 6
@export var frequency: float = 80.0
@export var terrain_height: float = 1.0
@export var height_maps: Array[Texture] = []

const CHUNK_SIZE: int = 64
const CHUNK_AMOUNT: int = 16

var is_loaded: bool = false

var world_size_x: int = 0
var world_size_y: int = 0

var noise: FastNoiseLite
var chunks: Dictionary = {}
var queued_chunks: Array = []
var thread: Thread

func _ready() -> void:
	#validate noise data
	#size of array must be n ^ 2 in length
	#n = dims
	var tile_dim: int = sqrt(height_maps.size())
	var is_square: bool = fmod(tile_dim, 1.0) == 0
	if height_maps.size() > 0 and is_square:
		generate_terrain(tile_dim)
	else:
		print("Height maps array must be n ^ 2 in length")

func generate_terrain(tile_dim: int) -> void:
	world_size_x = height_maps[0].get_height() * tile_dim
	world_size_y = world_size_x
	randomize()
	#for
	noise = FastNoiseLite.new()
	noise.seed = seed
	noise.fractal_octaves = octaves
	noise.frequency = frequency

	thread = Thread.new()
	generate()

func generate() -> void:
	queue_chunk(0, 0)
	generate_ring(3)
	generate_ring(5)
	generate_ring(7)
	generate_ring(9)

func generate_ring(w: int) -> void:
	var tank_translation: Vector3 = Vector3.ZERO#$Player.position
	var p_x: int = int(tank_translation.x)/CHUNK_SIZE
	var p_z: int = int(tank_translation.z)/CHUNK_SIZE
	var max: int = (w - 1) / 2
	var min: int = -max
	var x: int = min + int(p_x)
	var z: int = 0 + int(p_z)
	queue_chunk(x, z)
	#move up left
	for i in range(max):
		z += 1
		queue_chunk(x, z)
	#move right top
	for j in range(w - 1):
		x += 1
		queue_chunk(x,z)
	#move down right
	for k in range(w - 1):
		z -= 1
		queue_chunk(x, z)
	#move bottom left
	for l in range(w - 1):
		x -= 1
		queue_chunk(x, z)
	if (w - max) > 2:
		#move up left
		for m in range(max - 1):
			z += 1
			queue_chunk(x, z)

func _process(delta: float) -> void:
	if not thread.is_alive() and not queued_chunks.is_empty():
		var chunk_to_load = queued_chunks.pop_front()
		thread.start(load_chunk.bind(thread, chunk_to_load.x, chunk_to_load.z, terrain_height))

func queue_chunk(x, z) -> void:
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return
	queued_chunks.push_back(Vector3(x, 0, z))

func load_chunk(thread: Thread, _x: int, _y: int, height: float) -> void:
	var x: int = _x * CHUNK_SIZE
	var z: int = _y * CHUNK_SIZE

	var chunk = TerrainChunk.new(noise, x, z, CHUNK_SIZE)
	chunk.position = Vector3(x, 0, z)
	chunk.height = height

	call_deferred("load_done", chunk, thread)

func load_done(chunk: TerrainChunk, thread: Thread) -> void:
	if not is_loaded:
		load_tank()
		is_loaded = true
	add_child(chunk)
	var key = str(chunk.x / CHUNK_SIZE) + "," + str(chunk.z / CHUNK_SIZE)
	chunks[key] = chunk
#	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x: int, z: int) -> TerrainChunk:
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	return null

func load_tank() -> void:
	var tank = tank_scene.instantiate()
	add_child(tank)
	tank.global_position = Vector3.UP * 3
