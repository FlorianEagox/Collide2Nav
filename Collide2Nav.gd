tool
extends EditorPlugin

var btnGenerate
# We could put the button directly into the Polygon tools, but it looks functionally idential and is much easier just to add it to the canvas's menu
#var nav_toolbar_path = "/root/EditorNode/@@585/@@586/@@594/@@596/@@600/@@604/@@605/@@606/@@622/@@623/@@632/@@633/@@6278/@@6116/@@11825"
#var nav_toolbar: HBoxContainer
var editor_selection = get_editor_interface().get_selection()
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
	var bodies = [] # All of the static bodies in the scene
	get_of_type(get_editor_interface().get_edited_scene_root(), StaticBody2D, bodies) # Get every static body in the curently edited scene
	print(bodies)

# This function will recurse through every child of root, and if the child is of type type, add it to the referenced found_objects array
func get_of_type(root: Node, type, found_objects):
	for node in root.get_children():
		if node is type:
			found_objects.append(root)
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