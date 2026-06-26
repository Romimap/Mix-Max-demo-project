This [Godot 4.7](https://godotengine.org/download/archive/) project is a demo that both provides implementation examples and shows the capabilities of the [Mix-Max](https://hal.science/hal-04692440v1/file/islandora_171738.pdf) operator.
The project is not made to be run through an executable, but rather opened in Godot editor to be examined.

### TL;DR, I want to QUICKLY understand

Read those 3 files :
- ``shaders/mixing_2.gdshader`` (how to use the Mix-Max)
- ``shaders/includes/mix_max.gdshaderinc`` (the Mix-Max)
- ``shaders/includes/probability_functions.gdshaderinc`` (important formulae)

# Project structure

- **scenes** : This folder contains use-case scenarios. 
Each scene contains a mesh that is rendered using a ``ShaderMaterial``. 
By inspecting the material, one can see which shader is executing with which parameters.

- **textures** : This folder contains the data used by the shaders. 
three sets of appearances (paving_stones, rock, sand) is provided.
each appearance is composed of a color, normal, roughness texture, and have an associated priority map (``*_priority`` and ``*_bm``).

- **shaders** : This folder contains most of the code.
``shaders/includes`` contains an implementation of the paper, that is the Mix-Max operator and an associated tiling and blending algorithm.
``shaders/`` contains use case scenarios shaders used in the scenes.

- **precomputation** : This folder contains a precomputation step.
In the ``textures/`` folder, we saw that the priority maps exists in a "raw" state (grayscale ``_priority`` image), and a "bm" state (red and green ``_bm`` image).
The latter is derived from the former and is the one used in the shaders.
The ``_bm`` format contains the centered priorities in the red channel, and their square in the green channel.
This data enables real-time evaluation of both the mean and the variance of the priorities over footprints (see [LEAN mapping](https://userpages.cs.umbc.edu/olano/papers/lean/)).
the ``priority_to_bm.tscn`` scene is composed of a single tool node that takes as an input a grayscale priority map, and outputs a floating point BM image at the provided path.
Usage : Drag and drop a texture into the ``Priority Map`` field, define the ``Export Path`` to where the BM map will be saved (e.g. ``textures/sand_bm.exr``, other file formats are not supported), and press ``Run !``.

# Scenes

- **mixing_2.tscn** : Transitions between two textures. UV coordinates are used to define the blending weights.

- **synthesis.tscn** : Synthesizes a texture using a tiling and blending algorithm (a dual grid is used)

- **synthesis_mixing_3.tscn** : Synthesizes three texture "layers", and then mixes them together using image masks.

# Shader dependencies

```
tiling_and_blending --- mix_max --- probability_functions
					\-- hash
```

# Optimizations

Note that this implementation is not finely optimized.
For example, BM maps are stored on the GPU in an uncompressed floating point format.
One could precompute and store variance values in the MIP-Map of a compressed 8 bits per color texture to make the texture fetch faster.
We however decided to limit the necessary boilerplate to keep the code simple.
