@tool

class_name PriorityToBM extends Node

@export var priority_map : Texture2D
@export var export_path : String = "res://textures/BM.exr"


@warning_ignore("unused_private_class_variable")
@export_tool_button("Run !") var _run = func() :
	var img_in = priority_map.get_image()
	var img_out = Image.create_empty(img_in.get_width(), img_in.get_height(), true, Image.FORMAT_RGF)
	
	# We compute the mean ...
	var mean : float = 0.0
	var N : float = img_in.get_height() * img_in.get_width()
	for y in img_in.get_height():
		for x in img_in.get_width():
			var priority : float = img_in.get_pixel(x, y).r;
			mean += priority / N
	
	for y in img_in.get_height():
		for x in img_in.get_width():
			var priority : float = img_in.get_pixel(x, y).r - mean; # ... so that we center the priority
			var priority_squared : float = priority * priority
			img_out.set_pixel(x, y, Color(priority, priority_squared, 0, 0))
	
	print("Done !")
	
	img_out.clear_mipmaps()
	img_out.generate_mipmaps()
	
	img_out.save_exr(export_path)
