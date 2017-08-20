tool
extends Node2D

var points = []
var neighbors = []
var velocities = []

var is_pressed = false

var add_timer = null

export(int, 300) var RANGE = 50
export(int, 100) var POINTS = 30 setget rebuild

const INITIAL_VELOCITY = 0.3
const VELOCITY_LIMIT = 0.2
const VELOCITY_CHANGE = 0.005

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	
	if add_timer != null: # this check here becouse we call _ready from rebuild method
		remove_child(add_timer)
		
	add_timer = Timer.new()
	add_timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
	add_child(add_timer)
	
	for i in range(POINTS):
		var x = rand_range(0, get_viewport_rect().size.x)
		var y = rand_range(0, get_viewport_rect().size.y)
		add_point(x, y)

func rebuild(new_points):
	POINTS = new_points
	points.clear()
	neighbors.clear()
	velocities.clear()
	_ready()

func _fixed_process(delta):
	for i in range(points.size()):
		# apply velocity
		points[i].x += velocities[i].x
		points[i].y += velocities[i].y
		
		# change velocity by small random value
		velocities[i].x += rand_range(-VELOCITY_CHANGE, VELOCITY_CHANGE)
		velocities[i].y += rand_range(-VELOCITY_CHANGE, VELOCITY_CHANGE)
		
		# if point is near to edge, then reverse velocity
		if points[i].x > get_viewport_rect().size.x:
			points[i].x = get_viewport_rect().size.x
			velocities[i].x = -velocities[i].x
		if points[i].x < 0:
			points[i].x = 0
			velocities[i].x = -velocities[i].x
		if points[i].y > get_viewport_rect().size.y:
			points[i].y = get_viewport_rect().size.y
			velocities[i].y = -velocities[i].y
		if points[i].y < 0:
			points[i].y = 0
			velocities[i].y = -velocities[i].y
		
		# if point is near to edge, then translate point to opposite edge
		#if points[i].x > get_viewport_rect().size.x:
		#	points[i].x = 0
		#if points[i].x < 0:
		#	points[i].x = get_viewport_rect().size.x
		#if points[i].y > get_viewport_rect().size.y:
		#	points[i].y = 0
		#if points[i].y < 0:
		#	points[i].y = get_viewport_rect().size.y
		
		# limit velocity
		if velocities[i].x > VELOCITY_LIMIT:
			velocities[i].x = VELOCITY_LIMIT
		if velocities[i].x < -VELOCITY_LIMIT:
			velocities[i].x = -VELOCITY_LIMIT
		if velocities[i].y > VELOCITY_LIMIT:
			velocities[i].y = VELOCITY_LIMIT
		if velocities[i].y < -VELOCITY_LIMIT:
			velocities[i].y = -VELOCITY_LIMIT
	
	# recalculate neighbors
	for i in range(points.size()):
		neighbors[i].clear()
		for j in range(i, points.size()):
			var distance = points[i].distance_to(points[j])
			if distance < RANGE:
				neighbors[i].append(Vector2(j, 1 - distance / RANGE)) # x - index of neghbor, y - opacity of the line
	update()

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
		is_pressed = true
	if event.type == InputEvent.MOUSE_BUTTON and not event.is_pressed():
		is_pressed = false
	if event.type == InputEvent.MOUSE_MOTION and is_pressed:
		if add_timer.get_time_left() == 0:
			add_point(event.x, event.y)
			add_timer.set_wait_time(0.5)
			add_timer.set_one_shot(true)
			add_timer.set_active(true)
			add_timer.start()

func _draw():
	for i in range(points.size()):
		for j in range(0, neighbors[i].size()):
			draw_line(points[i], points[neighbors[i][j].x], Color(255, 255, 255, neighbors[i][j].y))
		var op = neighbors[i].size() / (points.size() / 10.0)
		draw_circle(points[i], 1, Color(255, 255, 255, op))

func add_point(x, y):
	points.append(Vector2(x, y))
	neighbors.append([])
	velocities.append(Vector2(rand_range(-INITIAL_VELOCITY, INITIAL_VELOCITY), rand_range(-INITIAL_VELOCITY, INITIAL_VELOCITY)))