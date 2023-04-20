extends PanelContainer

signal outfit_changed(sprite_stack : Texture2D)
signal wardrobe_closed

@export var outfits : Array[OutfitData] = []

@onready var buttons_container = $VBoxContainer/GridContainer

func _on_outfit_button_pressed(sprite_stack : Texture2D):
	emit_signal("outfit_changed", sprite_stack)

func _clear_buttons():
	for button in buttons_container.get_children():
		button.queue_free()

func _update_buttons():
	_clear_buttons()
	for outfit_data in outfits:
		var button_instance = Button.new()
		button_instance.text = outfit_data.name
		button_instance.pressed.connect(_on_outfit_button_pressed.bind(outfit_data.sprite_stack))
		buttons_container.call_deferred("add_child", button_instance)

func _ready():
	_update_buttons()

func _on_close_button_pressed():
	emit_signal("wardrobe_closed")
