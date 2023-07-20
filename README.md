<h1 align="center">v-2d-polygon-colliders</h1>

A polygon collision detection library written in the V programming language.
This library provides utilities for polygon decomposition and collision detection,
which can be used for game development, physics simulations, or any application that requires
handling of 2D polygonal collisions.

## Overview

The pcoll2d library comprises three parts:
- `polygon.v`: Defines the polygon data structure.
- `sat_collision.v`: Uses the Separating Axis Theorem (SAT) algorithm to check if two convex polygons
collide.
- `bayazit_decomposition.v`: Handles the decomposition of a polygon into convex polygons using the
Bayazit algorithm.

## Usage

First, install package from [vpm](https://vpm.vlang.io/packages/ArtemkaKun.pcoll2d):

```
v install ArtemkaKun.pcoll2d
```

Then, import the module into your V code:

```v badsyntax
import artemkakun.pcoll2d
```

## Features

### Polygon collision

Checking collision between two polygons:

```v badsyntax
import artemkakun.pcoll2d
import artemkakun.trnsfrm2d

first_line_points := [trnsfrm2d.Position{
	x: 0
	y: 0
}, trnsfrm2d.Position{
	x: 1
	y: 1
}]

second_line_points := [trnsfrm2d.Position{
	x: 0
	y: 1
}, trnsfrm2d.Position{
	x: 1
	y: 0
}]

collides := pcoll2d.check_collision(first_polygon, second_polygon)! // true
```

### Polygon decomposition

Decomposing a polygon into convex polygons:

```v badsyntax
import artemkakun.pcoll2d
import artemkakun.trnsfrm2d

polygon := [trnsfrm2d.Position{
	x: 0.0
	y: 0.0
}, trnsfrm2d.Position{
	x: 1.0
	y: 1.0
}, trnsfrm2d.Position{
	x: 2.0
	y: 0.0
}]

convex_parts := pcoll2d.decompose(polygon) // [[{0.0, 0.0}, {1.0, 1.0}, {2.0, 0.0}]]
```

## Contributing

Please feel free to open an issue or submit a pull request with your bug fixes or enhancements.

## Donations

If you like this project, please consider donating to me or the V language project.
Your donations will help me to continue to develop this project and the V language.

## More about my projects

Subscribe to [my Mastodon account](https://mastodon.social/@yuart) to find more info about my projects.
