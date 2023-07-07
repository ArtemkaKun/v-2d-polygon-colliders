module pcoll2d

import artemkakun.trnsfrm2d

// Polygon data is stored in JSON format, so polygon files must have the .json extension.
pub const polygon_file_extension = '.json'

// Polygon is a 2D shape with a list of points. Points are stored in clockwise order.
pub struct Polygon {
pub:
	points []trnsfrm2d.Position
}
