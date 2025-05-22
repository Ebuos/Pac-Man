extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pac_man: CharacterBody2D = $"."
@onready var lifes_node: Node = $"../GameManager/Lifes"
@onready var blinky: CharacterBody2D = $"../Ghosts/Blinky/Blinky"
@onready var caughting_area: Area2D = $CaughtingArea
@onready var timer: Timer = $Timer
@onready var game_manager: Node = %GameManager
@onready var death_animated_sprite: AnimatedSprite2D = $"../GameManager/DeathAnimatedSprite"
@onready var dying_sfx: AudioStreamPlayer2D = $DyingSfx
@onready var pinky: CharacterBody2D = $"../Ghosts/Pinky/Pinky"
@onready var clyde: CharacterBody2D = $"../Ghosts/Clyde/Clyde"
@onready var inky: CharacterBody2D = $"../Ghosts/Inky/Inky"
@onready var pinky_target: Marker2D = $PinkyTarget
@onready var inky_sub_target: Marker2D = $InkySubTarget
@onready var inky_target: Marker2D = $InkyTarget

@export var default_position: Vector2
@export var cheating := false

const SPEED = 80.0
const JUMP_VELOCITY = -400.0
var life = 3
var direction := Vector2.ZERO
var last_dir: Vector2

func _ready() -> void:
	pac_man.global_position = default_position

func get_ghost_targets_direction():
	pinky_target.global_position = pac_man.global_position + (last_dir * 64)
	inky_sub_target.global_position = pac_man.global_position + (last_dir * 32)
	inky_target.global_position = inky_sub_target.global_position - (blinky.global_position * last_dir)

#Gets direction of movement
func get_input():
	if game_manager.can_start:
		if cheating:
			if Input.is_action_just_pressed("god_mode"):
				if caughting_area.monitoring != true:
					caughting_area.monitoring = true
				elif caughting_area.monitoring != false:
					caughting_area.monitoring = false
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var animation := animated_sprite.get_animation()
		velocity = direction * SPEED
		if direction != Vector2.ZERO:
			last_dir = direction
			animated_sprite.rotation = direction.angle() + PI
			if animation != "move":
				animated_sprite.play("move")
		else:
			pinky_target.global_position = pac_man.global_position
			if animation != "idle":
				animated_sprite.play("idle")
	else:
		animated_sprite.play("idle")

#Moves in selected direction
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	get_ghost_targets_direction()

func eating_mode():
	blinky.frightened_mode()
	pinky.frightened_mode()
	clyde.frightened_mode()
	inky.frightened_mode()
	timer.start()

func _on_caughting_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		if body.frightened:
			game_manager.plus_score += 200
			body.go_home_mode()
		else:
			life -= 1
			lifes_node.get_child(life).hide()
			death_animated_sprite.global_position = global_position
			death_animated_sprite.show()
			death_animated_sprite.play("pac-man-death")
			dying_sfx.play()
			if death_animated_sprite.is_playing():
				game_manager.can_start = false
			body.scatter_mode()
			velocity = Vector2.ZERO
			global_position = default_position
			await get_tree().create_timer(2).timeout
			game_manager.can_start = true
			if life <= 0:
				game_manager.final_menu()

func _on_timer_timeout() -> void:
	caughting_area.monitoring = true
	blinky.after_frightened()
	pinky.after_frightened()
	clyde.after_frightened()
	inky.after_frightened()
	timer.stop()

func _on_clyde_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Clyde"):
		body.scatter_mode()
	await get_tree().create_timer(5).timeout
