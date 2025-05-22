extends Area2D

@onready var game_manager: Node = %GameManager
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var power_up_sfx: AudioStreamPlayer = $PowerUpSfx

var colleted: bool = false

func deactivate():
	hide()
	set_deferred("monitoring", false)
	colleted = true
func activate():
	show()
	set_deferred("monitoring", true)
	colleted = false
	modulate = Color(1, 1, 1)
	
func _on_body_entered(body: Node2D) -> void:
	if not colleted and body.is_in_group("Pickups"):
		power_up_sfx.play()
		body.eating_mode()
		game_manager.plus_score += 50
		game_manager.collected_coin()
		deactivate()
