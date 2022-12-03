# 🎯 Description
This is a plugin for Godot 4 that will add a configurable vision cone to 2D entities. This can be used for example to simulate the vision of enemies in a stealth game.

TODO: add gif of example project

TODO: update link to asset library once it gets approved

# 🚅 Quickstart
- [Install the plugin](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)
- Check out the [example scene](addons\vision_cone_2d\examples\example.tscn) to see the plugin in action
- Instantiate the [vision_cone_2d_template](addons/vision_cone_2d/vision_cone_2d_template.tscn) scene as a child of your node that should have a vision cone. This scene is configured with some predefined configurations to get you started quickly
- Configure properties in the `VisionCone2D` node
- Connect `body_entered`/`body_exited` signals from `VisionCone2D/VisionConeArea` node to your main game logic
- You can duplicate vision_cone_2d_template.tscn into your project and modify it to better suit your project configuration, or just attach the [vision_cone_2d.gd](addons/vision_cone_2d/vision_cone.gd) script to any node in your scene and configure everything manually
- ?
- Profit! 💸
  
# 🔧 Configuration
TODO
Check out the [example scene](addons\vision_cone_2d\examples\example.tscn) to see different configurations for the plugin in action. You can check out the text in the explanation labels in the scene for more details on what's happening

# 📝 Notes
- This implements the simple raycasting method described [here](https://www.redblobgames.com/articles/visibility/). The optimized version of it with raycasts to corners is hard to make as a general solution that will work on different projects
- This only works with 2D nodes right now but if there is any interest in it, reach out to me and I will consider doing a 3D version
- This only supports Godot 4 and I don't plan on supporting Godot 3. You are free to fork and add support for it
- This has only been tested in mobile renderer, but should work in forward mode as well