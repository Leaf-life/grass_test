extends Node3D
#@onready var grass: Node3D = $node_3d
var grass_tile := preload("res://node_3d.tscn")

@onready var proto_controller: CharacterBody3D = $ProtoController
@onready var grid_map: GridMap = $GridMap

const SPAWN_RADIUS = 3  # number of tiles in each direction
const TILE_SIZE = 10    # match your GridMap cell size or grass tile spacing

var loaded_tiles := {}  # Dictionary of Vector2i -> tile reference
var player_tile := Vector2i.ZERO

#creates grass tiles
func create_grass():
	var center = player_tile
	var tiles_to_keep = {}

	for x in range(center.x - SPAWN_RADIUS, center.x + SPAWN_RADIUS + 1):
		for z in range(center.y - SPAWN_RADIUS, center.y + SPAWN_RADIUS + 1):
			var tile_pos = Vector2i(x, z)
			tiles_to_keep[tile_pos] = true

			if not loaded_tiles.has(tile_pos):
				var tile = grass_tile.instantiate()
				tile.position = Vector3(tile_pos.x * TILE_SIZE, 0, tile_pos.y * TILE_SIZE)
				
				var mesh_instance = tile.get_node("MultiMeshInstance3D")
				var dist = abs(tile_pos.x - center.x) + abs(tile_pos.y - center.y)
				
				mesh_instance.multimesh = mesh_instance.multimesh.duplicate()
				
				mesh_instance.multimesh.visible_instance_count = 2500
				
				#if dist == 0:
					#mesh_instance.multimesh.visible_instance_count = 2500
				#elif dist <= 2:
					#mesh_instance.multimesh.visible_instance_count = 1000
				#else:
					#mesh_instance.multimesh.visible_instance_count = 500

				add_child(tile)
				loaded_tiles[tile_pos] = tile

	# Unload distant tiles
	for tile_pos in loaded_tiles.keys():
		if not tiles_to_keep.has(tile_pos):
			loaded_tiles[tile_pos].queue_free()
			loaded_tiles.erase(tile_pos)
	
func _ready() -> void:
	create_grass()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_tile = grid_map.local_to_map(proto_controller.global_transform.origin)
	var new_tile_2d = Vector2i(new_tile.x, new_tile.z)
	if new_tile_2d != player_tile:
		player_tile = new_tile_2d
		create_grass()
	
