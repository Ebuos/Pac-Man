extends Area2D

@onready var portal_right: Area2D = $"../PortalRight"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PortalBody"):
		body.position.x = portal_right.global_position.x - 20
