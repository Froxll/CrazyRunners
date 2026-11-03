extends CharacterBody2D

enum State {
	IDLE,
	CHARGING,
	FALLING,
	RESTING,
	RISING
}

@export var charge_time: float = 0.25
@export var fall_speed: float = 850.0
@export var rest_time: float = 1.0
@export var rise_speed: float = 180.0
@export var return_to_start: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var damage_area: Area2D = $DamageArea
@onready var damage_shape: CollisionShape2D = $DamageArea/CollisionShape2D

var state: State = State.IDLE
var starting_y: float
var state_timer: float = 0.0
var player_killed: bool = false


func _ready() -> void:
	starting_y = global_position.y

	sprite.play("idle")
	damage_shape.disabled = true

	# Connexion automatique des signaux
	detection_area.body_entered.connect(_on_detection_body_entered)
	damage_area.body_entered.connect(_on_damage_body_entered)


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			pass

		State.CHARGING:
			state_timer += delta

			if state_timer >= charge_time:
				start_falling()

		State.FALLING:
			process_falling(delta)

		State.RESTING:
			state_timer += delta

			if return_to_start and state_timer >= rest_time:
				start_rising()

		State.RISING:
			process_rising(delta)


# Détection du joueur sous le bloc
func _on_detection_body_entered(body: Node2D) -> void:
	if state != State.IDLE:
		return

	if not body.is_in_group("player"):
		return

	# Le joueur doit être sous le Thwomp
	if body.global_position.y <= global_position.y + 10.0:
		return

	state = State.CHARGING
	state_timer = 0.0


# Début de la chute
func start_falling() -> void:
	state = State.FALLING

	sprite.play("fall")

	# Activer la hitbox mortelle
	damage_shape.set_deferred("disabled", false)


# Mouvement vers le sol
func process_falling(delta: float) -> void:
	var motion := Vector2.DOWN * fall_speed * delta

	var collision: KinematicCollision2D = move_and_collide(motion)

	if collision != null:
		var body := collision.get_collider()

		# Vérifier si le bloc frappe le joueur
		if body is Node2D and body.is_in_group("player"):
			kill_player()

		# S'arrêter sur toute collision physique
		land()


# Collision avec la zone mortelle
func _on_damage_body_entered(body: Node2D) -> void:
	if state != State.FALLING:
		return

	if body.is_in_group("player"):
		kill_player()


# Mort du joueur
func kill_player() -> void:
	if player_killed:
		return

	player_killed = true
	get_tree().call_deferred("reload_current_scene")


# Impact sur une surface
func land() -> void:
	state = State.RESTING
	state_timer = 0.0

	sprite.play("rest")

	# Désactiver la hitbox mortelle
	damage_shape.set_deferred("disabled", true)


# Début du retour vers le haut
func start_rising() -> void:
	state = State.RISING
	sprite.play("idle")


# Remontée vers la position initiale
func process_rising(delta: float) -> void:
	var distance := global_position.y - starting_y

	if distance <= 1.0:
		global_position.y = starting_y
		state = State.IDLE
		sprite.play("idle")
		return

	var step := minf(rise_speed * delta, distance)
	var collision := move_and_collide(Vector2.UP * step)

	# Ne pas traverser les obstacles en remontant
	if collision != null:
		state = State.RESTING
		state_timer = 0.0
		sprite.play("rest")
