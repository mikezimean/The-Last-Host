extends Area2D
class_name Wardrobe

signal wardrobe_access_changed(has_access_flag:bool)

func _on_body_entered(body):
	if body.is_in_group(TeamConstants.PLAYER_GROUP):
		emit_signal("wardrobe_access_changed", true)

func _on_body_exited(body):
	if body.is_in_group(TeamConstants.PLAYER_GROUP):
		emit_signal("wardrobe_access_changed", false)
