# MetaBalls
An implementation Metaballs (a.k.a Blobs) inside Unity3D. Written as a shader for the Particle System to allow formore control and fun ;-)

![Demo Glass Metaball](http://i.giphy.com/l3q2CEBxrQABnRhaE.gif)

## Demo
Demo scene included. As I didn't have time to make GUI, I included the following commands to interact with the demo.
#### Commands
<ul>
<li> <code>RMB</code> and move mouse to rotate camera. </li>
<li> <code>Mouse Wheel</code> to zoom in/out. </li>
<li> <code>1, 2, 3</code> to change between 3 shader varients. </li>
<li> <code>q, w</code> to change between 2 particle system. </li>
<li> <code>a</code> to change the speed of the particles between (0.5, 1, 2) </li>
<li> <code>s</code> to stop the particle system. </li>
<li> <code>d</code> to disable the noise effect of the particle system. </li>
<li> <code>z, x, c</code> to change the background. </li>
<li> <code>v</code> to stop the auto rotation of the camera </li>
</ul>

## Usage
<ol>
<li> Create a new Particle System and make sure it is set to Prewarm and the Max Particles are 10.</li>
<li> Create a new material with one of the provided shaders. </li>
<li> Add the material to the renderer component in the Particle System. </li>
<li> Add the script MetaBalls.cs to the Particle System. </li>
<li> Enjoy a mesmerizing effect. </li>
</ol>

## TO DO
<ul>
<li>Further optimise the raymarching on the particles.</li>
<li>Write a main cginclude file to allow reusability and extensibility.</li>
<li>Further integrate the shader it can take colours directly from the Particle System.</li>
<li>Add support to Blend Probes.</li>
<li>Support huge amounts of particles. (Currently only support max of 10 particles)</li>
</ul>

## Disclaimer
Skybox from http://pauldebevec.com/Probes/
