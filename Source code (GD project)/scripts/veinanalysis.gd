extends Control

export var veins = preload("res://veincalc/ring-veins.png")
var pxToKm = 10000
var traceMinerals = ["Be", "Pt", "Fe", "Pd", "V", "W"]
var mineralPrices = {
	"H2O": 0.1, 
	"Be": 20.5, 
	"Fe": 0.9, 
	"Pd": 2.5, 
	"Pt": 2.7, 
	"V": 3.0, 
	"W": 6.5
}

var vein_image = veins.get_data()
var vein_size = vein_image.get_size()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getVeinPixelAt(pos: Vector2) -> Color:
	var x = posmod(pos.x, vein_size.x)
	var y = posmod(pos.y, vein_size.y)
	var x1 = posmod(pos.x + 1, vein_size.x)
	var y1 = posmod(pos.y + 1, vein_size.y)
	
	vein_image.lock()
	var p00 = vein_image.get_pixel(x, y)
	var p10 = vein_image.get_pixel(x1, y)
	var p11 = vein_image.get_pixel(x1, y1)
	var p01 = vein_image.get_pixel(x, y1)
	vein_image.unlock()
	
	var cx = fposmod(pos.x, 1.0)
	var cy = fposmod(pos.y, 1.0)

	var pu = lerp(p00, p10, cx)
	var pd = lerp(p01, p11, cx)
	
	var pixel = lerp(pu, pd, cy)
	return pixel

func get_vein_at(pos: Vector2) -> String:
	var p1 = getVeinPixelAt(pos*pxToKm / 1861.0)
	var p2 = getVeinPixelAt(pos*pxToKm / - 2531.0)
	
	var values = [p1.r, p1.g, p1.b, p1.a, p2.r, p2.b, p2.g, p2.a]
		
	var total = 0
	for n in range(traceMinerals.size()):
		var tm = traceMinerals[n]
		values[n] = pow(values[n] / pow(mineralPrices.get(tm, 1), 0.2), 4)
		total += values[n]
		
	var rnd = randf() * total
	var nr = 0
	for n in values:
		rnd -= n
		if rnd < 0:
			return traceMinerals[nr]
		nr += 1
	
	return traceMinerals[0]

