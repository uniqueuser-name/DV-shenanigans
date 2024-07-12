extends Node

var veincalc = load("res://scripts/veinanalysis.gd").new()
var map = preload("res://veincalc/ring-map.png")

onready var sliderX = $XBox/ScrollX
onready var sliderXprec = $XBox/ScrollX2

onready var sliderY = $YBox/ScrollY
onready var sliderYprec = $YBox/ScrollY2

onready var xpos = $posBox/posX
onready var ypos = $posBox/posY

onready var butt = $CalculateButton

onready var MineralContainer = $CenterContainer/MineralsContainer

onready var smallmap = $mapsmall
onready var smallmap_cross = $mapsmall/cross
export var calibration = Vector2(0, 0)
export var segment_length = 5  # Length of each segment for the bars

var image = map.get_data()
var size = image.get_size()

onready var timer = $timer
onready var minerals = ["Fe", "Pd", "Pt", "V", "W", "Be"]
var mineral_bars = {}

export var scalefactor = Vector2(2,2)
# Called when the node enters the scene tree for the first time.
func _ready():
	var sfactor = smallmap.rect_size/scalefactor
	smallmap.rect_pivot_offset = sfactor
	smallmap.rect_size /= scalefactor
	smallmap.rect_position += sfactor
	
	smallmap_cross.scale = Vector2(1,1)/scalefactor
	smallmap_cross.position = sfactor/scalefactor
	
	timer.connect("timeout", self, "_on_Timer_timeout")
	#butt.connect("pressed", self, "_on_CalculateButton_pressed")
	
	# Instance and configure HBoxContainers
	for mineral in minerals:
		var container = preload("res://HUD/MineralTemplate.tscn").instance()
		container.name = mineral + "Container"
		container.get_node("ColorRect").rect_min_size = Vector2(44,0)
		container.get_node("Label").text = mineral
		container.get_node("Label").rect_min_size = Vector2(44, 0)  # Set fixed size for the label
		container.get_node("PercentageLabel").rect_min_size = Vector2(44, 0)  # Set fixed size for the percentage label
		MineralContainer.add_child(container)
		mineral_bars[mineral] = {
			"bar": container.get_node("ColorRect"),
			"percentage": container.get_node("PercentageLabel"),
			"count": 0
		}
		mineral_bars[mineral]["bar"].rect_min_size.y = 1
		mineral_bars[mineral]["percentage"].text = "00.0%"
		mineral_bars[mineral]["count"] = 1
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_image_display()
	for mineral in minerals:
		var count = mineral_bars[mineral]["count"]
		var percentage = (count / 1000.0) * 1000.0
		mineral_bars[mineral]["bar"].rect_min_size.y = count * segment_length
		if percentage == 0:
			mineral_bars[mineral]["percentage"].text = "00.0%"
		else:
			mineral_bars[mineral]["percentage"].text = str((percentage)) + ".0%"
# Function to handle the CalculateButton press
func _on_CalculateButton_pressed():
	for xmod in [-1,0,1]:
		for ymod in [-1,0,1]:
			var x_scanned = int(xpos.text) + xmod
			var y_scanned = int(ypos.text) + ymod
		# Clear previous results
			for mineral in minerals:
				mineral_bars[mineral]["bar"].rect_min_size.y = 1
				mineral_bars[mineral]["percentage"].text = "00.0%"
				mineral_bars[mineral]["count"] = 0
			var scanned_pos = Vector2(x_scanned, y_scanned)
			# Perform 100 calls to get_vein_at
			for _i in range(100):
				var mineral = veincalc.get_vein_at(scanned_pos)
				if mineral in mineral_bars:
					mineral_bars[mineral]["count"] += 1
	timer.start()

# Function to handle the timeout signal of the Timer
func _on_Timer_timeout():
	butt.disabled = false


func texture_to_map():
	pass
# Function to update the display of the map and mapsmall.
func update_image_display():
	var x_center = sliderX.value + sliderXprec.value #+ calibration.x
	var y_center = sliderY.value + sliderYprec.value #+ calibration.y
	
	var size = $map.rect_size
	var smallsize = smallmap.rect_size
	
	var maptexture = ImageTexture.new()
	var display_rect = Rect2(Vector2(x_center - size.x/2, y_center - size.y/2), size)
	var mapimage = image.get_rect(display_rect)
	maptexture.create_from_image(mapimage)
	$map.texture = maptexture
	
	
	
	var small_texture = ImageTexture.new()
	var small_display_rect = Rect2(Vector2((x_center - smallsize.x/2), (y_center - smallsize.y/2)), smallsize)
	var small_image = image.get_rect(small_display_rect)
	
	small_texture.create_from_image(small_image)
	smallmap.texture = small_texture
	smallmap.rect_scale = scalefactor
	
	
	
	xpos.text = str(x_center+calibration.x)
	ypos.text = str(y_center+calibration.y)
