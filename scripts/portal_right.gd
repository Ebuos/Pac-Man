extends Area2D

@onready var portal_left: Area2D = $"../PortalLeft"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PortalBody"):
		body.position.x = portal_left.global_position.x + 20
