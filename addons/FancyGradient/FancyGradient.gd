tool
class_name FancyGradient
extends Gradient

# FancyGradient Gradient extension

export(Array, Color) var custom_colors = [Color.white, Color.black] setget _update_custom_colors
export(int, "Don't add", "Gamma", "sRGB") var add_corrected_middle_point = 0 setget _update_corrected


func _update():
	var offsets_ = []
	var colors_ = []
	var offset_delta = (1.0 / (len(custom_colors) - 1))
	for i in len(custom_colors) - 1:
		colors_.append(custom_colors[i])
		offsets_.append(offset_delta * i)
		if add_corrected_middle_point:
			offsets_.append(offset_delta * i + offset_delta * 0.5)
			match add_corrected_middle_point:
				1:
					colors_.append(blend_colors_gamma_corrected(custom_colors[i], custom_colors[i + 1], 0.5))
				2:
					colors_.append(blend_colors_srgb(custom_colors[i], custom_colors[i + 1], 0.5))
					
		
	colors_.append(custom_colors[-1])
	offsets_.append(1.0)

	offsets = PoolRealArray(offsets_)
	colors = PoolColorArray(colors_)


func _update_custom_colors(value):
	if len(value)<2:
		return
	custom_colors = value
	_update()


func _update_corrected(value):
	add_corrected_middle_point = value
	_update()


func blend_colors_gamma_corrected(color1: Color, color2: Color, t: float, gamma: float = 2.2) -> Color:
	t = clamp(t, 0.0, 1.0)
	var linear1 = Color(
		pow(color1.r, gamma),
		pow(color1.g, gamma), 
		pow(color1.b, gamma),
		color1.a
	)	
	var linear2 = Color(
		pow(color2.r, gamma),
		pow(color2.g, gamma),
		pow(color2.b, gamma), 
		color2.a
	)
	var blended_linear = Color(
		lerp(linear1.r, linear2.r, t),
		lerp(linear1.g, linear2.g, t),
		lerp(linear1.b, linear2.b, t),
		lerp(linear1.a, linear2.a, t)
	)
	var inv_gamma = 1.0 / gamma
	var result = Color(
		pow(blended_linear.r, inv_gamma),
		pow(blended_linear.g, inv_gamma),
		pow(blended_linear.b, inv_gamma),
		blended_linear.a
	)
	return result

func srgb_to_linear_component(c: float) -> float:
	if c <= 0.04045:
		return c / 12.92
	else:
		return pow((c + 0.055) / 1.055, 2.4)


func linear_to_srgb_component(c: float) -> float:
	if c <= 0.0031308:
		return c * 12.92
	else:
		return 1.055 * pow(c, 1.0/2.4) - 0.055


func srgb_to_linear(color: Color) -> Color:
	return Color(
		srgb_to_linear_component(color.r),
		srgb_to_linear_component(color.g),
		srgb_to_linear_component(color.b),
		color.a
	)


func linear_to_srgb(color: Color) -> Color:
	return Color(
		linear_to_srgb_component(color.r),
		linear_to_srgb_component(color.g),
		linear_to_srgb_component(color.b),
		color.a
	)


func blend_colors_srgb(color1: Color, color2: Color, t: float) -> Color:
	t = clamp(t, 0.0, 1.0)
	var linear1 = srgb_to_linear(color1)
	var linear2 = srgb_to_linear(color2)
	var blended = linear1.linear_interpolate(linear2, t)
	return linear_to_srgb(blended)
