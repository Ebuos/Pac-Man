extends Control

@onready var stream_player: VideoStreamPlayer = $VideoStreamPlayer

@export var load_scene: PackedScene

func _ready() -> void:
	stream_player.play()

func _on_video_stream_player_finished() -> void:
	stream_player.play()

func _on_start_button_button_down() -> void:
	get_tree().change_scene_to_packed(load_scene)

func _on_exit_button_button_down() -> void:
	get_tree().quit()
