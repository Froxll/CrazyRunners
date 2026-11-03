
class_name TimedBlock
extends StaticBody2D

# Couleur du bloc : 0 = bleu, 1 = rouge
@export_enum("Blue", "Red") var block_color: int = 0
# Identifiant du circuit
@export var circuit_id: StringName = &"A"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const BLUE_TEXTURE_PATH := "res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/block_blue.png"
const RED_TEXTURE_PATH := "res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/block_red.png"

# Boutons qui maintiennent ce bloc activé
var active_sources: Dictionary = {}


func _ready() -> void:
	add_to_group("timed_blocks")

	# Choisir le sprite selon la couleur
	if block_color == 0:
		if ResourceLoader.exists(BLUE_TEXTURE_PATH):
			sprite.texture = load(BLUE_TEXTURE_PATH)
	else:
		if ResourceLoader.exists(RED_TEXTURE_PATH):
			sprite.texture = load(RED_TEXTURE_PATH)

	# Désactivé au lancement
	_update_state()


func set_activated_by(source_id: int, enabled: bool) -> void:
	if enabled:
		active_sources[source_id] = true
	else:
		active_sources.erase(source_id)

	_update_state()


func _update_state() -> void:
	var is_active := not active_sources.is_empty()

	# Apparition ou disparition du bloc
	visible = is_active

	# Activer/désactiver sa collision physique
	collision_shape.set_deferred("disabled", not is_active)
