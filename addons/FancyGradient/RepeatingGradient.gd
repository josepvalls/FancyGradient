@tool
@icon("res://addons/FancyGradient/FancyGradient.svg")
class_name RepeatingGradient
extends Gradient

# RepeatingGradient Gradientextension

@export var repetitions: int = 0 : set = _update_repetitions
@export var gradient: Gradient = null : set = _update_gradient
@export var repeat_back_to_back : bool = true : set = _update_repeat_back_to_back


func _update():
	var offsets_ = []
	var colors_ = []
	var current_offset = 0.0
	for i in repetitions + 1:
		if gradient:
			var gradient_delta = 1.0 / (repetitions + 1)
			for j in gradient.get_point_count():
				if repeat_back_to_back and i % 2 == 1:
					offsets_.append((1.0 - gradient.get_offset(gradient.get_point_count() - j - 1))* gradient_delta + i * gradient_delta)
					colors_.append(gradient.get_color(gradient.get_point_count() - j - 1))
				else:
					offsets_.append(gradient.get_offset(j) * gradient_delta + i * gradient_delta)
					colors_.append(gradient.get_color(j))
	offsets = PackedFloat32Array(offsets_)
	colors = PackedColorArray(colors_)


func _update_repeat_back_to_back(value):
	repeat_back_to_back = value
	_update()


func _update_repetitions(value):
	if value < 0:
		return
	repetitions = value
	_update()


func _update_gradient(value):
	gradient = value
	_update()
