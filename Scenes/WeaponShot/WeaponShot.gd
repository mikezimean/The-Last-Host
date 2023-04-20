extends Node2D

signal projectile_shot(projectile_scene : PackedScene, angle_offset: float, consume_ammo : bool)

func _shoot_angled_shot(shot_data : ShotData):
	emit_signal("projectile_shot", shot_data.projectile_scene, shot_data.angle_offset, shot_data.use_ammo)

func _shoot_single_shot(shot_data : ShotData):
	var timer_node
	if shot_data.time_offset > 0:
		timer_node = Timer.new()
		add_child(timer_node)
		timer_node.start(shot_data.time_offset)
		await timer_node.timeout
		timer_node.queue_free()
	_shoot_angled_shot(shot_data)

func shoot(shots):
	for shot_data in shots:
		_shoot_single_shot(shot_data)
