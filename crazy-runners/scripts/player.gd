
extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D

# Paramètres de la caméra
@export_range(0.0, 1.0, 0.01) var player_screen_ratio := 0.30
@export_range(1.0, 20.0, 0.5) var camera_follow_speed := 8.0

# Paramètres du joueur
@export var speed: float = 300.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 980.0

var camera_fixed_y: float
var camera_x: float


func _ready() -> void:
    # Activer l'interpolation physique du joueur
    physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

    # Mémoriser la hauteur initiale
    camera_fixed_y = camera.global_position.y

    # Rendre la caméra indépendante du joueur
    camera.top_level = true

    # Utiliser l'interpolation physique native
    camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

    # Synchroniser caméra et physique
    camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS

    # Désactiver les lissages supplémentaires
    camera.position_smoothing_enabled = false
    camera.rotation_smoothing_enabled = false
    camera.drag_horizontal_enabled = false
    camera.drag_vertical_enabled = false

    camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
    camera.offset = Vector2.ZERO

    # Calcul du décalage horizontal
    var visible_width := get_viewport_rect().size.x / camera.zoom.x
    var offset_x := visible_width * (0.5 - player_screen_ratio)

    # Position initiale
    camera_x = global_position.x + offset_x
    camera.global_position = Vector2(camera_x, camera_fixed_y)

    camera.reset_physics_interpolation()

    # Forcer la caméra principale
    camera.enabled = true
    camera.make_current()


func _physics_process(delta: float) -> void:
    # Gravité
    if not is_on_floor():
        velocity.y += gravity * delta

    # Déplacement horizontal
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed

    # Saut
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

        if $JumpSound.stream != null:
            $JumpSound.play()

    # Déplacement du personnage
    move_and_slide()

    # Animations
    update_animation(direction)

    # Mise à jour caméra
    update_camera(delta)


func update_camera(delta: float) -> void:
    # Largeur visible du niveau
    var visible_width := get_viewport_rect().size.x / camera.zoom.x

    # 30 % derrière, 70 % devant
    var offset_x := visible_width * (0.5 - player_screen_ratio)

    # Position cible
    var target_x := global_position.x + offset_x

    # Lissage calculé pendant la physique
    var weight := 1.0 - exp(-camera_follow_speed * delta)

    camera_x = lerpf(camera_x, target_x, weight)

    # Position de caméra
    camera.global_position = Vector2(camera_x, camera_fixed_y)

    # Garantir la caméra active
    if not camera.is_current():
        camera.make_current()


func update_animation(direction: float) -> void:
    # Orientation
    if direction > 0:
        $AnimatedSprite2D.flip_h = false
    elif direction < 0:
        $AnimatedSprite2D.flip_h = true

    # Animation
    if not is_on_floor():
        $AnimatedSprite2D.play("Jump")
    elif direction != 0:
        $AnimatedSprite2D.play("Walk")
    else:
        $AnimatedSprite2D.play("Idle")
