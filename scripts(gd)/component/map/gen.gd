class_name Gen
extends Node

# Map Layout Generator by flipcoder

enum Direction {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	ANY
}

# Wall directions
enum Wall {
	LEFT = 1 << 0,
	RIGHT = 1 << 1,
	TOP = 1 << 2,
	BOTTOM = 1 << 3,
}
const WALL_ALL: int = Wall.LEFT | Wall.RIGHT | Wall.TOP | Wall.BOTTOM

const INT_MIN: int = -9223372036854775807
const INT_MAX: int = 9223372036854775807
const EPSILON: float = 0.00001
const EPSILON2 = EPSILON * EPSILON

class Generator:
	static func IsWall(ch: String) -> bool:
		if ch == "#" or ch == "H" or ch == "V" or ch == "|" or ch == "-":
			return true
		return false

	static func IsDoor(ch: String) -> bool:
		if ch == "d" or ch == "D":
			return true
		return false

	static func IsPerimeter(ch: String) -> bool:
		if ch == "v" or ch == "h":
			return true
		return false

	static func IsInnerPerimeter(ch: String) -> bool:
		if ch == "c" or ch == "C":
			return true
		return false


	static func Rotate(vx: int, vy: int) -> Array:
		if vx == 1 and vy == 0:
			return [0, 1]
		if vx == 0 and vy == 1:
			return [-1, 0]
		if vx == -1 and vy == 0:
			return [0, -1]
		if vx == 0 and vy == -1:
			return [1, 0]
		return [0, 0]

	static func RotateBackwards(vx: int, vy: int) -> Array:
		if vx == 1 and vy == 0:
			return [0, -1]
		if vx == 0 and vy == 1:
			return [1, 0]
		if vx == -1 and vy == 0:
			return [0, 1]
		if vx == 0 and vy == -1:
			return [-1, 0]
		return [0, 0]


	static func WalkPerimeter(map, i: int, j: int) -> void:
		var x: int = 0
		var y: int = 0
		var vx: int = 1
		var vy: int = 0
		while true:
			var ch = map[j + y][i + x]
			var next = map[j + y + vy][i + x + vx]
			print("position: " + str(x) + ", " + str(y) + " char: " + ch)
			if IsWall(next):
				if vx == 0 and vy == -1:
					break
				var rot = Rotate(vx, vy)
				vx = rot[0]
				vy = rot[1]
			map[j + y][i + x] = "W"

			x += vx
			y += vy

	static func Run(
		mapWidth: int = 75,
		mapHeight: int = 75,
		startingWidth: int = 15,
		startingHeight: int = 15,
		steps: int = 2000,
		minSize: int = 5,
		maxSize: int = 22,
		variance: int = 10
	) -> LayoutGenerator:

		var map = LayoutGenerator.new(
			mapWidth,
			mapHeight,
			startingWidth,
			startingHeight,
			steps,
			minSize,
			maxSize,
			variance
		)
		map.Run()

		# for j in range(map.MapHeight):
		# 	for i in range(map.MapWidth):
		# 		var ij = map.grid[j][i]
		# 		var left = IsWall(map.At(i - 1, j))
		# 		var right = IsWall(map.At(i + 1, j))
		# 		var above = IsWall(map.At(i, j - 1))
		# 		var below = IsWall(map.At(i, j + 1))
		# 		if ij == ".":
		# 			if left or right:
		# 				map.grid[j][i] = "v"
		# 			elif above or below:
		# 				map.grid[j][i] = "h"

		# for j in range(map.MapHeight):
		# 	for i in range(map.MapWidth):
		# 		var ij = map.grid[j][i]
		# 		var left = map.At(i - 1, j)
		# 		var right = map.At(i + 1, j)
		# 		var above = map.At(i, j - 1)
		# 		var below = map.At(i, j + 1)
		# 		var wleft = IsPerimeter(left)
		# 		var wright = IsPerimeter(right)
		# 		var wabove = IsPerimeter(above)
		# 		var wbelow = IsPerimeter(below)
		# 		if ij == "h" or ij == "v":
		# 			if wleft and wbelow:
		# 				map.grid[j][i] = "."
		# 			elif wleft and wabove:
		# 				map.grid[j][i] = "."
		# 			elif wright and wbelow:
		# 				map.grid[j][i] = "."
		# 			elif wright and wabove:
		# 				map.grid[j][i] = "."

		# for j in range(map.MapHeight):
		# 	for i in range(map.MapWidth):
		# 		var ij = map.grid[j][i]
		# 		var left = map.At(i - 1, j)
		# 		var right = map.At(i + 1, j)
		# 		var above = map.At(i, j - 1)
		# 		var below = map.At(i, j + 1)
		# 		if (ij == ".") and (IsPerimeter(left) or IsPerimeter(right) or IsPerimeter(above) or IsPerimeter(below)):
		# 			if not IsWall(left) and not IsWall(right) and not IsWall(above) and not IsWall(below):
		# 				map.grid[j][i] = "C"

		# for j in range(map.MapHeight):
		# 	for i in range(map.MapWidth):
		# 		var ij = map.grid[j][i]
		# 		var left = IsInnerPerimeter(map.At(i - 1, j))
		# 		var right = IsInnerPerimeter(map.At(i + 1, j))
		# 		var above = IsInnerPerimeter(map.At(i, j - 1))
		# 		var below = IsInnerPerimeter(map.At(i, j + 1))
		# 		if IsInnerPerimeter(ij):
		# 			if left and below:
		# 				map.grid[j][i] = "."
		# 			elif left and above:
		# 				map.grid[j][i] = "."
		# 			elif right and below:
		# 				map.grid[j][i] = "."
		# 			elif right and above:
		# 				map.grid[j][i] = "."
		# 			elif left or right:
		# 				map.grid[j][i] = "c"

		return map;


