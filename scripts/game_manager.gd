extends Node

@onready var pac_man: CharacterBody2D = $"../Pac man"
@onready var score_label: Label = $ScoreLabel
@onready var coins: Node = $"../Pickups/Coins"
@onready var blinky: CharacterBody2D = $"../Ghosts/Blinky/Blinky"
@onready var timer_label: Label = $TimerLabel
@onready var plus_score_label: Label = $PlusScoreLabel
@onready var game_start_sfx: AudioStreamPlayer = $GameStartSfx
@onready var pinky: CharacterBody2D = $"../Ghosts/Pinky/Pinky"
@onready var clyde: CharacterBody2D = $"../Ghosts/Clyde/Clyde"
@onready var inky: CharacterBody2D = $"../Ghosts/Inky/Inky"
@onready var level_label: Label = $LevelLabel
@onready var fruit: Area2D = $"../Pickups/Fruit/Fruit"
@onready var cherry: Sprite2D = $FruitDisplays/VBoxContainer/Cherry
@onready var cherry_label: Label = $FruitDisplays/VBoxContainer/Cherry/CherryLabel
@onready var strawberry: Sprite2D = $FruitDisplays/VBoxContainer/Strawberry
@onready var strawberry_label: Label = $FruitDisplays/VBoxContainer/Strawberry/StrawberryLabel
@onready var orange: Sprite2D = $FruitDisplays/VBoxContainer/Orange
@onready var orange_label: Label = $FruitDisplays/VBoxContainer/Orange/OrangeLabel
@onready var apple: Sprite2D = $FruitDisplays/VBoxContainer/Apple
@onready var apple_label: Label = $FruitDisplays/VBoxContainer/Apple/AppleLabel
@onready var melon: Sprite2D = $FruitDisplays/VBoxContainer/Melon
@onready var melon_label: Label = $FruitDisplays/VBoxContainer/Melon/MelonLabel
@onready var galaxian: Sprite2D = $FruitDisplays/VBoxContainer/Galaxian
@onready var galaxian_label: Label = $FruitDisplays/VBoxContainer/Galaxian/GalaxianLabel
@onready var bell: Sprite2D = $FruitDisplays/VBoxContainer/Bell
@onready var bell_label: Label = $FruitDisplays/VBoxContainer/Bell/BellLabel
@onready var key: Sprite2D = $FruitDisplays/VBoxContainer/Key
@onready var key_label: Label = $FruitDisplays/VBoxContainer/Key/KeyLabel
@onready var end_menu: Control = $EndMenu
@onready var final_score_label: Label = $EndMenu/ColorRect/VBoxContainer/FinalScoreLabel
@onready var final_level_label: Label = $EndMenu/ColorRect/VBoxContainer/FinalLevelLabel
@onready var final_time_label: Label = $EndMenu/ColorRect/VBoxContainer/FinalTimeLabel
@onready var resume_button: Button = $EndMenu/ColorRect/ResumeButton
@onready var appear_audio_sfx: AudioStreamPlayer = $AppearAudioSFX

@export var load_scene: PackedScene

var score: int = 0
var collected_coins := 0
var play_time := 0.0
var plus_score: int
var can_start := false
var can_realy_start := false
var scatters := 0
var level := 1
var current_fruit_animation: String
var cherry_count := 0
var strawberry_count := 0
var orange_count := 0
var apple_count := 0
var melon_count := 0
var galaxian_count := 0
var bell_count := 0
var key_count := 0
var last_input := false
var last_time

func _ready() -> void:
	pac_man.speed = 60.0
	get_tree().call_group("Enemies", "set_speed", 35.0)
	end_menu.hide()
	game_start_sfx.play()
	await get_tree().create_timer(4.25).timeout
	can_realy_start = true
	can_start = true
	end_menu.hide()

