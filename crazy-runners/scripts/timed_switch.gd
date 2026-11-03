
extends Area2D

# Configuration indépendante de chaque bouton
@export_enum("Blue", "Red") var switch_color: int = 0
@export_range(0.1, 120.0, 0.1) var activation_duration: float = 5.0
@export var circuit_id: StringName = &"A"

@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

const BLUE_IDLE = preload("res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/switch_blue.png")
const BLUE_PRESSED = preload("res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/switch_blue_pressed.png")

const RED_IDLE = preload("res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/switch_red.png")
const RED_PRESSED = preload("res://assets/kenney_new-platformer-pack-1.1/Sprites/Tiles/Default/switch_red_pressed.png")

var is_pressed: bool = false


func _ready() -> void:
    # Connecter les signaux automatiquement
    body_entered.connect(_on_body_entered)

    timer.one_shot = true
    timer.timeout.connect(_on_timer_timeout)

    update_sprite()


# Détection du joueur
func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return

    # Empêcher une nouvelle activation pendant le timer
    if is_pressed:
        return

    activate_switch()


# Activation du bouton
func activate_switch() -> void:
    is_pressed = true
    update_sprite()

    # Faire apparaître les blocs associés
    set_blocks_active(true)

    # Démarrer le compte à rebours
    timer.start(activation_duration)

    print("Bouton activé pendant ", activation_duration, " secondes")


# Fin du timer
func _on_timer_timeout() -> void:
    is_pressed = false
    update_sprite()

    # Faire disparaître les blocs associés
    set_blocks_active(false)

    print("Bouton réinitialisé")


# Changer l'apparence du bouton
func update_sprite() -> void:
    if switch_color == 0:
        if is_pressed:
            sprite.texture = BLUE_PRESSED
        else:
            sprite.texture = BLUE_IDLE
    else:
        if is_pressed:
            sprite.texture = RED_PRESSED
        else:
            sprite.texture = RED_IDLE


# Activer ou désactiver les blocs correspondants
func set_blocks_active(active: bool) -> void:
    var source_id := get_instance_id()

    for node in get_tree().get_nodes_in_group("timed_blocks"):
        if not node is TimedBlock:
            continue

        var block := node as TimedBlock

        # Vérifier couleur et circuit
        if block.block_color != switch_color:
            continue

        if block.circuit_id != circuit_id:
            continue

        block.set_activated_by(source_id, active)
