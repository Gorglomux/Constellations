extends Control
signal refresh
var container_resource = preload("res://Container.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

func add_star(star):
	var container = container_resource.instance()
	container.add_child(star)
	star.position = Vector2(25,25)
	$GridContainer.add_child(container)
	
func reset():
	for child in $GridContainer.get_children():
		child.queue_free()

func _on_refresh_pressed():
	emit_signal("refresh")
