# DropletShader

Shader recreation of droplet transition effect from Abe's Oddysee/Exoddus.


# Parameters
Different shader parameters can be used by appending to the url.

Adding `?frameRate=60` to the url sets the framerate to 60. (default is 15)

Multiple parameters can also be added like this: `?frameRate=60&duration=5`

Basically: add a `?` first and then `&` between each assignment.
Some parameters have multiple values. Just add a `,` between each:
`?drop0=0.2,0.5,0.9` (sets the first droplet to arrive 0.2 seconds in at 0.5x and 0.9y)

## List of Parameters
- ``frameRate`` how many unique frames per second (default = 15)
- ``startPause`` how long to pause at the start before playing the animation (default = 0.5)
- ``duration`` how long the transition lasts (default = 3.5)
- ``endPause`` how long to pause at the end before restarting (default = 0.5)
- ``dropCount`` how many droplets to include (default = 4)
- ``warpAmount`` this parameter controls how extreme the warp effect is (default = 6.0)
- ``bg_a``/``bg_b`` set to `true` or `false` to enable/disable the background (default = false for bg_a and true for bg_b)
- ``drop0``/``drop1``/``drop2``/``drop3`` set timing and position for one of the droplets

Default drop values:
`drop0=0.2,0.5,0.9&drop1=0.4,0.2,0.1&drop2=0.6,0.5,0.5&drop3=0.8,0.8,0.1`