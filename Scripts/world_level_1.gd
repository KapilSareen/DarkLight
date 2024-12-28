extends Node2D

# Use get_node_or_null to prevent errors if nodes are missing
@onready var enemy: CharacterBody2D = get_node_or_null("enemy")
@onready var enemy_2: CharacterBody2D = get_node_or_null("enemy2")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var audio_stream_player_2d: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D2")

var gameOver = false
var can_grenade = true
var grenade_scene = preload("res://Scenes/grenade_2.tscn")
var Click_Position = Vector2.ZERO
var final_position = Vector2.ZERO
var throw_force = 180
@onready var player = get_node_or_null("Player")
@onready var grenade_cooldown: Timer = get_node_or_null("grenade_cooldown")
@onready var animation_player: AnimationPlayer = $CanvasLayer2/AnimationPlayer

var ray_scene = preload("res://Scenes/ray.tscn")
var m
var mid
var time = 0
var r = false
var val = 0
var max_radius = 1200

var grenade

func _ready() -> void:
	if audio_stream_player_2d:
		audio_stream_player_2d.play()

func _process(delta):
	if (not enemy or not is_instance_valid(enemy) or enemy.HEALTH <= 0) and (not enemy_2 or not is_instance_valid(enemy_2) or enemy_2.HEALTH <= 0):
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color.WHITE, 3)
		await get_tree().create_timer(1).timeout
		animation_player.play("win")
	if gameOver:
		return
	
	# Validate player node
	if not player or not is_instance_valid(player):
		return
	
	var pos = player.global_position
	val += delta
	
	# Grenade throw logic
	if Input.is_action_just_pressed("left_mouse_click") && can_grenade:
		can_grenade = false
		if grenade_cooldown:
			grenade_cooldown.start()
		
		Click_Position = get_global_mouse_position()
		final_position = Click_Position

		m = (final_position + 3 * pos) / 4
		m.y -= 0.5 * abs(final_position.y - pos.y) + 0.5 * abs(final_position.x - pos.x)
		
		grenade = grenade_scene.instantiate()
		if audio_stream_player_2d_2:
			audio_stream_player_2d_2.play()
		add_child(grenade)
		grenade.position = pos
		time = 0

	# Grenade movement logic
	if m and grenade and is_instance_valid(grenade):
		grenade.position = bezeir(time, pos)
		time += delta
		if time > 0.5:
			m = null
			time = 0

	# Damage enemies on grenade explosion
	if grenade and is_instance_valid(grenade):
		var radius = 200
		var grenade_position = grenade.position
		
		var damaged = false
		
		# Damage Enemy 1
		if enemy and is_instance_valid(enemy):
			var distance_enemy1 = enemy.position.distance_to(grenade_position)
			if distance_enemy1 < radius:
				if "HEALTH" in enemy:
					enemy.HEALTH -= grenade.damage
				damaged = true
		
		# Damage Enemy 2
		if enemy_2 and is_instance_valid(enemy_2):
			var distance_enemy2 = enemy_2.position.distance_to(grenade_position)
			if distance_enemy2 < radius:
				if "HEALTH" in enemy_2:
					enemy_2.HEALTH -= grenade.damage
				damaged = true
		
		# Free grenade if any damage occurred
		if damaged:
			grenade.queue_free()
			grenade = null

func bezeir(t, pos):
	t = t * 2
	if not m:
		return pos  # Fallback if 'm' is not set
	
	var p1 = pos.lerp(m, t)
	var p2 = m.lerp(final_position, t)
	return p1.lerp(p2, t)

func get_final_position(player_pos: Vector2, click_pos: Vector2, max_radius: float) -> Vector2:
	var distance = player_pos.distance_to(click_pos)
	if distance <= max_radius:
		return click_pos 
	else:
		var direction = (click_pos - player_pos).normalized()
		return player_pos + direction * max_radius  

func _on_grenade_cooldown_timeout() -> void:
	can_grenade = true
	
func hit():
	# Ensure nodes are valid before proceeding
	if not enemy or not is_instance_valid(enemy) or not player or not is_instance_valid(player):
		return
	
	var ray_node = ray_scene.instantiate()
	add_child(ray_node)
	ray_node.position = enemy.position
	var direction = (player.position - ray_node.position).normalized()
	var angle = direction.angle()
	ray_node.rotation = angle
	ray_node.apply_impulse(direction * 400)
