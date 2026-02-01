extends Node2D

# The SCRIPT that creates tilemap nodes
const GroundTileMapScript = preload("res://tools/ground_tile_map.gd")

# The RESOURCE with texture paths
const GroundTileSetResource = preload("res://levels/debug_level/debug_tileset.tres")

func _ready():
	var ground = Node2D.new()
	ground.set_script(GroundTileMapScript)
	ground.tile_set_resource = GroundTileSetResource  # Assign resource here
	ground.grid_size = Vector2i(20, 10)
	add_child(ground)
	GameManager.died.connect(_update_death_count)

func _update_death_count(count):
	$UI/DeathCounter.text = "Deaths: %d" % count
