# Screenspace Data Example
2019.4.30f1

An example showing a geometry shader encoding multiple per-vertex attributes (world positions, orientation, and an 'up' value) into a grid of screenspace pixel blocks. 

This data is captured into a rendertexture where a different shader can perform arbitrary computations on said data (in this case, we modulate world position with a sine wave). 

We then finally read the result of said computations to mesh attributes when actually drawing the mesh.

A grabpass version of the technique is also included that can be toggled with the USE_GRABPASS keyword in the shaders. A CRT-version is included as well, use with caution.

![img](./Images/1.png)
