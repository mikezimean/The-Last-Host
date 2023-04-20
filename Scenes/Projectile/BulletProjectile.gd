extends BaseProjectile

func _on_projectile_expired():
	queue_free()

func _on_new_body_collided(opponent_node : Node2D):
	if opponent_node.has_method("hit"):
		opponent_node.hit(damage)
		penetration_count -= 1
		if penetration_count <= 0:
			queue_free()
		else:
			damage = damage * (1-penetration_loss_rate/100)