func _process(delta: float) -> void:
	play_time += delta
	timer_label.text = format_time(play_time)
	plus_score_label.text = "+" + str(plus_score)
	score_label.text = "Score: " + str(score)
	level_label.text = "Level: " + str(level)
	if collected_coins == 60 or collected_coins == 120:
		fruit.appear()
		appear_audio_sfx.play()
	if end_menu.visible:
		final_score_label.text = "Score: " + str(score)
		final_level_label.text = "Level: " + str(level)
		final_time_label.text = "Time: " + format_time(last_time)
		score += plus_score
		plus_score = 0
		can_start = false
		pac_man.velocity = Vector2.ZERO
		pac_man.pause_timer()
	if Input.is_action_just_pressed("display_menu"):
		pac_man.velocity = Vector2.ZERO
		if not last_input:
			can_start = false
			if not resume_button.visible and pac_man.life > 0:
				resume_button.show()
			end_menu.show()
			last_time = play_time
			last_input = true
		else:
			end_menu.hide()
			if can_realy_start:
				can_start = true
			last_input = false
			pac_man.resume_timer()


func format_time(seconds: float) -> String:
	var minutes = float(seconds) / 60
	var secs = int (seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func collected_coin():
	collected_coins += 1
	if collected_coins >= coins.get_child_count():
		new_level()

func new_level():
	pac_man.global_position = pac_man.default_position
	await get_tree().create_timer(0.001).timeout
	for coin in coins.get_children():
		if coin.has_method("activate"):
			coin.activate()
	collected_coins = 0
	scatters = 0
	level += 1
	if level > 4 and level < 19:
		pac_man.speed = 80.0
		get_tree().call_group("Enemies", "set_speed", 60.0)
	elif level >= 19:
		pac_man.speed = 100.0
		get_tree().call_group("Enemies", "set_speed", 85.0)

func final_menu():
	last_time = play_time
	end_menu.show()
	resume_button.hide()

func _on_score_timer_timeout() -> void:
	score += plus_score
	plus_score = 0

func _on_scatter_timer_timeout() -> void:
	scatters += 1
	if scatters <= 4:
		blinky.scatter_mode()
		pinky.scatter_mode()
		clyde.scatter_mode()
		inky.scatter_mode()

func display_fruit():
	if current_fruit_animation == "cherry":
		if not cherry.visible:
			cherry.show()
		if not cherry_label.visible:
			cherry_label.show()
		cherry_count += 1
		cherry_label.text = str(cherry_count)
		plus_score += 100
	elif current_fruit_animation == "strawberry":
		if not strawberry.visible:
			strawberry.show()
		if not strawberry_label.visible:
			strawberry_label.show()
		strawberry_count += 1
		strawberry_label.text = str(strawberry_count)
		plus_score += 300
	elif current_fruit_animation == "orange":
		if not orange.visible:
			orange.show()
		if not orange_label.visible:
			orange_label.show()
		orange_count += 1
		orange_label.text = str(orange_count)
		plus_score += 500
	elif current_fruit_animation == "apple":
		if not apple.visible:
			apple.show()
		if not apple_label.visible:
			apple_label.show()
		apple_count += 1
		apple_label.text = str(apple_count)
		plus_score += 700
	elif current_fruit_animation == "melon":
		if not melon.visible:
			melon.show()
		if not melon_label.visible:
			melon_label.show()
		melon_count += 1
		melon_label.text = str(melon_count)
		plus_score += 1000
	elif current_fruit_animation == "galaxian":
		if not galaxian.visible:
			galaxian.show()
		if not galaxian_label.visible:
			galaxian_label.show()
		galaxian_count += 1
		galaxian_label.text = str(galaxian_count)
		plus_score += 2000
	elif current_fruit_animation == "bell":
		if not bell.visible:
			bell.show()
		if not bell_label.visible:
			bell_label.show()
		bell_count += 1
		bell_label.text = str(bell_count)
		plus_score += 3000
	elif current_fruit_animation == "key":
		if not key.visible:
			key.show()
		if not key_label.visible:
			key_label.show()
		key_count += 1
		key_label.text = str(key_count)
		plus_score += 5000

func _on_restart_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_button_button_down() -> void:
	get_tree().quit()

func _on_resume_button_button_down() -> void:
	last_input = false
	end_menu.hide()
	if can_realy_start:
		can_start = true
