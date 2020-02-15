tool
extends EditorPlugin

var btnGenerate
# We could put the button directly into the Polygon tools, but it looks functionally idential and is much easier just to add it to the canvas's menu
#var nav_toolbar_path = "/root/EditorNode/@@585/@@586/@@594/@@596/@@600/@@604/@@605/@@606/@@622/@@623/@@632/@@633/@@6278/@@6116/@@11825"
#var nav_toolbar: HBoxContainer

var editor_selection = get_editor_interface().get_selection()
var root # The scene root
var selected_node: NavigationPolygonInstance

func _enter_tree() -> void:
	editor_selection.connect("selection_changed", self, "selection_changed") # Connect an event when the user selects a node in their scene tree
	btnGenerate = ToolButton.new()
	btnGenerate.text = "Generate from bodies"
	btnGenerate.hint_tooltip = "Generate from bodies"
	btnGenerate.name = "btnGenerate"
	btnGenerate.connect("pressed", self, "generate")
	#nav_toolbar = get_node(nav_toolbar_path)

func selection_changed():
	var nodes = editor_selection.get_selected_nodes() # Get the nodes they selected
	if nodes.size() == 1 and nodes[0] is NavigationPolygonInstance: # If they only selected one, and it's a mesh
		if not btnGenerate.get_parent(): # if the button hasn't been added yet
			selected_node = nodes[0]
			add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, btnGenerate) # add it to the menu
			# nav_toolbar.add_child(btnGenerate)
	else:
		if btnGenerate.get_parent(): # If we've added it before
			remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, btnGenerate) # Remove the button when we're not editing a mesh

func get_plugin_name() -> String:
	return "Collide2Nav"

func _exit_tree() -> void:
	if btnGenerate.get_parent(): #If we've added it before
		remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, btnGenerate)
	btnGenerate.queue_free()
	#nav_toolbar.remove_child(btnGenerate)

func generate():
	print("Generating Mesh...")
	root = get_editor_interface().get_edited_scene_root()

	var mesh = NavigationPolygon.new()

	# Our goal is to find the top leftest corner and bottom rightest corner of all the tilmaps so we are encompassing everything.
	var maps = []
	get_of_type(root, TileMap, maps) # Get all the tilemaps in the scene
	if maps.size() > 0: # If we found at least one
		# initialize the top and bottom corners in case we don't find a larger tile map
		var map_bounds_min = maps[0].map_to_world(maps[0].get_used_rect().position)
		var map_bounds_max = map_bounds_min + maps[0].map_to_world(maps[0].get_used_rect().size)
		for i in range(maps.size()):
			var tile_rect = maps[i].get_used_rect()
			var origin = maps[i].map_to_world(tile_rect.position)
			var map_size = maps[i].map_to_world(tile_rect.size)
			# This is just a big min max of each corner of each map
			if  origin.x < map_bounds_min.x:
				map_bounds_min.x = origin.x
			if origin.x + map_size.x > map_bounds_max.x:
				map_bounds_max.x = origin.x + map_size.x
			if map_bounds_min.y < origin.y:
				map_bounds_min.y = origin.y
			if origin.y + map_size.y > map_bounds_max.y:
				map_bounds_max.y = origin.y + map_size.y
		
		# Creating a rectangle with the bounds of the tilemaps to be our base nav polygon
		mesh.add_outline([map_bounds_min, Vector2(map_bounds_max.x, map_bounds_min.y), map_bounds_max, Vector2(map_bounds_min.x, map_bounds_max.y)])
		
	var shapes = [] # All of the collision polygons in the scene
	get_of_type(root, CollisionPolygon2D, shapes) # Get every collision polygon in the curently edited scene
	
	for shape in shapes: # Go through every shape and generate a nav polygon
		# We need to offset the mesh points to the same as the collission polygon points
		var points = shape.polygon
		for i in range(points.size()):
			points[i] += shape.get_parent().position + shape.position
		mesh.add_outline(points)
	mesh.make_polygons_from_outlines()
	mesh.clear_outlines()
	selected_node.navpoly = mesh # Set the scene's polymeshinstance to the one we just created

# This function will recurse through every child of root, and if the child is of type type, add it to the referenced found_objects array
func get_of_type(root: Node, type, found_objects):
	for node in root.get_children():
		if node is type:
			found_objects.append(node)
		get_of_type(node, type, found_objects)


# This function is very useful for parsing actual Editor elements
func print_children_readable(child: Control, level: int = 0):
	if child and child.visible:
		var tabs = ""
		for i in range(level):
			tabs += "\t"
		print(tabs, child, child.get_path(), child.get_tooltip() if child.get_tooltip() else "")
		for sub_child in child.get_children():
			print_children_readable(sub_child, level+1)