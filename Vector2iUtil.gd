class_name Vector2iUtil

static func normalize(vi: Vector2i):
	return Vector2i(vi / vi.length())
	
static func direction_to(from: Vector2i, to: Vector2i):
	return normalize(to - from)

static func manhattan_distance(from: Vector2i, to: Vector2i):
	return abs(from.y - to.y) + abs(from.x - to.x)
