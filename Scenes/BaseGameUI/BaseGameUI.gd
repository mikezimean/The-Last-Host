extends Control

@onready var level_container_node = $SubViewportContainer/SubViewport

@export var ordered_levels : Array[PackedScene] = []

var crosshair_scene = preload("res://Assets/Sourced/Icons/crosshair.png")
var time = [0,0,0] # H,M,S
var can_cycle : bool = true
var current_level : int = 0
var current_level_node
var has_wardrobe_access : bool = false
var current_outfit

func _update_level_counter():
	$LabelLevelCounter.text = "Level %d" % (current_level + 1)

func _on_level_player_dashed(cooldown):
	$DashCooldownIndicator.start(cooldown)
	
func _on_level_player_shoot():
	$AmmoCounter.shoot()

func _on_level_player_weapon_changed(weapon_name, ammo, max_ammo, index):
	$AmmoCounter.current_ammo = ammo
	$AmmoCounter.max_ammo = max_ammo
	$InventoryBar.select_slot(index)

func _on_level_player_new_weapon(weapon_name : String):
	$InventoryBar.activate_new_slot(weapon_name)

func _on_level_wardrobe_access_changed(has_access_flag : bool):
	has_wardrobe_access = has_access_flag
	$InteractInstructions.visible = has_wardrobe_access

func _open_wardrobe():
	%WardrobePanelContainer.show()

func _close_wardrobe():
	%WardrobePanelContainer.hide()

func _clear_levels():
	current_level_node = null
	for level_instance in level_container_node.get_children():
		level_instance.queue_free()

func _load_level(level_scene : PackedScene):
	_clear_levels()
	var level_instance : BaseLevel = level_scene.instantiate()
	level_container_node.call_deferred("add_child", level_instance)
	level_instance.player_dashed.connect(_on_level_player_dashed)
	level_instance.player_shoot.connect(_on_level_player_shoot)
	level_instance.player_weapon_changed.connect(_on_level_player_weapon_changed)
	level_instance.player_new_weapon.connect(_on_level_player_new_weapon)
	level_instance.player_reached_exit.connect(_on_level_player_reached_exit)
	level_instance.wardrobe_access_changed.connect(_on_level_wardrobe_access_changed)
	if current_outfit: 
		level_instance.set_pc_outfit(current_outfit)
	current_level_node = level_instance

func _load_current_level():
	if ordered_levels.size() == 0:
		return
	if current_level >= ordered_levels.size():
		current_level = 0
	var level_scene : PackedScene = ordered_levels[current_level]
	if level_scene != null:
		_load_level(level_scene)

func _on_level_player_reached_exit():
	current_level += 1
	_load_current_level()
	_update_level_counter()

func _on_mouse_entered():
	Input.set_custom_mouse_cursor(crosshair_scene, Input.CURSOR_ARROW, Vector2(16, 16))

func _on_mouse_exited():
	Input.set_custom_mouse_cursor(null)

func _on_wardrobe_panel_container_wardrobe_closed():
	_close_wardrobe()

func _start_cycle_input_cooldown():
	can_cycle = false
	$CycleInputTimer.start()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var current_window = get_window()
		var mouse_position = event.position - Vector2(current_window.content_scale_size / 2) 
		current_level_node.set_pc_direction(mouse_position)
	else:
		if event.is_action_pressed("shoot"):
			current_level_node.set_pc_shooting(true)
		elif event.is_action_released("shoot"):
			current_level_node.set_pc_shooting(false)
		elif event.is_action_pressed("dash"):
			current_level_node.set_pc_dashing(true)
		elif event.is_action_released("dash"):
			current_level_node.set_pc_dashing(false)
		elif event.is_action_pressed("interact"):
			if has_wardrobe_access:
				_open_wardrobe()
		elif event.is_action("cycle_next"):
			if can_cycle:
				current_level_node.set_pc_cycle_next()
				_start_cycle_input_cooldown()
		elif event.is_action("cycle_prev"):
			if can_cycle:
				current_level_node.set_pc_cycle_prev()
				_start_cycle_input_cooldown()

func _on_timer_timeout():
	time[2] += 1
	if time[2] >= 60:
		time[2] -= 60
		time[1]+=1
		if time[1] >= 60:
			time[1] -= 60
			time[0]+=1
	$LabelTime.text = "%02d:%02d:%02d" % time

func _on_cycle_input_timer_timeout():
	can_cycle = true

func _ready():
	_load_current_level()

func _on_wardrobe_panel_container_outfit_changed(sprite_stack):
	current_outfit = sprite_stack
	current_level_node.set_pc_outfit(sprite_stack)
