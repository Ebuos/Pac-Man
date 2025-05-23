extends Control

@onready var stream_player: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	stream_player.play()

func _on_video_stream_player_finished() -> void:
	stream_player.play()
