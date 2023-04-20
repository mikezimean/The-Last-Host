@tool
extends Control

const DEFAULT_COLOR = Color(0.80000001192093, 0.80000001192093, 0.80000001192093)
const HIGHLIGHT_COLOR = Color(0.16078431904316, 0.80000001192093, 0.16078431904316)

@export var region_offset = 0:
	set(value):
		region_offset = value
		if is_ready or Engine.is_editor_hint():
			$PanelContainer/TextureRect.texture.region.position.x = region_offset

var is_ready = false

var highlight = false :
	set(value):
		if value != highlight:
			highlight = value
			var stylebox = $PanelContainer.get_theme_stylebox("panel") as StyleBoxFlat
			stylebox.border_color = HIGHLIGHT_COLOR if highlight else DEFAULT_COLOR


func _ready():
	$PanelContainer/TextureRect.texture.region.position.x = region_offset
	is_ready = true

