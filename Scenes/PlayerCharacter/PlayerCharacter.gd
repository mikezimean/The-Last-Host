extends CharacterBody2D

signal projectile_shot(projectile_scene : PackedScene, projectile_position: Vector2, projectile_velocity: Vector2, shot_data : ShotData)
signal casing_dropped(casing_scene : PackedScene, casing_position : Vector2)
signal dash(cooldown : float)
signal weapon_changed(weapon_name : String, ammo : int, max_ammo : int)
signal new_weapon(weapon_name : String)

@export var acceleration : float = 600
@export var max_speed : float = 125
@export var friction : float = 600
@export var dash_speed : float = 400
@export var current_weapon_iter : int = 0

@onready var animation_tree = $CharacterAnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var weapons : Array[WeaponData] = [preload("res://Resources/Weapons/Handcannon.tres")]
var is_shooting : bool = false
var can_shoot : bool = true
var facing_direction : Vector2
var is_dashing : bool = false
var can_dash : bool = true

#test init weapon ammo 
func _init():
		weapons[0].ammunition_count = weapons[0].max_ammunition

func _update_weapon_sprite():
	var current_weapon : WeaponData = get_current_weapon()
	$WeaponStackedSprite2D.y_offset = current_weapon.y_offset
	$WeaponStackedSprite2D.hframes = current_weapon.sprite_stack_layers
	$WeaponStackedSprite2D.texture = current_weapon.sprite_stack
	$WeaponText2D/Label.text = current_weapon.name
	$WeaponText2D/AnimationPlayer.play("FadeOut")
	face_direction(facing_direction)
	
	if current_weapon.remaining_cooldown > 0:
		$CooldownTimer.start(current_weapon.remaining_cooldown)
	else:
		can_shoot = true
	emit_signal("weapon_changed", current_weapon.name, current_weapon.ammunition_count, current_weapon.max_ammunition, current_weapon_iter)

func pickup_item(item):
	if item is WeaponData:
		item.ammunition_count = item.max_ammunition
		get_current_weapon().remaining_cooldown = $CooldownTimer.time_left
		$CooldownTimer.stop()
		weapons.append(item)
		emit_signal("new_weapon", item.name)
		current_weapon_iter = weapons.size() -1
		_update_weapon_sprite()

func cycle_next():
	get_current_weapon().remaining_cooldown = $CooldownTimer.time_left
	$CooldownTimer.stop()
	
	current_weapon_iter += 1
	if current_weapon_iter >= weapons.size():
		current_weapon_iter = 0
	_update_weapon_sprite()

func cycle_prev():
	get_current_weapon().remaining_cooldown = $CooldownTimer.time_left
	$CooldownTimer.stop()
	
	current_weapon_iter -= 1
	if current_weapon_iter < 0:
		current_weapon_iter = weapons.size() - 1
	_update_weapon_sprite()

func get_current_weapon():
	if weapons.size() == 0:
		return
	if current_weapon_iter >= weapons.size():
		current_weapon_iter = 0
	return weapons[current_weapon_iter]

func set_body_sprite(sprite_stack : Texture2D):
	$BodyStackedSprite2D.texture = sprite_stack

func face_direction(new_direction : Vector2):
	facing_direction = new_direction.normalized()
	animation_tree.set("parameters/Idle/blend_position", facing_direction)
	$BodyStackedSprite2D.sprite_rotation = facing_direction.angle()
	var current_weapon : WeaponData = get_current_weapon()
	$WeaponStackedSprite2D.position = $BodyStackedSprite2D.position + (facing_direction * current_weapon.weapon_offset)
	$WeaponStackedSprite2D.sprite_rotation = facing_direction.angle()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		$WalkingStreamRepeater2D.play_loop()
		if is_dashing and can_dash:
			velocity = input_vector * dash_speed
			$DashingStreamPlayer2D.play()
			can_dash = false
			$DashTimer.start()
			emit_signal("dash", $DashTimer.wait_time)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		$WalkingStreamRepeater2D.stop_loop()
	move()

func move():
	move_and_slide()

func shoot():
	if is_shooting and can_shoot:
		var current_weapon : WeaponData = get_current_weapon()
		if current_weapon.ammunition_count < 1: return
		$WeaponShot.shoot(current_weapon.shots)
		can_shoot = false
		$CooldownTimer.start(current_weapon.cooldown)

func _physics_process(delta):
	move_state(delta)
	shoot()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var current_window = get_window()
		var mouse_position = event.position - Vector2(current_window.content_scale_size / 2) 
		face_direction(mouse_position)

func _on_cooldown_timer_timeout():
	can_shoot = true

func _on_dash_timer_timeout():
	can_dash = true

func _on_weapon_shot_projectile_shot(projectile_scene : PackedScene, shot_data : ShotData):
	var current_weapon : WeaponData = get_current_weapon()
	var projectile_vector = (facing_direction * current_weapon.projectile_speed).rotated(shot_data.angle_offset)
	var projectile_position = position + (facing_direction * (current_weapon.weapon_offset + current_weapon.barrel_offset))
	emit_signal("projectile_shot", projectile_scene, projectile_position, projectile_vector, current_weapon.damage, shot_data)
	if shot_data.consume_ammo:
		current_weapon.ammunition_count -= 1
		await get_tree().create_timer(0.0167).timeout
		var casing_position = position + (facing_direction * current_weapon.weapon_offset)
		emit_signal("casing_dropped", current_weapon.casing_scene, casing_position)
