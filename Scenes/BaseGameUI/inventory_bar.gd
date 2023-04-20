extends HBoxContainer

var texture_region_offset = {
	"Grenade Launcher" = 0,
	"Handcannon" = 32,
	"Assault Rifle" = 64,
	"Sawn-Off" = 96,
	"Sniper Rifle" = 128,
}

var activated_slots = 1
var current_slot = 0
var slots


func _ready():
	slots = get_children()
	slots[0].highlight = true
	$AnimationPlayer.play("fade_out")


func activate_new_slot(weapon_name : String):
	var new_slot = slots[activated_slots]
	new_slot.visible = true
	new_slot.region_offset = texture_region_offset.get(weapon_name)
	activated_slots += 1


func select_slot(id : int):
	slots[current_slot].highlight = false
	slots[id].highlight = true
	current_slot = id
	$AnimationPlayer.stop()
	$AnimationPlayer.play("fade_out")



