extends Area2D

@onready var game_manager: Node = %GameManager
@onready var waka_sfx: AudioStreamPlayer = $WakaSfx

var colleted: bool = false

func deactivate():
	hide()
	set_deferred("monitoring", false)
	colleted = true
	
func activate():
	show()
	set_deferred("monitoring", true)
	modulate = Color(1, 1, 1)
	colleted = false
	
func _on_body_entered(body: Node2D) -> void:
	if not colleted and body.is_in_group("Pickups"):
		waka_sfx.play()
		game_manager.plus_score += 10
		game_manager.collected_coin()
		deactivate()
