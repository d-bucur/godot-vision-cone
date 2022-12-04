# 🎯 Description
A plugin for Godot 4 that adds a configurable vision cone to 2D entities. It can be used for example to simulate the vision of enemies in a stealth game. It is implemented using a simple raycast in uniform directions algorithm as shown in the first picture [here](https://www.redblobgames.com/articles/visibility/).

![vision cone demo](https://github.com/d-bucur/demos/raw/master/godot-vision-cone.gif)

[Asset library page](https://godotengine.org/asset-library/asset/1568)

# 🚅 Quickstart
- [Install the plugin](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
- Check out the [example scene](addons/vision_cone_2d/examples/example.tscn) to see the plugin in action
- Instantiate the [vision_cone_2d_template](addons/vision_cone_2d/vision_cone_2d_template.tscn) scene as a child of your node that should have a vision cone. This scene comes with some predefined configurations to get you started quickly
- Configure properties in the `VisionCone2D` node. More details in [this section](#-configuration)
- Connect `body_entered`/`body_exited` signals from `VisionCone2D/VisionConeArea` node to your main game logic
- You can duplicate vision_cone_2d_template.tscn into your project and modify it to better suit objects in your project, or just attach the [vision_cone_2d.gd](addons/vision_cone_2d/vision_cone.gd) script to any node in your scene and configure everything manually
- ???
- Profit! 💸
  
# 🔧 Configuration
Script parameters are described in the [code](addons/vision_cone_2d/vision_cone_2d.gd) and they can also be viewed in the editor by hovering the mouse over the property

Check out the [example scene](addons\vision_cone_2d\examples\example.tscn) to see different configurations for the plugin in action. You can read the text in the explanation labels in the scene for more details on what's happening

The main idea is that rays are shot into many directions around the object and the resulting shape can be written to a render shape like Polygon2D or to a collision shape like CollisionPolygon2D. You can also call `calculate_vision_shape()` directly to get an array of points for the shape and then use that however you wish.

The DebugDraw node and associated script only draw an approximation of the cone inside the editor as this has to be done in a different script entirely and cannot use actual physics in the scene

# 📝 Notes
- This implements the simple raycasting method described [here](https://www.redblobgames.com/articles/visibility/). The optimized version of it with raycasts to corners is hard to make as a general solution that will work on different projects
- This only works with 2D nodes right now but if there is any interest in it, reach out to me and I will consider doing a 3D version
- This only supports Godot 4 and I don't plan on supporting Godot 3. You are free to fork and add support for it
- Tested with v4.0.beta6
- This has only been tested in mobile renderer, but should work in forward mode as well
- At the time of writing, Polygon2D does not render correctly in exported web builds. See [issue](https://github.com/godotengine/godot/issues/69533)

# 🪪 License
[Apache](LICENSE-APACHE) or [MIT](LICENSE-MIT), whichever you prefer
