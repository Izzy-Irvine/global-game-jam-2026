class_name GroundTileSet
extends Resource

const TILE_POSITIONS = [
	"Top_Left", "Top_Center", "Top_Right",
	"Left", "Center", "Right",
	"Bottom_Left", "Bottom_Center", "Bottom_Right"
]

enum TerrainType {
	GROUND,
	STONE
}

@export var tile_size: int = 32  # Changed to 32

@export_category("Ground Tiles")
@export_dir var ground_none_path: String = "res://sprites/Ground/NONE/"
@export_dir var ground_blue_path: String = "res://sprites/Ground/BLUE/"
@export_dir var ground_red_path: String = "res://sprites/Ground/RED/"
@export_dir var ground_black_path: String = "res://sprites/Ground/BLACK/"

@export_category("Stone Tiles")
@export_dir var stone_none_path: String = "res://sprites/Stone/NONE/"
@export_dir var stone_blue_path: String = "res://sprites/Stone/BLUE/"
@export_dir var stone_red_path: String = "res://sprites/Stone/RED/"
@export_dir var stone_black_path: String = "res://sprites/Stone/BLACK/"

var _texture_cache: Dictionary = {}
var _loaded: bool = false

func _load_textures():
	if _loaded:
		return
	
	_texture_cache.clear()
	
	var configs = [
		{ "terrain": TerrainType.GROUND, "mask": 0, "path": ground_none_path, "prefix": "NONE" },
		{ "terrain": TerrainType.GROUND, "mask": 1, "path": ground_blue_path, "prefix": "BLUE" },
		{ "terrain": TerrainType.GROUND, "mask": 2, "path": ground_red_path, "prefix": "RED" },
		{ "terrain": TerrainType.GROUND, "mask": 3, "path": ground_black_path, "prefix": "BLACK" },
		{ "terrain": TerrainType.STONE, "mask": 0, "path": stone_none_path, "prefix": "NONE" },
		{ "terrain": TerrainType.STONE, "mask": 1, "path": stone_blue_path, "prefix": "BLUE" },
		{ "terrain": TerrainType.STONE, "mask": 2, "path": stone_red_path, "prefix": "RED" },
		{ "terrain": TerrainType.STONE, "mask": 3, "path": stone_black_path, "prefix": "BLACK" },
	]
	
	for config in configs:
		var terrain = config["terrain"]
		var mask_id = config["mask"]
		var base_path = config["path"]
		var prefix = config["prefix"]
		
		if not _texture_cache.has(terrain):
			_texture_cache[terrain] = {}
		if not _texture_cache[terrain].has(mask_id):
			_texture_cache[terrain][mask_id] = {}
		
		if base_path.is_empty():
			continue
		
		for tile_pos in TILE_POSITIONS:
			var file_path = base_path.path_join("%s_%s.png" % [prefix, tile_pos])
			if ResourceLoader.exists(file_path):
				_texture_cache[terrain][mask_id][tile_pos] = load(file_path)
			else:
				push_warning("Missing tile texture: " + file_path)
	
	_loaded = true

func get_texture(terrain: TerrainType, mask_id: int, tile_position: String) -> Texture2D:
	_load_textures()
	
	if _texture_cache.has(terrain):
		if _texture_cache[terrain].has(mask_id):
			if _texture_cache[terrain][mask_id].has(tile_position):
				return _texture_cache[terrain][mask_id][tile_position]
		
		if mask_id != 0 and _texture_cache[terrain].has(0):
			if _texture_cache[terrain][0].has(tile_position):
				return _texture_cache[terrain][0][tile_position]
	
	return null

func reload_textures():
	_loaded = false
	_load_textures()
