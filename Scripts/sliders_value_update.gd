extends HSlider

var value_label : Label

func _ready() -> void:
	value_label = get_child(1) as Label
	value_label.text = "%s" % value

func _on_slider_value_changed(value: float) -> void:
	value_label.text = "%s" % value
