module pcoll2d

import artemkakun.trnsfrm2d
import math

pub fn quick_decomp(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut result := [][]trnsfrm2d.Position{}

	mut upper_int := trnsfrm2d.Position{}
	mut lower_int := trnsfrm2d.Position{}
	mut p := trnsfrm2d.Position{}

	mut upper_dist := 0.0
	mut lower_dist := 0.0
	mut d := 0.0
	mut closest_dist := 0.0

	mut upper_index := 0
	mut lower_index := 0
	mut closest_index := 0

	mut upper_poly := []trnsfrm2d.Position{}
	mut lower_poly := []trnsfrm2d.Position{}

	if polygon.len < 3 {
		return result
	}

	for vertex_id in 0 .. polygon.len {
		if is_reflex(polygon, vertex_id) {
			upper_dist = math.inf(1)
			lower_dist = math.inf(1)

			for vertex_id_2 in 0 .. polygon.len {
				if is_left(get_previous_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_vertex_at(polygon, vertex_id_2))
					&& is_right_or_on(get_previous_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_previous_vertex(polygon, vertex_id_2)) {
					p = get_intersection_point(get_previous_vertex(polygon, vertex_id),
						get_vertex_at(polygon, vertex_id), get_vertex_at(polygon, vertex_id_2),
						get_previous_vertex(polygon, vertex_id_2))

					if is_right(get_next_vertex(polygon, vertex_id), get_vertex_at(polygon,
						vertex_id), p)
					{
						d = sqdist(polygon[vertex_id], p)
						if d < lower_dist {
							lower_dist = d
							lower_int = p
							lower_index = vertex_id_2
						}
					}
				}

				if is_left(get_next_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_next_vertex(polygon, vertex_id_2))
					&& is_right_or_on(get_next_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_vertex_at(polygon, vertex_id_2)) {
					p = get_intersection_point(get_next_vertex(polygon, vertex_id), get_vertex_at(polygon,
						vertex_id), get_vertex_at(polygon, vertex_id_2), get_next_vertex(polygon,
						vertex_id_2))

					if is_left(get_previous_vertex(polygon, vertex_id), get_vertex_at(polygon,
						vertex_id), p)
					{
						d = sqdist(polygon[vertex_id], p)
						if d < upper_dist {
							upper_dist = d
							upper_int = p
							upper_index = vertex_id_2
						}
					}
				}
			}

			if lower_index == (upper_index + 1) % polygon.len {
				p = trnsfrm2d.Position{
					x: (lower_int.x + upper_int.x) / 2
					y: (lower_int.y + upper_int.y) / 2
				}

				if vertex_id < upper_index {
					lower_poly << polygon[vertex_id..upper_index + 1]
					lower_poly << p
					upper_poly << p

					if lower_index != 0 {
						upper_poly << polygon[lower_index..polygon.len]
					}

					upper_poly << polygon[0..vertex_id + 1]
				} else {
					if vertex_id != 0 {
						lower_poly << polygon[0..vertex_id + 1]
					}

					lower_poly << polygon[0..upper_index + 1]
					lower_poly << p
					upper_poly << p
					upper_poly << polygon[lower_index..vertex_id + 1]
				}
			} else {
				if lower_index > upper_index {
					upper_index += polygon.len
				}

				closest_dist = math.inf(1)

				if upper_index < lower_index {
					return result
				}

				for vertex_id_2 in lower_index .. upper_index + 1 {
					if is_left_or_on(get_previous_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_vertex_at(polygon, vertex_id_2))
						&& is_right_or_on(get_next_vertex(polygon, vertex_id), get_vertex_at(polygon, vertex_id), get_vertex_at(polygon, vertex_id_2)) {
						d = sqdist(get_vertex_at(polygon, vertex_id), get_vertex_at(polygon,
							vertex_id_2))
						if d < closest_dist {
							closest_dist = d
							closest_index = vertex_id_2 % polygon.len
						}
					}
				}

				if vertex_id < closest_index {
					lower_poly << polygon[vertex_id..closest_index + 1]

					if closest_index != 0 {
						upper_poly << polygon[closest_index..polygon.len]
					}

					upper_poly << polygon[0..vertex_id + 1]
				} else {
					if vertex_id != 0 {
						lower_poly << polygon[vertex_id..polygon.len]
					}

					lower_poly << polygon[0..closest_index + 1]
					upper_poly << polygon[closest_index..vertex_id + 1]
				}
			}

			if lower_poly.len < upper_poly.len {
				result << quick_decomp(lower_poly)
				result << quick_decomp(upper_poly)
			} else {
				result << quick_decomp(upper_poly)
				result << quick_decomp(lower_poly)
			}

			return result
		}
	}

	result << polygon

	return result
}

fn is_reflex(polygon []trnsfrm2d.Position, i int) bool {
	return is_right(get_previous_vertex(polygon, i), get_vertex_at(polygon, i), get_next_vertex(polygon,
		i))
}

fn get_vertex_at(polygon []trnsfrm2d.Position, i int) trnsfrm2d.Position {
	s := polygon.len
	return polygon[i % s]
}

fn is_left(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) > 0
}

fn is_left_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) >= 0
}

fn is_right_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) <= 0
}

fn is_right(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) < 0
}

fn calculate_triangle_area(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) f64 {
	return (vertex_b.x - vertex_a.x) * (vertex_c.y - vertex_a.y) - (vertex_b.y - vertex_a.y) * (vertex_c.x - vertex_a.x)
}

fn get_previous_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	if vertex_index == 0 {
		return polygon.last()
	}

	return polygon[vertex_index - 1]
}

fn get_next_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	return polygon[(vertex_index + 1) % polygon.len]
}

fn get_intersection_point(p1 trnsfrm2d.Position, p2 trnsfrm2d.Position, q1 trnsfrm2d.Position, q2 trnsfrm2d.Position) trnsfrm2d.Position {
	a1 := p2.y - p1.y
	b1 := p1.x - p2.x
	c1 := (a1 * p1.x) + (b1 * p1.y)
	a2 := q2.y - q1.y
	b2 := q1.x - q2.x
	c2 := (a2 * q1.x) + (b2 * q1.y)
	det := (a1 * b2) - (a2 * b1)

	if det.eq_epsilon(0) == false {
		return trnsfrm2d.Position{
			x: ((b2 * c1) - (b1 * c2)) / det
			y: ((a1 * c2) - (a2 * c1)) / det
		}
	} else {
		return trnsfrm2d.Position{}
	}
}

fn sqdist(a trnsfrm2d.Position, b trnsfrm2d.Position) f64 {
	dx := b.x - a.x
	dy := b.y - a.y
	return dx * dx + dy * dy
}
