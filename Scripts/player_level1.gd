extends CharacterBody2D

@onready var healthbar: ColorRect = $ColorRect/healthbar
@onready var dash_cooldown_timer: Timer = $Dash_Cooldown 
@onready var knockback: Timer = $Knockback
@onready var enemy: CharacterBody2D = $"../enemy"
@onready var line_to_enemy: Line2D = $Line2D

var gameOver=false
var HEALTH = 100
var dash_cooldown
var NORMAL_SPEED = 180
var DASH_SPEED =1000
var SPEED
var is_dashing = false
const DASH_DURATION = 0.5 
var dash_timer=false
var health_width
var knockback_timer = 1.2
var knockback_strength = 150 
var is_knocked_back = false

enum {
	SURROUND,
	RANDOM,
	HIT,
	RETREAT
}

func _ready() -> void:
	health_width = healthbar.size.x
	SPEED=NORMAL_SPEED
	dash_cooldown=false
	line_to_enemy.visible = true
	$Dash_Right.emitting=false
	$Dash_Front.emitting=false
	$Dash_Left.emitting=false
	$Dash_Back.emitting=false

func _physics_process(delta: float) -> void:
	if gameOver:
		return
	if enemy:
		var direction_to_enemy = (enemy.global_position - global_position).normalized()
	healthbar.size.x = (HEALTH / 100.0) * health_width
	var directionx := Input.get_axis("move_left", "move_right")
	var directiony := Input.get_axis("move_up", "move_down")
	if Input.is_action_just_pressed("dash") and not is_dashing and not dash_cooldown:
		dash_cooldown=true
		dash_cooldown_timer.start()
		is_dashing = true
		dash_timer = DASH_DURATION
	
	if is_dashing:
		
		SPEED = DASH_SPEED
		dash_timer -= delta
		
		if dash_timer <= 0.0:
			SPEED=NORMAL_SPEED
			is_dashing = false
			$Dash_Right.emitting=false
			$Dash_Front.emitting=false
			$Dash_Left.emitting=false
			$Dash_Back.emitting=false
	
	if is_knocked_back:
		move_and_slide()
		return
		
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if velocity.length() > 0:
		if !is_dashing:
			velocity = velocity.normalized() * SPEED
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	if velocity.x != 0:
		if velocity.x > 0:
			$AnimatedSprite2D.animation = "right"
			if is_dashing:
				$Dash_Right.emitting=true
			else:
				$Dash_Right.emitting=false
		if velocity.x < 0:
			$AnimatedSprite2D.animation = "left"
			if is_dashing:
				$Dash_Left.emitting=true
			else:
				$Dash_Left.emitting=false
	elif velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite2D.animation = "down"
			if is_dashing:
				$Dash_Front.emitting=true
			else:
				$Dash_Front.emitting=false
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "up"
			if is_dashing:
				$Dash_Back.emitting=true
			else:
				$Dash_Back.emitting=false
	move_and_slide()
	update_enemy_direction()

func _on_attack_radius_body_entered(body: Node2D) -> void:
	print(body)
	if body.has_method("set_state"):
		body.is_in_attack_area=true
		if body.CAN_ATTACK:
			body.state=HIT
			body.is_hitting = false
			body.CAN_ATTACK=false
			body.cooldown.start()
		else:
			body.state=RANDOM

func _on_attack_radius_body_exited(body: Node2D) -> void:
	if body.has_method("set_state"):
		body.is_in_attack_area=false
		body.set_state(SURROUND)


func _on_player_area_body_entered(body: Node2D) -> void:
	take_damage(body)
	set_retreat(body)
	
	if body.is_in_group("Enemies"):
		body.set_state(RETREAT)
		
func take_damage(body):
	print(body.get_groups())
	if body.is_in_group("damage_enemy"):
		HEALTH= HEALTH - body.damage
		body.queue_free()
		
func set_retreat(body: Node2D):
	var retreat_direction = (global_position - body.global_position).normalized()
	velocity = retreat_direction * knockback_strength
	if body.is_in_group("Enemies"):
		HEALTH -= 10  
		is_knocked_back = true
	$Knockback.start()

func _on_dash_cooldown_timeout():
	dash_cooldown=false

func _on_knockback_timeout() -> void:
		is_knocked_back = false

func update_enemy_direction():
	if enemy:
		var direction_to_enemy = (enemy.global_position - global_position).normalized()
		var arrow_start = global_position + Vector2(0, -250)  # Adjust Y-offset as needed
		line_to_enemy.width = 12  
		
		# Update Line2D points for the main part of the arrow
		line_to_enemy.global_position = arrow_start
		line_to_enemy.points = [
			Vector2.ZERO, 
			direction_to_enemy * 95  # Arrow length (adjust as needed)
		]
		
		var arrowhead_length = 25 
		var arrowhead_angle = direction_to_enemy.angle()
		
		var arrowhead_left = line_to_enemy.points[1] - direction_to_enemy.rotated(-PI / 4) * arrowhead_length
		var arrowhead_right = line_to_enemy.points[1] - direction_to_enemy.rotated(PI / 4) * arrowhead_length
		
		line_to_enemy.add_point(arrowhead_left)
		line_to_enemy.add_point(line_to_enemy.points[1])  
		line_to_enemy.add_point(arrowhead_right)		
		line_to_enemy.visible = true
