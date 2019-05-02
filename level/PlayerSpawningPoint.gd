tool
extends Position2D

export(float) var RADIUS = 100.0
export(int) var EDGES = 32
export(Color) var LINE_COLOR = Color("#ffffff")

func _ready():
	set_as_toplevel(true)


# Draw spawn circle
func _draw():
	if not Engine.editor_hint:
		return
	var points = PoolVector2Array()
	var angle_step = PI * 2 / EDGES
	for i in range(EDGES + 1):
		var point = Vector2(
			cos(angle_step * i) * RADIUS,
			sin(angle_step * i) * RADIUS
		)
		points.append(point)
	draw_polyline(points, LINE_COLOR, 4.0)