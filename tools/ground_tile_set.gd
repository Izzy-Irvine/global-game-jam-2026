class_name GroundTileSet
extends Resource

const TILE_POSITIONS = [
	"Top_Left", "Top_Center", "Top_Right",
	"Left", "Center", "Right",
	"Bottom_Left", "Bottom_Center", "Bottom_Right"
]

@export var tile_size: int = 32

@export_dir var none_tiles_path: String = "res://sprites/Ground/NONE/"
@export_dir var blue_tiles_path: String = "res://sprites/Ground/BLUE/"
@export_dir var red_tiles_path: String = "res://sprites/Ground/RED/"
@export_dir var black_tiles_path: String = "res://sprites/Ground/BLACK/"

# Use int keys instead of enum to avoid parse-time dependency
# 0 = NONE, 1 = BLUE, 2 = RED, 3 = BLACK
var _texture_cache: Dictionary = {}
var _loaded: bool = false

func _load_textures():
	if _loaded:
		return
	
	_texture_cache.clear()
	
	var paths = {
		0: none_tiles_path,  # NONE
		1: blue_tiles_path,  # BLUE
		2: red_tiles_path,   # RED
		3: black_tiles_path, # BLACK
	}
	
	var prefixes = {
		0: "NONE",
		1: "BLUE",
		2: "RED",
		3: "BLACK",
	}
	
	for mask_id in paths:
		_texture_cache[mask_id] = {}
		var base_path = paths[mask_id]
		if base_path.is_empty():
			continue
		
		var prefix = prefixes[mask_id]
		for tile_pos in TILE_POSITIONS:
			var file_path = base_path.path_join("%s_%s.png" % [prefix, tile_pos])
			if ResourceLoader.exists(file_path):
				_texture_cache[mask_id][tile_pos] = load(file_path)
			else:
				push_warning("Missing tile texture: " + file_path)
	
	_loaded = true

func get_texture(mask_id: int, tile_position: String) -> Texture2D:
	_load_textures() 
	
	if _texture_cache.has(mask_id) and _texture_cache[mask_id].has(tile_position):
		return _texture_cache[mask_id][tile_position]
	return null

func reload_textures():
	_loaded = false
	_load_textures()
