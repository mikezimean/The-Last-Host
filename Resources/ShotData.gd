extends Resource
class_name ShotData

@export var projectile_scene : PackedScene
@export var angle_offset : float = 0
@export var time_offset : float = 0
@export var penetration_count : int = 1 # number of targets the bullet can penetrate
@export_range(0,100) var penetration_loss_rate : float = 100 # % of damage lost after penetrating a target
@export var consume_ammo : bool = true
