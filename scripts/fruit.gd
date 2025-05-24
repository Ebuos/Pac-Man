extends Area2D

@onready var game_manager: Node = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
#AnimationMixer (at: fruit.tscn): 'cherry', Value Track: 'AnimatedSprite2D:animation' blends String types. This is an experimental algorithm.
func appear():
	if game_manager.level == 1:
		animation_player.play("cherry")
	elif game_manager.level == 2:
		animation_player.play("strawberry")
	elif game_manager.level in [3, 4]:
		animation_player.play("orange")
	elif game_manager.level in [5, 6]:
		animation_player.play("apple")
	elif game_manager.level in [7, 8]:
		animation_player.play("melon")
	elif game_manager.level in [9, 10]:
		animation_player.play("galaxian")
	elif game_manager.level in [11, 12]:
		animation_player.play("bell")
	elif game_manager.level >= 13:
		animation_player.play("key")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pickups"):
		game_manager.current_fruit_animation = animation_player.current_animation
		audio_stream_player.play()
		animation_player.play("RESET")
		game_manager.display_fruit()
