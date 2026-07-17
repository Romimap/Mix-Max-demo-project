@tool

class_name PriorityToBM extends Node

@export var priority_map : Texture2D
@export var export_path : String = "res://textures/BM.exr"

# Precondition : img must be of size 1x1 or more
func get_mean(img : Image) -> Color:
	var mean = Color(0, 0, 0, 0)
	var H = img.get_height()
	var W = img.get_width()
	var N : float = H * W
	for y in H:
		for x in W:
			mean += img.get_pixel(x, y);
	return mean / N


# Precondition : img_in and img_out must be of the same size
func fill_centered_priorities(img_in : Image, img_out : Image) -> void:
	var mean_priority = get_mean(img_in).r
	var H = img_in.get_height()
	var W = img_in.get_width()
	
	for y in H:
		for x in W:
			var in_pixel : Color = img_in.get_pixel(x, y)
			var out_pixel : Color = Color.BLACK
			
			var centered_priority : float = in_pixel.r - mean_priority;
			out_pixel.r = centered_priority
			out_pixel.g = centered_priority * centered_priority
			
			img_out.set_pixel(x, y, out_pixel)


@warning_ignore("unused_private_class_variable")
@export_tool_button("Run !") var _run = func() :
	var img_in = priority_map.get_image()
	var img_out = Image.create_empty(img_in.get_width(), img_in.get_height(), true, Image.FORMAT_RGF)
	
	fill_centered_priorities(img_in, img_out)
	
	img_out.clear_mipmaps()
	img_out.generate_mipmaps()
	
	img_out.save_exr(export_path)
