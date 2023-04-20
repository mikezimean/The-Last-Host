extends Control

const DEFAULT_COLOR = Color(0.80000001192093, 0.80000001192093, 0.80000001192093)
const HIGHLIGHT_COLOR = Color(0, 0.29411765933037, 0)

var highlight = false :
	set(value):
		if value != highlight:
			highlight = value
			var stylebox = $PanelContainer.get_theme_stylebox("panel") as StyleBoxFlat
			stylebox.border_color = HIGHLIGHT_COLOR if highlight else DEFAULT_COLOR
		