class LayoutGenerator:
	# Every room in the map, Room index -> Room
	var rooms: Dictionary = {}
	var subrooms: Dictionary = {}
	var mainRooms: Dictionary = {}

	var rand: RandomNumberGenerator

	# adjacency list
	var adjacencyList: Dictionary = {}

	var MapWidth: int
	var MapHeight: int
	var StartingWidth: int
	var StartingHeight: int
	var STEPS: int
	var MinSize: int
	var MaxSize: int
	var Variance: int

	var StartRoom: int
	var EndRoom: int
	var RoomPath: Array # path in room IDs from start to end
	var InRoomPath: Dictionary = {} # set of room IDs in path

	# Parallel 2d arrays for grid characters, ownership (which room # owns
	#   this char), and occlusion (approximate distance of tile from center
	#   of room normalized to 0-1)),
	var grid: Array
	var roomID: Array
	var occlusion: Array

	func FindFarNode() -> int:
		var farNode: int = -1
		var maxEccentricity: int = INT_MIN

		for node in adjacencyList.keys():
			var eccentricity = CalculateEccentricity(node)
			if eccentricity > maxEccentricity:
				maxEccentricity = eccentricity
				farNode = node

		return farNode

	func FindCenterNode() -> int:
		var centerNode: int = -1
		var minEccentricity: int = INT_MAX

		for node in adjacencyList.keys():
			var eccentricity = CalculateEccentricity(node)
			if eccentricity < minEccentricity:
				minEccentricity = eccentricity
				centerNode = node

		return centerNode

	func CalculateEccentricity(startNode: int) -> int:
		var shortestDistances: Dictionary = {}

		var queue: Array = []
		queue.append(startNode)
		shortestDistances[startNode] = 0

		while queue.size() > 0:
			var current = queue.pop_front()

			var neighbors: Array = []
			if adjacencyList.has(current):
				neighbors = adjacencyList[current]
			else:
				print("Cannot find " + str(current) + " in adjacency list")
			for neighbor in neighbors:
				if not shortestDistances.has(neighbor):
					shortestDistances[neighbor] = shortestDistances[current] + 1
					queue.append(neighbor)

		var maxDistance: int = 0
		for distance in shortestDistances.values():
			if distance > maxDistance:
				maxDistance = distance

		return maxDistance

	func FindFurthestNodes() -> Array:
		var node1: int = -1
		var node2: int = -1
		var maxDistance: int = -1

		for node in adjacencyList.keys():
			var shortestDistances = CalculateShortestDistances(node)

			for kvp_key in shortestDistances.keys():
				var kvp_value = shortestDistances[kvp_key]
				if kvp_value > maxDistance:
					maxDistance = kvp_value
					node1 = node
					node2 = kvp_key

		return [node1, node2]

	func FindPath(start: int, end: int) -> Array:
		var stack: Array = []
		var parentMap: Dictionary = {}
		var path: Array = []

		stack.append(start)
		parentMap[start] = -1

		while stack.size() > 0:
			var current = stack.pop_back()

			if current == end:
				var node = end
				while node != -1:
					path.append(node)
					node = parentMap[node]
				path.reverse()
				return path

			if adjacencyList.has(current):
				for neighbor in adjacencyList[current]:
					if not parentMap.has(neighbor):
						stack.append(neighbor)
						parentMap[neighbor] = current

		return []

	func CalculateShortestDistances(startNode: int) -> Dictionary:
		var shortestDistances: Dictionary = {}

		var queue: Array = []
		queue.append(startNode)
		shortestDistances[startNode] = 0

		while queue.size() > 0:
			var current = queue.pop_front()
			var neighbors: Array = []
			if adjacencyList.has(current):
				neighbors = adjacencyList[current]
			else:
				print("Cannot find " + str(current) + " in adjacency list")
			for neighbor in neighbors:
				if not shortestDistances.has(neighbor):
					shortestDistances[neighbor] = shortestDistances[current] + 1
					queue.append(neighbor)

		return shortestDistances

	func _init(
		mapWidth: int = 75,
		mapHeight: int = 75,
		startingWidth: int = 15,
		startingHeight: int = 15,
		steps: int = 2000,
		minSize: int = 6,
		maxSize: int = 22,
		variance: int = 10
	):
		assert(minSize >= 5)
		assert(minSize <= maxSize)

		MapWidth = mapWidth
		MapHeight = mapHeight
		StartingWidth = startingWidth
		StartingHeight = startingHeight
		STEPS = steps
		MinSize = minSize
		MaxSize = maxSize
		Variance = variance

	func Run() -> void:
		self.rand = RandomNumberGenerator.new()
		self.rand.randomize()

		# Initialize our 2d arrays
		grid = []
		roomID = []
		occlusion = []

		for i in range(MapHeight):
			var grow: Array = []
			var rrow: Array = []
			var orow: Array = []
			for j in range(MapWidth):
				grow.append(" ")
				rrow.append(0)
				orow.append(0.0)
			grid.append(grow)
			roomID.append(rrow)
			occlusion.append(orow)

		# Create our first room
		var rw = StartingWidth
		var rh = StartingHeight
		var root = Room.new(self, MapWidth / 2 - rw / 2, MapHeight / 2 - rh / 2, rw, rh)
		root.Draw(false)
		rooms[root.id] = root
		mainRooms[root.id] = root
		var room = root
		var steps: int = 0

		# Iterate through our rooms, extruding them semi-randomly
		while steps < STEPS:
			if rand.randf() < 0.5:
				var cons = room.connect[rand.randi_range(0, 3)]
				if cons.size() > 0:
					room = cons.values()[rand.randi_range(0, cons.size() - 1)]

			var r = room.Extrude()
			if r != null:
				rooms[r.id] = r
				mainRooms[r.id] = r
				room = mainRooms.values()[rand.randi_range(0, mainRooms.size() - 1)]
			steps += 1

		# Build adjacency list
		for r in mainRooms.values():
			for d in range(4):
				for r2 in r.connect[d].values():
					if adjacencyList.has(r.id):
						adjacencyList[r.id].append(r2.id)
					else:
						var list: Array = []
						list.append(r2.id)
						adjacencyList[r.id] = list

		var roomsCopy = mainRooms.duplicate()
		# Iterate through our rooms, splitting them into subrooms if possible
		for r in roomsCopy.values():
			var w2: int = int(floor(r.w / 2.0))
			var h2: int = int(floor(r.h / 2.0))

			if w2 < 6 or h2 < 6:
				continue

			if not r.CanSplit:
				continue # room has a shape where it can't split

			# Directions allowing subroom splitting (meaning they aren't occupied)
			var left: bool = r.connect[Direction.LEFT].size() == 0
			var right: bool = r.connect[Direction.RIGHT].size() == 0
			var up: bool = r.connect[Direction.UP].size() == 0
			var down: bool = r.connect[Direction.DOWN].size() == 0

			if left and up and down:
				var sub = Room.new(self, r.x, r.y, w2, r.h, false, Wall.RIGHT)
				if sub.Draw(false, WALL_ALL, 0, false):
					rooms[sub.id] = sub
					subrooms[sub.id] = sub
					sub.HSplit()
				else:
					print("left up down BAD")
			elif right and up and down:
				var sub = Room.new(self, r.x + r.w - w2, r.y, w2, r.h, false, Wall.LEFT)
				if sub.Draw(false, WALL_ALL, 0, false):
					rooms[sub.id] = sub
					subrooms[sub.id] = sub
					sub.HSplit()
				else:
					print("right up down BAD")
			elif up and left and right:
				var sub = Room.new(self, r.x, r.y, r.w, h2, false, Wall.BOTTOM)
				if sub.Draw(false, WALL_ALL, 0, false):
					rooms[sub.id] = sub
					subrooms[sub.id] = sub
					sub.VSplit()
				else:
					print("up left right BAD")
			elif down and left and right:
				var sub = Room.new(self, r.x, r.y + h2, r.w, h2, false, Wall.TOP)
				if sub.Draw(false, WALL_ALL, 0, false):
					rooms[sub.id] = sub
					subrooms[sub.id] = sub
					sub.VSplit()
				else:
					print("down left right BAD")
			else:
				if left and up:
					var sub = Room.new(self, r.x, r.y, w2, h2, false, Wall.RIGHT | Wall.BOTTOM)
					if not sub.Draw(false, WALL_ALL, 0, false):
						print("left up BAD")
					else:
						rooms[sub.id] = sub
						subrooms[sub.id] = sub
				if left and down:
					var sub = Room.new(self, r.x, r.y + r.h - h2, w2, h2, false, Wall.RIGHT | Wall.TOP)
					if not sub.Draw(false, WALL_ALL, 0, false):
						print("left down BAD")
					else:
						rooms[sub.id] = sub
						subrooms[sub.id] = sub
				if right and down:
					var sub = Room.new(self, r.x + r.w - w2, r.y + r.h - h2, w2, h2, false, Wall.LEFT | Wall.TOP)
					if not sub.Draw(false, WALL_ALL, 0, false):
						print("right down BAD")
					else:
						rooms[sub.id] = sub
						subrooms[sub.id] = sub
				if right and up:
					var sub = Room.new(self, r.x + r.w - w2, r.y, w2, h2, false, Wall.LEFT | Wall.BOTTOM)
					if not sub.Draw(false, WALL_ALL, 0, false):
						print("right up BAD")
					else:
						rooms[sub.id] = sub
						subrooms[sub.id] = sub

		for r in mainRooms.values():
			var eccentricity = CalculateEccentricity(r.id)
			r.Eccentricity = eccentricity

		var furthestNodes = FindFurthestNodes()

		StartRoom = furthestNodes[0]
		EndRoom = furthestNodes[1]

		# Player start
		var start = mainRooms[furthestNodes[0]]
		var end = mainRooms[furthestNodes[1]]
		var cx = start.x + start.w / 2
		var cy = start.y + start.h / 2

		RoomPath = FindPath(StartRoom, EndRoom)
		for r_id in RoomPath:
			InRoomPath[r_id] = true

		for rr in mainRooms.values():
			if not rr.DoorCheck():
				print("Checking...")
				for j in range(rr.y + 1, rr.y + rr.h - 1):
					for i in range(rr.x + 1, rr.x + rr.w - 1):
						At(i, j, "X")
				Print()
				print("WARNING: Map has errors.")
				break

	func Print() -> void:
		for j in range(MapHeight):
			var line: String = ""
			for i in range(MapWidth):
				line += grid[j][i]
			print(line)

	func ToString() -> String:
		var s: String = ""
		for j in range(MapHeight):
			for i in range(MapWidth):
				s += self.At(i,j)
			s += "\n"
		return s

	# This function gets or sets the character, the occlusion, and the
	#   room ownership (what character belongs to which room ID) at the given
	#   location.
	func At(i: int, j: int, ch: String = "", occlude: float = -1.0, own: int = 0) -> String:
		if i < 0 or j < 0 or i >= MapWidth or j >= MapHeight:
			return ""
		if ch != "": # set character to ch
			if i < 0 or j < 0 or i >= MapWidth or j >= MapHeight:
				return ""
			grid[j][i] = ch
			if occlude >= -EPSILON:
				occlusion[j][i] = occlude
			if own > 0:
				roomID[j][i] = own
			return ch

		# otherwise, get character at i, j
		return grid[j][i]

	func RoomAt(i: int, j: int):
		if i < 0 or j < 0 or i >= MapWidth or j >= MapHeight:
			return null
		var own = roomID[j][i]
		if own == 0:
			return null
		return rooms[own]

	# Get/set the ownership value at the given location
	func RoomIndexAt(i: int, j: int, own: int = -1) -> int:
		if j < 0 or i < 0 or j >= MapHeight or i >= MapWidth:
			return 0

		if own != -1:
			roomID[j][i] = own
			return own

		return roomID[j][i]

	func InBounds(x: int, y: int, w: int, h: int) -> bool:
		if x < 0 or x + w >= MapWidth:
			return false
		if y < 0 or y + h >= MapHeight:
			return false
		return true

	func CheckSpace(x: int, y: int, w: int, h: int) -> bool:
		for j in range(y, y + h):
			for i in range(x, x + w):
				if grid[j][i] != " ":
					return false
		return true


