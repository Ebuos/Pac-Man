extends CharacterBody2D

@export var target: Node2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var pac_man: CharacterBody2D = $"../../../Pac man"
@onready var blinky_scatter_target: Area2D = $"../BlinkyScatterTarget"
@onready var death_area: Area2D = $DeathArea
@onready var home_target: Area2D = $"../../HomeTarget"
@onready var home_marker: Marker2D = $"../../HomeMarker"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = %GameManager

var speed = 60.0
var frightened := false
var direction := Vector2.ZERO

func _ready() -> void:
	animated_sprite.play("move_left")
	target = blinky_scatter_target
	death_area.monitoring = false

func _physics_process(_delta: float) -> void:
	if game_manager.can_start:
		if not frightened:
			animated_sprite.play("move_left")
		else:
			animated_sprite.play("frightened")
		direction = to_local(navigation_agent.get_next_path_position()).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		animated_sprite.play("idle")

func makepath() -> void:
	navigation_agent.target_position = target.global_position

func scatter_mode():
	blinky_scatter_target.monitoring = true
	death_area.monitoring = false
	target = blinky_scatter_target

func chase_mode():
	target = pac_man
	if blinky_scatter_target.monitoring:
			blinky_scatter_target.set_deferred("monitoring", false)

func go_home_mode():
	global_position = home_marker.global_position
	target = home_target
	speed = 60
	death_area.set_deferred("monitoring", false)

func frightened_mode():
	frightened = true
	animated_sprite.play("frightened")
	speed = 40
	death_area.monitoring = true
	blinky_scatter_target.monitoring = true
	target = blinky_scatter_target

func after_frightened():
	animated_sprite.play("move_left")
	speed = 60
	frightened = false
	death_area.monitoring = false
	chase_mode()

func _on_timer_timeout() -> void:
	makepath()

func _on_death_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pickups"):
		game_manager.plus_score += 200
		go_home_mode()

func _on_blinky_scatter_target_body_entered(body: Node2D) -> void:
	if body.is_in_group("Blinky"):
		chase_mode()

func _on_home_target_body_entered(body: Node2D) -> void:
	if body.is_in_group("Blinky"):
		after_frightened()
