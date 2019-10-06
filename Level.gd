extends Node2D
signal check_if_left
signal won 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var link_resource = preload("res://Link.tscn")
var start_link = null
var star_highlighted = null
var incorrect = false
var stars = []
var links = []

var test_win=3
var can_win = false


	
func _ready():
	for element in $Stars.get_children():
		if element is Area2D:
			stars.append(element)
			element.connect("start_link",self,"on_star_start_link")
			element.connect("highlighted",self,"on_star_highlight")
			element.connect("link_stars",self,"on_star_link")
			element.connect("update_links",self,"on_update_links")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if check_win():
		if test_win >= 0:
			test_win -=1
			return
		for star in stars:
			if star.dragging:
				test_win = 3
				return
		if !incorrect:
			emit_signal("check_if_left")
			if can_win:
				for s in stars:
					s.block_input = true
					s.show_star()
					yield(get_tree().create_timer(0.2), "timeout")
				yield(get_tree().create_timer(1), "timeout")
				emit_signal("won",stars,links)
				
		else:
			test_win =3
	pass

func on_star_start_link(star):
	star_highlighted=null
	start_link = star
func on_star_highlight(star):
	if start_link != null:
		star_highlighted = star
		
		
func on_star_link(star):
	
	if start_link!=null && star_highlighted !=null && star == start_link :
		start_link.add_neighbour(star_highlighted)
		star_highlighted.add_neighbour(start_link)
	start_link = null
	star_highlighted = null

func on_update_links(): 
	for l in links:
		l.queue_free()
		links.remove(links.find(l))
	var done= []
	for s in stars:
		for n in s.neighbours:
			incorrect = false
			var link = link_resource.instance()
			if [s,n] in done or [n,s] in done:
				continue
			if n.remaining < 0 or s.remaining <0:
				link.color = Color(1,0,0)
			link.a = s.global_position
			link.b = n.global_position
			link.origins = [s,n]
			link.z_index = 1
			link.create_link()
			
			link.connect("incorrect",self,"on_incorrect")
			links.append(link)
			done.append([s,n])
			add_child(link)
			
func on_incorrect():
	incorrect = true
func findall(tab, item):
	var count = 0
	for i in tab:
		if i == item:
			count+=1
	return count
						
func check_win():
	for s in stars:
		if s.remaining !=0:
			return false
	return true
	
func add_star(star):
	stars.append(star)
	star.connect("start_link",self,"on_star_start_link")
	star.connect("highlighted",self,"on_star_highlight")
	star.connect("link_stars",self,"on_star_link")
	star.connect("update_links",self,"on_update_links")
	add_child(star)
	star.position= get_viewport().get_mouse_position()
	star.z_index=2
	star.pickable=false