# Representation of our Room in our ASCII layout
class Room:
	static var nextRoomId: int = 1

	# Unique room ID
	var id: int

	# Room dimensions
	var x: int
	var y: int
	var w: int
	var h: int

	# Character to use for floor (.)
	var floor: String

	# Door flags (Wall.LEFT, Wall.RIGHT, Wall.TOP, Wall.BOTTOM)
	var doors: int

	# Dictionary of rooms connected to this room in each direction
	var connect: Array

	# Reference to our ASCII layout gen
	var gen

	# Random number gen
	var rand: RandomNumberGenerator

	var Eccentricity: int = 0 # calculated after generation

	# If we do any cuts, mark this to false so we can no longer split
	var CanSplit: bool = true

	var HasPillars: bool = false

	# This function draws a specific room at the given location with the given
	#   floor character.
	# It draws the given walls around the room, and only blits existing values
	#   unless clobber is set.
	# It also ignores the given walls when drawing
	static func DrawRoom(gen, rid: int, x: int, y: int, w: int, h: int, floor: String = ".", clobber: bool = true, walls: int = 15, ignore: int = 0) -> bool:
		for j in range(y, y + h):
			for i in range(x, x + w):
				if (i == x and (walls & Wall.LEFT) != 0) or \
				   (i == x + w - 1 and (walls & Wall.RIGHT) != 0) or \
				   (j == y and (walls & Wall.TOP) != 0) or \
				   (j == y + h - 1 and (walls & Wall.BOTTOM) != 0):
					if not clobber or gen.At(i, j) == " ":
						# if corner
						if (i == x and j == y) or (i == x + w - 1 and j == y) or \
						   (i == x and j == y + h - 1) or (i == x + w - 1 and j == y + h - 1):
							gen.At(i, j, "#")
						# if horizontal wall
						elif j == y or j == y + h - 1:
							gen.At(i, j, "H")
						# if vertical wall
						elif i == x or i == x + w - 1:
							gen.At(i, j, "V")
						else:
							gen.At(i, j, "#")
				elif (i == x and (ignore & Wall.LEFT) != 0) or \
					 (i == x + w - 1 and (ignore & Wall.RIGHT) != 0) or \
					 (j == y and (ignore & Wall.TOP) != 0) or \
					 (j == y + h - 1 and (ignore & Wall.BOTTOM) != 0):
					continue
				else:
					var dist_from_center: float = sqrt(pow(i - x - w / 2, 2) + pow(j - y - h / 2, 2))
					var radius: float = sqrt(pow(w / 2, 2) + pow(h / 2, 2))
					var occlusion_val: float = dist_from_center / radius
					gen.At(i, j, floor, occlusion_val, rid)
		return true

	func _init(gen, x: int, y: int, w: int, h: int, sub: bool = false, doors: int = 0):
		self.gen = gen
		# Get the next room ID
		# Since drawing a room can fail, you can decrement this when
		#   destroying the room you just created.
		id = nextRoomId
		nextRoomId += 1
		self.rand = RandomNumberGenerator.new()
		self.rand.randomize()
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		floor = "."
		self.doors = doors
		connect = []
		for i in range(4):
			connect.append({})

	# This function checks if a room can be drawn at the given location
	func CheckRoom(gen, x: int, y: int, w: int, h: int, ignore: int = 0) -> bool:
		for j in range(y, y + h):
			for i in range(x, x + w):
				var ch = gen.At(i, j)
				if ch == "":
					return false
				if (i == x and (ignore & Wall.LEFT) != 0) or \
				   (i == x + w - 1 and (ignore & Wall.RIGHT) != 0) or \
				   (j == y and (ignore & Wall.TOP) != 0) or \
				   (j == y + h - 1 and (ignore & Wall.BOTTOM) != 0):
					continue
				if ch != " ":
					return false
		return true

	# This function checks if this room can be drawn at the given location.
	# It ignores the given walls when checking.
	func Check(ignore: int = 0) -> bool:
		return CheckRoom(self.gen, x, y, w, h, ignore)

	# This function draws a specific room at the given location with the given
	#   floor character.
	# It draws the given walls around the room, and only blits existing values
	#   unless clobber is set.
	# It also ignores the given walls when drawing
	func Draw(check: bool = true, walls: int = 15, ignore: int = 0, clobber: bool = true) -> bool:
		if check:
			if not CheckRoom(self.gen, x, y, w, h, ignore):
				return false

		# Attempt to draw the room
		var result: bool = DrawRoom(self.gen, id, x, y, w, h, floor, clobber, walls, ignore)
		if not result:
			return false

		# Add random doors on each given side
		if doors != 0:
			var xEntry: int = rand.randi_range(1, w - 3)
			var yEntry: int = rand.randi_range(1, h - 3)
			if (doors & Wall.LEFT) != 0:
				self.gen.At(x, y + yEntry, "|")
			if (doors & Wall.RIGHT) != 0:
				self.gen.At(x + w - 1, y + yEntry, "|")
			if (doors & Wall.TOP) != 0:
				self.gen.At(x + xEntry, y, "-")
			if (doors & Wall.BOTTOM) != 0:
				self.gen.At(x + xEntry, y + h - 1, "-")

		return result

	func CheckCut(x: int, y: int, w: int, h: int) -> bool:
		if x < self.x or x + w > self.x + self.w or \
		   y < self.y or y + h > self.y + self.h:
			return false

		for j in range(y, y + h):
			for i in range(x, x + w):
				var ch = self.gen.At(i, j)
				if ch != "." and ch != "H" and ch != "V":
					return false

		return true

	# Subtract a section inside the room
	func Cut(x: int, y: int, w: int, h: int, mid: String = ",") -> bool:
		if not CheckCut(x, y, w, h):
			return false

		CanSplit = false

		for j in range(y, y + h):
			for i in range(x, x + w):
				# corners
				if i == x and j == y:
					self.gen.At(i, j, "#")
				elif i == x + w - 1 and j == y:
					self.gen.At(i, j, "#")
				elif i == x and j == y + h - 1:
					self.gen.At(i, j, "#")
				elif i == x + w - 1 and j == y + h - 1:
					self.gen.At(i, j, "#")
				# vertical wall
				elif i == x or i == x + w - 1:
					self.gen.At(i, j, "V")
				# horizontal wall
				elif j == y or j == y + h - 1:
					self.gen.At(i, j, "H")
				# enclosed space (do not draw here)
				else:
					self.gen.At(i, j, mid)

		return true

	func Stylize() -> bool:
		var r: bool = false # If ANY part succeeds, we need to disable splits
		if w < 8 or h < 8:
			return false
		var randomValue: float = rand.randf()
		if randomValue < 0.2:
			var maxInset: int = min(w, h) / 2 - 1
			var inset: int
			if maxInset <= 3:
				return false
			inset = rand.randi_range(3, maxInset - 1)
			if Cut(x + inset, y + inset, w - inset * 2, h - inset * 2):
				r = true
		elif randomValue < 0.3:
			if MakePillars():
				r = true
		if r:
			CanSplit = false
		return r

	func MakePillars() -> bool:
		if w < 7 or h < 7:
			return false
		self.gen.At(x + 2, y + 2, "P")
		self.gen.At(x + w - 3, y + 2, "P")
		self.gen.At(x + 2, y + h - 3, "P")
		self.gen.At(x + w - 3, y + h - 3, "P")
		CanSplit = false
		HasPillars = true
		return true

	# This function returns a random size for a new room, given the current
	#  room's size and the global min/max size and variance.
	func RandomSize() -> Array:
		var w: int = rand.randi_range(self.gen.MinSize, self.gen.MaxSize - 1)
		var h: int = rand.randi_range(self.gen.MinSize, self.gen.MaxSize - 1)
		# Variance works by gradually adjust the size of the new room by a
		#   specific amount within the range of the variance.
		return [w, h]

	func DoorBlocked(i: int, j: int, ch: String) -> bool:
		var g
		if ch == "|":
			g = self.gen.At(i - 1, j)
			if g != "." and g != " ":
				return true
			g = self.gen.At(i + 1, j)
			if g != "." and g != " ":
				return true
		elif ch == "-":
			g = self.gen.At(i, j - 1)
			if g != "." and g != " ":
				return true
			g = self.gen.At(i, j + 1)
			if g != "." and g != " ":
				return true
		return false

	# Attempt to create a new adjacent room in the direction given and return
	#   it.  Failures return null.  If the direction is not specified, a random
	#  direction is chosen.
	func Extrude(dir: int = Direction.ANY):
		if dir == Direction.ANY:
			dir = rand.randi_range(0, 3)

		if dir == Direction.LEFT:
			var entry: int = rand.randi_range(1, h - 2)
			var sz = RandomSize()
			var rw: int = sz[0]
			var rh: int = sz[1]
			var rx: int = x - rw + 1
			var ry_min: int = y + entry - rh + 2
			var ry_max: int = y + entry - 1
			var ry: int = rand.randi_range(ry_min, ry_max - 1)
			if not self.gen.InBounds(rx, ry, rw, rh):
				return null
			if not self.gen.CheckSpace(rx + 1, ry + 1, rw - 2, rh - 2):
				return null
			var r = Room.new(self.gen, rx, ry, rw, rh)
			if r.Check(WALL_ALL):
				self.gen.At(x, y + entry, "|")
				r.connect[Direction.RIGHT][id] = self
				self.connect[dir][r.id] = r
				if not r.Draw(false):
					print("Drawing failed.")
				if entry < h - 2:
					if not DoorBlocked(x, y + entry + 1, "|"):
						self.gen.At(x, y + entry + 1, "|")
				r.Stylize()
				return r
			else:
				nextRoomId -= 1
				return null


		elif dir == Direction.RIGHT:
			var entry: int = rand.randi_range(1, h - 2)
			var sz = RandomSize()
			var rw: int = sz[0]
			var rh: int = sz[1]
			var rx: int = x + w - 1
			var ry_min: int = y + entry - rh + 2
			var ry_max: int = y + entry - 1
			var ry: int = rand.randi_range(ry_min, ry_max - 1)
			if not self.gen.InBounds(rx, ry, rw, rh):
				return null
			if not self.gen.CheckSpace(rx + 1, ry + 1, rw - 2, rh - 2):
				return null
			var r = Room.new(self.gen, rx, ry, rw, rh)
			if r.Check(WALL_ALL):
				self.gen.At(x + w - 1, y + entry, "|")
				r.connect[Direction.LEFT][id] = self
				self.connect[dir][r.id] = r
				if not r.Draw(false):
					print("Drawing failed.")
				if entry < h - 2:
					if not DoorBlocked(x + w - 1, y + entry + 1, "|"):
						self.gen.At(x + w - 1, y + entry + 1, "|")
				r.Stylize()
				return r
			else:
				nextRoomId -= 1
				return null

		elif dir == Direction.UP:
			var entry: int = rand.randi_range(1, w - 2)
			var sz = RandomSize()
			var rw: int = sz[0]
			var rh: int = sz[1]
			var ry: int = y - rh + 1
			var rx_min: int = x + entry - rw + 2
			var rx_max: int = x + entry - 1
			var rx: int = rand.randi_range(rx_min, rx_max - 1)
			if not self.gen.InBounds(rx, ry, rw, rh):
				return null
			if not self.gen.CheckSpace(rx + 1, ry + 1, rw - 2, rh - 2):
				return null
			var r = Room.new(self.gen, rx, ry, rw, rh)
			if r.Check(WALL_ALL):
				self.gen.At(x + entry, y, "-")
				r.connect[Direction.DOWN][id] = self
				self.connect[dir][r.id] = r
				if not r.Draw(false):
					print("Drawing failed.")
				if entry < w - 2:
					if not DoorBlocked(x + entry + 1, y, "-"):
						self.gen.At(x + entry + 1, y, "-")
				r.Stylize()
				return r
			else:
				nextRoomId -= 1
				return null

		elif dir == Direction.DOWN:
			var entry: int = rand.randi_range(1, w - 2)
			var sz = RandomSize()
			var rw: int = sz[0]
			var rh: int = sz[1]
			var ry: int = y + h - 1
			var rx_min: int = x + entry - rw + 2
			var rx_max: int = x + entry - 1
			var rx: int = rand.randi_range(rx_min, rx_max - 1)
			if not self.gen.InBounds(rx, ry, rw, rh):
				return null
			if not self.gen.CheckSpace(rx + 1, ry + 1, rw - 2, rh - 2):
				return null
			var r = Room.new(self.gen, rx, ry, rw, rh)
			if r.Check(WALL_ALL):
				self.gen.At(x + entry, y + h - 1, "-")
				r.connect[Direction.UP][id] = self
				self.connect[dir][r.id] = r
				if not r.Draw(false):
					print("Drawing failed.")
				if entry < w - 2:
					if not DoorBlocked(x + entry + 1, y + h - 1, "|"):
						self.gen.At(x + entry + 1, y + h - 1, "|")
				r.Stylize()
				return r
			else:
				nextRoomId -= 1
				return null

		push_error("Invalid direction")
		return null

	# Horizontally split the room in half, if possible. Add doors to the split.
	func HSplit() -> bool:
		if not CanSplit:
			return false
		if h < 6:
			return false

		@warning_ignore("integer_division")
		var split_row: int = y + h / 2
		for i in range(w):
			# Preserve external doors at the corners where the split meets the
			# sub-room's outer walls.
			var cell = self.gen.At(x + i, split_row)
			if cell == "|" or cell == "-":
				continue
			self.gen.At(x + i, split_row, "#")

		var entry: int = rand.randi_range(1, w - 3)
		self.gen.At(x + entry, split_row, "-")
		return true

	# Vertically split the room in half, if possible. Add doors to the split.
	func VSplit() -> bool:
		if w < 6:
			return false

		@warning_ignore("integer_division")
		var split_col: int = x + w / 2
		for j in range(h):
			var cell = self.gen.At(split_col, y + j)
			if cell == "|" or cell == "-":
				continue
			self.gen.At(split_col, y + j, "#")

		var entry: int = rand.randi_range(1, h - 3)
		self.gen.At(split_col, y + entry, "|")
		return true

	func DoorCheck() -> bool:
		var has_door: bool = false
		var fail: bool = false
		for j in range(y, y + h):
			for i in range(x, x + w):
				if i == x or i == x + w - 1 or j == y or j == y + h - 1:
					if self.gen.At(i, j) == "|":
						# check on both sides of door for '.'
						if self.gen.At(i - 1, j) != "." or self.gen.At(i + 1, j) != ".":
							print("Door to nowhere! (h)")
							fail = true
						has_door = true
					if self.gen.At(i, j) == "-":
						# check on both sides of door for '.'
						if self.gen.At(i, j - 1) != "." or self.gen.At(i, j + 1) != ".":
							print("Door to nowhere! (v)")
							fail = true
						has_door = true
		if not has_door:
			print("No doors!")
		return has_door and not fail

	func InBounds() -> bool:
		if x < 0 or x + w >= self.gen.MapWidth:
			return false
		if y < 0 or y + h >= self.gen.MapHeight:
			return false
		return true
