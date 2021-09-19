# Screenspace Data Example

Well gamers somehow my hopeless ass has managed to make an example showing a geometry shader encoding multiple per-vertex attributes (world positions, orientation, and an 'up' value) into a grid of screenspace pixel blocks.

This data is captured into a rendertexture where a different shader can perform arbitrary computations on said data (in this case, we modulate world position with a sine wave). 

We then finally read the result of said computations to mesh attributes when actually drawing the mesh.

A grabpass version of the technique is also included that can be toggled with the USE_GRABPASS keyword in the shaders. This exports the data to the screen directly without the need for a camera to be pointed at the object. A CRT-version is included as well, use with caution.

![img](./Images/1.png)

 #### Credits: 

 Cnlohr for providing helpful example code that really allowed me to understand this.

 MerlinVR for providing code for encoding and decoding perfect 32 bit uints and perfect 32 bit floats.

 Pema99 for writing up the explanations so I don't have to xd: [1](https://github.com/pema99/shader-knowledge/blob/main/tips-and-tricks.md#encoding-and-decoding-data-in-a-grabpass) [2](https://github.com/pema99/shader-knowledge/blob/main/tips-and-tricks.md#easy-way-to-show-uv-unwrap-in-clipspace) [3](https://github.com/pema99/shader-knowledge/blob/main/geometry-shaders.md#blitting-to-camera-loops-or-cameras-in-general) 
