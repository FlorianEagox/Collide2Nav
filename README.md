# Collide2Nav

A tool to automatically generate navigation polygons based on collision objects.

The purpose of this plugin is to speed up level building especially when working with complex collisoin shapes and navigation paths. You only have to place collision polygons and it will generate the nav polygons for you.

## Instillation
Clone or download this project into your
```
res://addons/
```
so that you have
```
res://addons/Collide2Nav/
```
Open a Godot project -> `Project` -> `Project Settings...` -> `Plugins (tab)`

In the list, select Collide2Nav, click the right-most dropdown box and select active.

If it does not appear, check your addons folder and possibly restart the engine if you added it while it was running.

## Usage
Now, when editing a scene, if you select a NavigationPolygonInstance in your scene graph, there should be a new button in the viewport's menu toolbar that says, "Generate from Bodies."

![The button](https://i.imgur.com/jOvzmtZ.png)

Clicking this will begin ateempting to generate the navpoly.

The plugin will find the bounds of all the tilesets in your map and create a large rectangle navpoly.

It will then find all the CollisionPolygon2D nodes and generate polygons at their locations. It does this to "mask them out"

Your AI should now be able to navigate everywhere within your TileMap that didn't have a collision polygon already there.
