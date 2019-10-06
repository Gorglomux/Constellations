extends Area2D

signal link_stars
signal highlighted
signal update_links
signal start_link
signal reparent

export(int) var weight = 1


export(bool) var pickable = false
var highlight = false
var drawing = false

var neighbours = []
var remaining = 0
var dragging = false
var block_input = false
var draw = true
# Called when the node enters the scene tree for the first time.
func _ready():

	$Shape.shape = CircleShape2D.new()
	$Shape.shape.radius = 15+3*weight
	if weight >= 10:
		$Weight.rect_scale*=(weight/13.0)
		$Weight.rect_position.x-=30
	else: 
		$Weight.rect_scale*=((weight+1)/7.0)
	var pos = Vector2($Weight.rect_position.x - $Weight.rect_size.x/1.5,$Weight.rect_position.y - $Weight.rect_size.y/2.35)
	$Weight.rect_position = pos * $Weight.rect_scale
	remaining = weight-neighbours.size()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	remaining = weight-neighbours.size()
	$Weight.text = str(remaining)
	if dragging :
		var m_pos = get_viewport().get_mouse_position()
		emit_signal("update_links")
		global_position = m_pos
		
func show_star():
	$body.show()
	$Shape.hide()
	$Weight.hide()
	draw=false
	update()
func _draw():
	if !draw:
		return
	if highlight :
		draw_circle(Vector2(0,0),15+3*weight+4,Color(1,1,1))
	if pickable:
		draw_circle(Vector2(0,0),15+3*weight+2,Color(1,0.1,0.1))
	else:		
		draw_circle(Vector2(0,0),15+3*weight+2,Color(0.1,0.1,1))


func _input(event):
	if block_input:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && highlight && event.pressed && !pickable:
			highlight = true
			drawing = true
			emit_signal("start_link",self)
			update()
		if event.button_index == BUTTON_LEFT && highlight && !event.pressed && drawing && !pickable:
				highlight = false
				drawing = false
				update()		
				emit_signal("link_stars",self)
		if event.button_index == BUTTON_LEFT && event.pressed && pickable && highlight:
			dragging = true
		if event.button_index == BUTTON_LEFT && !event.pressed && pickable && highlight:
			dragging=false
			emit_signal("reparent",self)
		if event.button_index == BUTTON_MIDDLE && event.pressed && highlight:
			dragging = true
			
		if event.button_index == BUTTON_MIDDLE && !event.pressed && highlight:
			dragging=false


func _on_Star_mouse_entered():
	highlight = true
	update()
	emit_signal("highlighted",self)

func _on_Star_mouse_exited():
	if !drawing:
		highlight = false
		update()
		
func add_neighbour(star):
	if not star in neighbours && star!= self:
		neighbours.append(star)
	remaining = weight-neighbours.size()
	emit_signal("update_links")
