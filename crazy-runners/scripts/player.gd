extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 980.0


func _physics_process(delta: float) -> void:
	# Appliquer la gravité lorsque le joueur est en l'air.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Déplacement horizontal.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Saut uniquement si le joueur est sur le sol.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		if $JumpSound.stream != null:
			$JumpSound.play()

	# Appliquer le déplacement et les collisions.
	move_and_slide()

	update_animation(direction)

func update_animation(direction):
	# Gérer la direction du regard (retourner le sprite)
	if direction > 0:
		$AnimatedSprite2D.flip_h = false # Regarde à droite
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true  # Regarde à gauche
		
	# Gérer quelle animation jouer
	if not is_on_floor():
		$AnimatedSprite2D.play("Jump")
	elif direction != 0:
		$AnimatedSprite2D.play("Walk")
	else:
		$AnimatedSprite2D.play("Idle")
