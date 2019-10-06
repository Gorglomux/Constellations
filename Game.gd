extends Node2D
var link_resource = preload("res://Link.tscn")
var star_resource = preload("res://star.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level_name = ""
var level = null

func _ready():
	$Camera.disable = false
	$Camera.reset()
	$Interface.reset()
	$Interface.hide()
	$ParallaxBackground2/Back.hide()
	level = null
	for elem in $Map.get_children():
		elem.hide()	
	
	$Interface.connect("refresh",self,"on_refresh")
	for layer in $Map.get_children():
		for button in layer.get_children():
			if button is TextureButton:
				button.connect("pressed",self,"on_load_level", [button])
		

	
var level_completed = 0


func on_load_level(button):
	level_name = button.get_name()
	load_level(level_name)

func on_refresh():
	if level!=null:
		level.queue_free()
		level = null
	load_level(level_name)

func on_back():
	if level != null:
		$Camera.disable = false
		$Camera.reset()
		$Interface.reset()
		$Interface.hide()
		level.queue_free()
		level = null
		for elem in $Map.get_children():
			elem.show()
	else:
		for elem in $Map.get_children():
			elem.hide()	
		$ParallaxBackground2/Back.hide()
		$"Main menu".show()	
		pass
	return
func load_level(level_name):

	if level_name == "":
		return
	$Interface.reset()
	$Camera.reset()
	$Camera.disable = true

	level = load("res://Levels/"+level_name+".tscn").instance()
	level.connect("check_if_left",self,"on_Level_check")
	level.connect("won",self,"on_Level_won")
	for node in level.get_children():
		if node.get_name() =="Stars":
			for star in node.get_children():
				if star.pickable:
					node.remove_child(star)
					$Interface.add_star(star)
			
			
	for element in $Interface/GridContainer.get_children():
		if element is Control:
			for star in element.get_children():
				star.connect("reparent",self,"on_reparent")
	for elem in $Map.get_children():
		elem.hide()
	$Interface.show()
	
	add_child(level)
					
func on_reparent(star):
	if star.position.x < 0:
		for c in $Interface/GridContainer.get_children():

			if c.get_child_count()!=0 && c.get_children()[0] == star:
				c.remove_child(star)

		level.add_star(star)
func on_Level_check():
	level.can_win = true
	for element in $Interface/GridContainer.get_children():
		if element is Control:
			for elem in element.get_children():
				if elem.has_method("show_star"):
					level.can_win = false

func on_Level_won(stars,links):

	$Map.get_node(level_name+"/"+level_name).queue_free()
	for elem in $Map.get_children():
		elem.show()
	level_completed+=1
	$Camera.disable = false
	$Camera.reset()
	level.hide()
	$Interface.hide()
	for s in stars:
		var star = star_resource.instance()
		star.position = Vector2(s.position.x,s.position.y)
		star.show_star()
		star.block_input
		star.z_index += level_completed+2
		$Map.get_node(level_name).add_child(star)
	for l in links:
		var link = link_resource.instance()
		link.a = Vector2(l.a.x,l.a.y)
		link.b = Vector2(l.b.x,l.b.y)
		link.color = l.color 
		link.origins = l.origins
		
		link.z_index += level_completed +1
		link.create_link()

		$Map.get_node(level_name).add_child(link)

	level.queue_free()
	level = null

func _on_Main_menu_pressed():
	for elem in $Map.get_children():
		elem.show()
	$ParallaxBackground2/Back.show()
	$"Main menu".hide()