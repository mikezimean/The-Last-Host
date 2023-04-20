extends Area2D

const ROTATION_SPEED = 1

@export var weapon : WeaponData

func _ready():
	$StackedSprite2D.y_offset = weapon.y_offset
	$StackedSprite2D.hframes = weapon.sprite_stack_layers
	$StackedSprite2D.texture = weapon.sprite_stack
	
	$StackedSprite2D.position.y += weapon.y_offset


func _process(delta):
	$StackedSprite2D.sprite_rotation_offset += ROTATION_SPEED * delta


func _on_body_entered(body):
	body.pickup_item(weapon)
	queue_free()
