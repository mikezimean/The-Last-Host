extends Control

var tween

var current_ammo : int = 250 : 
	set(value):
		current_ammo = value
		$CurrentAmmo.text = str(current_ammo)
		$CurrentAmmoClone.text = str(current_ammo)

var max_ammo : int = 250 : 
	set(value):
		max_ammo = value
		$MaxAmmo.text = str(max_ammo)


func shoot():
	current_ammo -= 1
	$AnimationPlayer.stop()
	$AnimationPlayer.play("floating_ammo")


func pickup_ammo(new_ammo):
	current_ammo = new_ammo
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property($CurrentAmmo, "label_settings:font_size", 32, 0.5)
	tween.tween_property($CurrentAmmo, "label_settings:font_size", 24, 0.5)
