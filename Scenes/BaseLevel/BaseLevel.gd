extends Node2D
class_name BaseLevel

signal player_dashed(cooldown : float)
signal player_shoot(ammo_remaining)
signal player_weapon_changed(weapon_name : String, ammo : int, max_ammo : int, index : int)
signal player_new_weapon(weapon_name : String)
signal player_reached_exit
signal wardrobe_access_changed(has_access_flag : bool)

@onready var character_container = $CharacterContainer
@onready var projectile_container = $ProjectileContainer
@onready var rubbish_container = $RubbishContainer
@onready var collectible_container = $CollectibleContainer
@onready var text_container = $TextContainer
var pc_node
var muzzle_flash_scene = preload("res://Scenes/MuzzleFlash/MuzzleFlash.tscn")
var floating_text_scene = preload("res://Scenes/FloatingText/FloatingText2D.tscn")
var current_outfit
var can_exit = false

func add_player(player):
	pc_node = player
	pc_node.projectile_shot.connect(_on_player_character_projectile_shot)
	pc_node.casing_dropped.connect(_on_player_character_casing_dropped)
	pc_node.dash.connect(_on_player_character_dash)
	pc_node.weapon_changed.connect(_on_player_character_weapon_changed)
	pc_node.new_weapon.connect(_on_player_character_new_weapon)
	pc_node.ready.connect(_on_player_ready)
	
	pc_node.position = $PlayerSpawnPoint.position
	$CharacterContainer.add_child(pc_node)

func remove_player():
	pc_node = pc_node as CharacterBody2D
	$CharacterContainer.remove_child(pc_node)
	pc_node = null

func _on_player_ready():
	set_pc_direction(Vector2(1,0))
	if current_outfit:
		set_pc_outfit(current_outfit)

func spawn_projectile(projectile_scene : PackedScene, projectile_position : Vector2, projectile_velocity : Vector2, team : TeamConstants.Teams, damage : float, shot_data : ShotData):
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.position = projectile_position
	projectile_instance.velocity = projectile_velocity
	projectile_instance.damage = damage
	projectile_instance.team = team
	if shot_data: # can be null if grenade projectile want to spawn an explosion
		projectile_instance.penetration_count = shot_data.penetration_count
		projectile_instance.penetration_loss_rate = shot_data.penetration_loss_rate
	if projectile_instance.has_signal("spawned_projectile"):
		projectile_instance.spawned_projectile.connect(spawn_projectile)
	projectile_container.call_deferred("add_child", projectile_instance)

func spawn_muzzle_flash(flash_position : Vector2):
	var muzzle_flash_instance = muzzle_flash_scene.instantiate()
	muzzle_flash_instance.position = flash_position
	projectile_container.call_deferred("add_child", muzzle_flash_instance)

func spawn_casing(casing_scene : PackedScene, casing_position : Vector2):
	var casing_instance = casing_scene.instantiate()
	casing_instance.position = casing_position
	rubbish_container.call_deferred("add_child", casing_instance)

func spawn_floating_text(text_position : Vector2, text_value : String):
	var floating_text_instance = floating_text_scene.instantiate()
	floating_text_instance.position = text_position
	floating_text_instance.text = text_value
	text_container.call_deferred("add_child", floating_text_instance)

func pc_shoots_projectile(projectile_scene : PackedScene, projectile_position : Vector2, projectile_velocity : Vector2, damage : float, shot_data : ShotData):
	spawn_projectile(projectile_scene, projectile_position, projectile_velocity, TeamConstants.Teams.PLAYER, damage, shot_data)
	spawn_muzzle_flash(projectile_position)
	if shot_data.consume_ammo: # the signal is catched by the UI to update the ammo counter
		emit_signal("player_shoot")

func _on_player_character_projectile_shot(projectile_scene : PackedScene, projectile_position : Vector2, projectile_velocity : Vector2, damage : float, shot_data : ShotData):
	pc_shoots_projectile(projectile_scene, projectile_position, projectile_velocity, damage, shot_data)

func _on_player_character_dash(cooldown):
	emit_signal("player_dashed", cooldown)

func _on_player_character_weapon_changed(weapon_name, ammo, max_ammo, index):
	emit_signal("player_weapon_changed", weapon_name, ammo, max_ammo, index)

func _on_player_character_casing_dropped(casing_scene, casing_position):
	spawn_casing(casing_scene, casing_position)

func _on_wardrobe_access_changed(has_access_flag : bool):
	emit_signal("wardrobe_access_changed", has_access_flag)

func set_pc_shooting(shooting_flag : bool = true):
	pc_node.is_shooting = shooting_flag

func set_pc_direction(facing_direction : Vector2):
	pc_node.face_direction(facing_direction)

func set_pc_cycle_next():
	pc_node.cycle_next()

func set_pc_cycle_prev():
	pc_node.cycle_prev()

func set_pc_dashing(dashing_flag : bool):
	pc_node.is_dashing = dashing_flag

func set_pc_outfit(sprite_stack : Texture2D):
	current_outfit = sprite_stack
	if pc_node == null:
		return
	pc_node.set_body_sprite(sprite_stack)

func _on_enemy_damage_taken(enemy_position : Vector2, damage : float):
	spawn_floating_text(enemy_position, str(damage))

func _on_spawner_spawn_enemy(node):
	if node.is_in_group(TeamConstants.ENEMY_GROUP) and node.has_signal("damage_taken"):
		node.damage_taken.connect(_on_enemy_damage_taken)
	character_container.call_deferred("add_child", node)

func _attach_enemy_signals():
	for child in character_container.get_children():
		if child.is_in_group(TeamConstants.ENEMY_GROUP):
			if child.has_signal("damage_taken"):
				child.damage_taken.connect(_on_enemy_damage_taken)

func _attach_spawners_signals():
	for child in $SpawnerContainer.get_children():
		child.spawn_enemy.connect(_on_spawner_spawn_enemy)

func _attach_wardrobe_signals():
	for child in $InteractablesContainer.get_children():
		if child is Wardrobe:
			child.wardrobe_access_changed.connect(_on_wardrobe_access_changed)

func _ready():
	_attach_enemy_signals()
	_attach_spawners_signals()
	_attach_wardrobe_signals()

func _level_complete():
	emit_signal("player_reached_exit")

func _on_exit_area_2d_body_entered(body):
	if body.is_in_group(TeamConstants.PLAYER_GROUP) and can_exit:
		_level_complete()

func _on_player_character_new_weapon(weapon_name):
	emit_signal("player_new_weapon", weapon_name)

func _on_wardrobe_wardrobe_access_changed(has_access_flag):
	emit_signal("wardrobe_access_changed", has_access_flag)

# the purpose of this thing is to fix a bug in the engine -> the player is somewhat detect in the exit area on startup of the level
# while it is not, thus triggering the level_complete and skipping this level
# whith this timer i can skip the early collisions detection in _on_exit_area_2d_body_entered
func _on_can_exit_timer_timeout():
	can_exit = true
