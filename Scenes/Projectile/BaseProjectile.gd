extends Area2D
class_name BaseProjectile

@export var team : TeamConstants.Teams
@export var damage : float
var velocity : Vector2
var time_since_spawn : float = 0
var collided_bodies : Array = []

# will be set by world when instanciated from shot_data
var penetration_count = 1
var penetration_loss_rate = 100

func _physics_process(delta):
	time_since_spawn += delta
	position += velocity * delta
	rotation = velocity.angle()

func _activate_collision_mask(layer):
	set_collision_mask_value(layer, true)

func _set_mask_layers():
	var layer : int
	match(team):
		TeamConstants.Teams.PLAYER:
			layer = TeamConstants.Layers.ENEMY
		TeamConstants.Teams.ENEMY:
			layer = TeamConstants.Layers.PLAYER
	_activate_collision_mask(layer)

func _ready():
	_set_mask_layers()

func _on_projectile_expired():
	pass

func _on_kill_timer_timeout():
	_on_projectile_expired()

func _on_new_body_collided(_body_node):
	pass

func _on_body_collided(body_node):
	if body_node in collided_bodies:
		return
	collided_bodies.append(body_node)
	_on_new_body_collided(body_node)

func _on_body_entered(body):
	if body.is_in_group(TeamConstants.ENEMY_GROUP) or body.is_in_group(TeamConstants.PLAYER_GROUP):
		_on_body_collided(body)
	else:
		_on_projectile_expired()
