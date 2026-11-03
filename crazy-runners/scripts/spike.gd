
extends Area2D

var triggered: bool = false


func _ready() -> void:
	print("Spike initialisé !")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	print("Contact détecté avec : ", body.name)

	if not body.is_in_group("player"):
		print("L'objet n'appartient pas au groupe player")
		return

	if triggered:
		return

	triggered = true
	print("JOUEUR MORT !")

	get_tree().call_deferred("reload_current_scene")
