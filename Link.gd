extends Area2D
signal incorrect
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var a = Vector2()
var b = Vector2()
var color = Color(0.4,0.4,1)
var origins= []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func create_link():
	$Shape.shape = SegmentShape2D.new()
	$Shape.shape.a = origins[0].global_position
	$Shape.shape.b = origins[1].global_position
	$Line.points = [a,b]
	$Line.default_color = color

func _on_Link_area_entered(area):
	if area.has_method("create_link") && (a != area.a && b != area.b && a!=area.b && b!=area.a) &&area.z_index==z_index:
		$Line.default_color = Color(1,0.4,0.4)
		emit_signal("incorrect")
