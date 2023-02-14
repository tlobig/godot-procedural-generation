class_name BasicDungeonRoomOrganic
extends BasicDungeonRoom


const FACTOR := 1.0 / 8.0

var _data: Array
var _data_size: int

# the previous Godot 3 code does not work anymore like this
# func _init(rect: Rect2).(rect) -> void:
func _init(rect: Rect2) -> void:
	super._init(rect)
	pass


func _iter_get(_arg) -> Vector2:
	return _data[_iter_index]


func update(rect: Rect2) -> void:
	super.update(rect)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var unit := FACTOR * rect.size
	var order := [
		rect.grow_individual(-unit.x, 0, -unit.x, unit.y - rect.size.y),
		rect.grow_individual(unit.x - rect.size.x, -unit.y, 0, -unit.y),
		rect.grow_individual(-unit.x, unit.y - rect.size.y, -unit.x, 0),
		rect.grow_individual(0, -unit.y, unit.x - rect.size.x, -unit.y)
	]
	var poly = []
	for index in range(order.size()):
		var rect_current: Rect2 = order[index]
		var is_even := index % 2 == 0
		var poly_partial := []
		for r in range(rng.randi_range(1, 2)):
			poly_partial.push_back(Vector2(
				rng.randf_range(rect_current.position.x, rect_current.end.x),
				rng.randf_range(rect_current.position.y, rect_current.end.y)
			))
		poly_partial.sort_custom(Callable(BasicDungeonUtils,"lessv_x" if is_even else "lessv_y"))
		if index > 1:
			poly_partial.reverse()
		poly += poly_partial
	
	_data = []
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var point := Vector2(x, y)
			if Geometry2D.is_point_in_polygon(point, poly):
				_data.push_back(point)
	_data_size = _data.size()


func _iter_is_running() -> bool:
	return _iter_index < _data_size
