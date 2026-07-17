@tool

class_name PriorityToBM extends Node

@export var priority_map : Texture2D
@export var export_path : String = "res://textures/BM.exr"


func get_mean(img : Image) -> Color:
	var mean = Color(0, 0, 0, 0)
	var H = img.get_height()
	var W = img.get_width()
	var N : float = H * W
	for y in H:
		for x in W:
			mean += img.get_pixel(x, y);
	return mean / N

@warning_ignore("unused_private_class_variable")
@export_tool_button("Run !") var _run = func() :
	var img_in = priority_map.get_image()
	var img_out = Image.create_empty(img_in.get_width(), img_in.get_height(), true, Image.FORMAT_RGF)
	
	var mean_priority = get_mean(img_in).r
	
	for y in img_in.get_height():
		for x in img_in.get_width():
			var centered_priority : float = img_in.get_pixel(x, y).r - mean_priority;
			var centered_priority_squared : float = centered_priority * centered_priority
			img_out.set_pixel(x, y, Color(centered_priority, centered_priority_squared, 0, 0))
	
	img_out.clear_mipmaps()
	img_out.generate_mipmaps()
	
	img_out.save_exr(export_path)
