
extends Area2D

# Puissance du ressort
@export var bounce_velocity: float = 700.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    # Animation au repos
    animated_sprite.play("idle")


func _on_body_entered(body: Node2D) -> void:
    # Vérifier que c'est le joueur
    if not body.is_in_group("player"):
        return

    # Vérifier le type de personnage
    if not (body is CharacterBody2D):
        return

    var player := body as CharacterBody2D

    # Ne rebondir que lorsque le joueur descend
    if player.velocity.y < 0.0:
        return

    # Propulser le joueur vers le haut
    player.velocity.y = -bounce_velocity

    # Jouer l'animation du ressort
    animated_sprite.play("bounce")

    print("Spring Pad activé !")


func _on_animated_sprite_2d_animation_finished() -> void:
    # Retour à l'animation normale
    if animated_sprite.animation == "bounce":
        animated_sprite.play("idle")
