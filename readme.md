# 🎯 Description
A plugin for Godot 4 that adds a configurable vision cone to 2D entities. It can be used for example to simulate the vision of enemies in a stealth game. It is implemented using a simple raycast in uniform directions algorithm as shown in the first picture [here](https://www.redblobgames.com/articles/visibility/). I see this as being useful for prototyping and with a bit of tuning maybe even release.

![vision cone demo](https://github.com/d-bucur/demos/raw/master/godot-vision-cone.gif)

[Asset library page](https://godotengine.org/asset-library/asset/1568)

# 🚅 Quickstart
- [Install the plugin](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
- Check out the [example scene](addons/vision_cone_2d/examples/example.tscn) to see the plugin in action
- Instantiate the [vision_cone_2d_template](addons/vision_cone_2d/vision_cone_2d_template.tscn) scene as a child of your node that should have a vision cone. This scene comes with some predefined configurations to get you started quickly
- Configure properties in the `VisionCone2D` node. More details in [this section](#-configuration)
- Connect `body_entered`/`body_exited` signals from `VisionCone2D/VisionConeArea` node to your main game logic
- You can duplicate vision_cone_2d_template.tscn into your project and modify it to better suit objects in your project, or just attach the [vision_cone_2d.gd](addons/vision_cone_2d/vision_cone_2d.gd) script to any node in your scene and configure everything manually
- ???
- Profit! 💸
  
# 🔧 Configuration
Script parameters are described in the [code](addons/vision_cone_2d/vision_cone_2d.gd) and they can also be viewed in the editor by hovering the mouse over the property

Check out the [example scene](addons\vision_cone_2d\examples\example.tscn) to see different configurations for the plugin in action. You can read the text in the explanation labels in the scene for more details on what's happening

The main idea is that rays are shot into many directions around the object and the resulting shape can be written to a render shape like Polygon2D or to a collision shape like CollisionPolygon2D. You can also call `calculate_vision_shape()` directly to get an array of points for the shape and then use that however you wish.

The DebugDraw node and associated script only draw an approximation of the cone inside the editor as this has to be done in a different script entirely and cannot use actual physics in the scene. It's also kind of buggy at the moment

# 🏎️ Performance
- It implements the simple raycasting method described [here](https://www.redblobgames.com/articles/visibility/). The optimized version of it with raycasts to corners is harder to make as a general solution that will work on different projects.
- If you need performant checks for multiple entities (ie lots of enemies checking for a single player), it is better to just go for focused raycasts in the player direction, as described in [this tutorial](https://www.youtube.com/watch?v=04A7pUkhx3E). This plugin has worse performance than that and is useful only if you need to display the vision on the screen, or if you need to check visibility for multiple entities (ie, enemies checking visibility with other enemies or items in the world)

# 🛟 Compatibility
- Only works with 2D nodes
- Only supports Godot 4 and I don't plan on supporting Godot 3. You are free to fork and add support for it
- Tested with v4.4.1 but is known to work with all 4.* versions
- Has only been tested in mobile renderer, but should work in forward mode as well

# 🪪 License
[Apache](LICENSE-APACHE) or [MIT](LICENSE-MIT), whichever you prefer
