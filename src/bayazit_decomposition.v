module pcoll2d

import artemkakun.trnsfrm2d
import math

fn get_previous_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	if vertex_index == 0 {
		return polygon.last()
	}

	return polygon[vertex_index - 1]
}

fn get_next_vertex(polygon []trnsfrm2d.Position, vertex_index int) trnsfrm2d.Position {
	return polygon[(vertex_index + 1) % polygon.len]
}

// def lineInt(l1, l2, precision=0):
//    """Compute the intersection between two lines.
//
//    Keyword arguments:
//    l1 -- first line
//    l2 -- second line
//    precision -- precision to check if lines are parallel (default 0)
//
//    Returns:
//    The intersection point
//    """
//    i = [0, 0] # point
//    a1 = l1[1][1] - l1[0][1]
//    b1 = l1[0][0] - l1[1][0]
//    c1 = a1 * l1[0][0] + b1 * l1[0][1]
//    a2 = l2[1][1] - l2[0][1]
//    b2 = l2[0][0] - l2[1][0]
//    c2 = a2 * l2[0][0] + b2 * l2[0][1]
//    det = a1 * b2 - a2 * b1
//    if not scalar_eq(det, 0, precision): # lines are not parallel
//        i[0] = (b2 * c1 - b1 * c2) / det
//        i[1] = (a1 * c2 - a2 * c1) / det
//    return i
//

fn find_line_intersection_point(first_line_points [2]trnsfrm2d.Position, second_line_points [2]trnsfrm2d.Position) trnsfrm2d.Position {
	a1 := first_line_points[1].y - first_line_points[0].y
	b1 := first_line_points[0].x - first_line_points[1].x
	c1 := a1 * first_line_points[0].x + b1 * first_line_points[0].y

	a2 := second_line_points[1].y - second_line_points[0].y
	b2 := second_line_points[0].x - second_line_points[1].x
	c2 := a2 * second_line_points[0].x + b2 * second_line_points[0].y

	det := a1 * b2 - a2 * b1

	if det.eq_epsilon(0) {
		return trnsfrm2d.Position{
			x: 0
			y: 0
		}
	} else {
		return trnsfrm2d.Position{
			x: (b2 * c1 - b1 * c2) / det
			y: (a1 * c2 - a2 * c1) / det
		}
	}
}

// def triangleArea(a, b, c):
//    """Calculates the area of a triangle spanned by three points.
//    Note that the area will be negative if the points are not given in counter-clockwise order.
//
//    Keyword arguments:
//    a -- First point
//    b -- Second point
//    c -- Third point
//
//    Returns:
//    Area of triangle
//    """
//    return ((b[0] - a[0])*(c[1] - a[1]))-((c[0] - a[0])*(b[1] - a[1]))
//

fn calculate_triangle_area(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) f64 {
	return (vertex_b.x - vertex_a.x) * (vertex_c.y - vertex_a.y) - (vertex_b.y - vertex_a.y) * (vertex_c.x - vertex_a.x)
}

fn is_left(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) > 0
}

fn is_left_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) >= 0
}

fn is_right(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) < 0
}

fn is_right_or_on(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position, vertex_c trnsfrm2d.Position) bool {
	return calculate_triangle_area(vertex_a, vertex_b, vertex_c) <= 0
}

// def sqdist(a, b):
//    dx = b[0] - a[0]
//    dy = b[1] - a[1]
//    return dx * dx + dy * dy
//

fn calculate_sqdist(vertex_a trnsfrm2d.Position, vertex_b trnsfrm2d.Position) f64 {
	dx := vertex_b.x - vertex_a.x
	dy := vertex_b.y - vertex_a.y
	return dx * dx + dy * dy
}

// def polygonAt(polygon, i):
//    """Gets a vertex at position i on the polygon.
//    It does not matter if i is out of bounds.
//
//    Keyword arguments:
//    polygon -- The polygon
//    i -- Position desired on the polygon
//
//    Returns:
//    Vertex at position i
//    """
//    s = len(polygon)
//    return polygon[i % s]
//

fn get_vertex_at(polygon []trnsfrm2d.Position, i int) trnsfrm2d.Position {
	s := polygon.len
	return polygon[i % s]
}

// def polygonIsReflex(polygon, i):
//    """Checks if a point in the polygon is a reflex point.
//
//    Keyword arguments:
//    polygon -- The polygon
//    i -- index of point to check
//
//    Returns:
//    True is point is a reflex point
//
//    """
//    return isRight(polygonAt(polygon, i - 1), polygonAt(polygon, i), polygonAt(polygon, i + 1))
//

fn is_reflex(polygon []trnsfrm2d.Position, i int) bool {
	return is_right(get_previous_vertex(polygon, i), get_vertex_at(polygon, i), get_next_vertex(polygon,
		i))
}

// def polygonCanSee(polygon, a, b):
//    """Checks if two vertices in the polygon can see each other.
//
//    Keyword arguments:
//    polygon -- The polygon
//    a -- Vertex 1
//    b -- Vertex 2
//
//    Returns:
//    True if vertices can see each other
//
//    """
//
//    l1 = [None]*2
//    l2 = [None]*2
//
//    if isLeftOn(polygonAt(polygon, a + 1), polygonAt(polygon, a), polygonAt(polygon, b)) and isRightOn(polygonAt(polygon, a - 1), polygonAt(polygon, a), polygonAt(polygon, b)):
//        return False
//
//    dist = sqdist(polygonAt(polygon, a), polygonAt(polygon, b))
//    for i in xrange(0, len(polygon)): # for each edge
//        if (i + 1) % len(polygon) == a or i == a: # ignore incident edges
//            continue
//
//        if isLeftOn(polygonAt(polygon, a), polygonAt(polygon, b), polygonAt(polygon, i + 1)) and isRightOn(polygonAt(polygon, a), polygonAt(polygon, b), polygonAt(polygon, i)): # if diag intersects an edge
//            l1[0] = polygonAt(polygon, a)
//            l1[1] = polygonAt(polygon, b)
//            l2[0] = polygonAt(polygon, i)
//            l2[1] = polygonAt(polygon, i + 1)
//            p = lineInt(l1, l2)
//            if sqdist(polygonAt(polygon, a), p) < dist: # if edge is blocking visibility to b
//                return False
//
//    return True

fn can_see(polygon []trnsfrm2d.Position, a int, b int) bool {
	mut l1 := [2]trnsfrm2d.Position{}
	mut l2 := [2]trnsfrm2d.Position{}

	if is_left_or_on(get_next_vertex(polygon, a), get_vertex_at(polygon, a), get_vertex_at(polygon, b))
		&& is_right_or_on(get_previous_vertex(polygon, a), get_vertex_at(polygon, a), get_vertex_at(polygon, b)) {
		return false
	}

	dist := calculate_sqdist(get_vertex_at(polygon, a), get_vertex_at(polygon, b))

	for i in 0 .. polygon.len { // for each edge
		if (i + 1) % polygon.len == a || i == a { // ignore incident edges
			continue
		}

		if is_left_or_on(get_vertex_at(polygon, a), get_vertex_at(polygon, b), get_next_vertex(polygon, i))
			&& is_right_or_on(get_vertex_at(polygon, a), get_vertex_at(polygon, b), get_vertex_at(polygon, i)) { // if diag intersects an edge
			l1[0] = get_vertex_at(polygon, a)
			l1[1] = get_vertex_at(polygon, b)
			l2[0] = get_vertex_at(polygon, i)
			l2[1] = get_next_vertex(polygon, i)
			p := find_line_intersection_point(l1, l2)
			if calculate_sqdist(get_vertex_at(polygon, a), p) < dist { // if edge is blocking visibility to b
				return false
			}
		}
	}

	return true
}

// def polygonCopy(polygon, i, j, targetPoly=None):
//    """Copies the polygon from vertex i to vertex j to targetPoly.
//
//    Keyword arguments:
//    polygon -- The source polygon
//    i -- start vertex
//    j -- end vertex (inclusive)
//    targetPoly -- Optional target polygon
//
//    Returns:
//    The resulting copy.
//
//    """
//    p = targetPoly or []
//    polygonClear(p)
//    if i < j:
//        # Insert all vertices from i to j
//        for k in xrange(i, j+1):
//            p.append(polygon[k])
//
//    else:
//        # Insert vertices 0 to j
//        for k in xrange(0, j+1):
//            p.append(polygon[k])
//
//        # Insert vertices i to end
//        for k in xrange(i, len(polygon)):
//            p.append(polygon[k])
//
//    return p

fn copy_polygon(polygon []trnsfrm2d.Position, i int, j int) []trnsfrm2d.Position {
	mut p := []trnsfrm2d.Position{}

	if i < j {
		// Insert all vertices from i to j
		for k in i .. j + 1 {
			p << polygon[k]
		}
	} else {
		// Insert vertices 0 to j
		for k in 0 .. j + 1 {
			p << polygon[k]
		}

		// Insert vertices i to end
		for k in i .. polygon.len {
			p << polygon[k]
		}
	}

	return p
}

// def polygonGetCutEdges(polygon):
//    """Decomposes the polygon into convex pieces.
//    Note that this algorithm has complexity O(N^4) and will be very slow for polygons with many vertices.
//
//    Keyword arguments:
//    polygon -- The polygon
//
//    Returns:
//    A list of edges [[p1,p2],[p2,p3],...] that cut the polygon.
//
//    """
//    mins = []
//    tmp1 = []
//    tmp2 = []
//    tmpPoly = []
//    nDiags = float('inf')
//
//    for i in xrange(0, len(polygon)):
//        if polygonIsReflex(polygon, i):
//            for j in xrange(0, len(polygon)):
//                if polygonCanSee(polygon, i, j):
//                    tmp1 = polygonGetCutEdges(polygonCopy(polygon, i, j, tmpPoly))
//                    tmp2 = polygonGetCutEdges(polygonCopy(polygon, j, i, tmpPoly))
//
//                    for k in xrange(0, len(tmp2)):
//                        tmp1.append(tmp2[k])
//
//                    if len(tmp1) < nDiags:
//                        mins = tmp1
//                        nDiags = len(tmp1)
//                        mins.append([polygonAt(polygon, i), polygonAt(polygon, j)])
//
//    return mins

fn get_cut_edges(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut mins := [][]trnsfrm2d.Position{}
	mut tmp1 := [][]trnsfrm2d.Position{}
	mut tmp2 := [][]trnsfrm2d.Position{}
	mut n_diags := math.inf(1)

	for i in 0 .. polygon.len {
		if is_reflex(polygon, i) {
			for j in 0 .. polygon.len {
				if can_see(polygon, i, j) {
					tmp1 = get_cut_edges(copy_polygon(polygon, i, j))
					tmp2 = get_cut_edges(copy_polygon(polygon, j, i))

					for k in 0 .. tmp2.len {
						tmp1 << tmp2[k]
					}

					if tmp1.len < n_diags {
						mins = tmp1.clone()
						n_diags = tmp1.len
						mins << [get_vertex_at(polygon, i), get_vertex_at(polygon, j)]
					}
				}
			}
		}
	}

	return mins
}

// def polygonSlice(polygon, cutEdges):
//    """Slices the polygon given one or more cut edges. If given one, this function will return two polygons (false on failure). If many, an array of polygons.
//
//    Keyword arguments:
//    polygon -- The polygon
//    cutEdges -- A list of edges to cut on, as returned by getCutEdges()
//
//    Returns:
//    An array of polygon objects.
//
//    """
//    if len(cutEdges) == 0:
//        return [polygon]
//
//    if isinstance(cutEdges, list) and len(cutEdges) != 0 and isinstance(cutEdges[0], list) and len(cutEdges[0]) == 2 and isinstance(cutEdges[0][0], list):
//
//        polys = [polygon]
//
//        for i in xrange(0, len(cutEdges)):
//            cutEdge = cutEdges[i]
//            # Cut all polys
//            for j in xrange(0, len(polys)):
//                poly = polys[j]
//                result = polygonSlice(poly, cutEdge)
//                if result:
//                    # Found poly! Cut and quit
//                    del polys[j:j+1]
//                    polys.extend((result[0], result[1]))
//                    break
//
//        return polys
//    else:
//
//        # Was given one edge
//        cutEdge = cutEdges
//        i = polygon.index(cutEdge[0])
//        j = polygon.index(cutEdge[1])
//
//        if i != -1 and j != -1:
//            return [polygonCopy(polygon, i, j),
//                    polygonCopy(polygon, j, i)]
//        else:
//            return False
//

fn slice_polygon(polygon []trnsfrm2d.Position, cut_edges [][]trnsfrm2d.Position) [][]trnsfrm2d.Position {
	if cut_edges.len == 0 {
		return [polygon]
	}

	mut polys := [polygon]

	for i in 0 .. cut_edges.len {
		mut cut_edge := cut_edges[i]
		// Cut all polys
		for j in 0 .. polys.len {
			mut poly := polys[j]
			mut result := cut_polygon_by_edge(poly, cut_edge)
			if result != none {
				for k in j .. j + 1 {
					polys.delete(k)
				}

				polys << result or { break }[0]
				polys << result or { break }[1]
				break
			}
		}
	}

	return polys
}

fn cut_polygon_by_edge(polygon []trnsfrm2d.Position, cut_edge []trnsfrm2d.Position) ?[][]trnsfrm2d.Position {
	mut i := polygon.index(cut_edge[0])
	mut j := polygon.index(cut_edge[1])

	if i != -1 && j != -1 {
		return [copy_polygon(polygon, i, j), copy_polygon(polygon, j, i)]
	} else {
		return none
	}
}

// def polygonDecomp(polygon):
//    """Decomposes the polygon into one or more convex sub-polygons.
//
//    Keyword arguments:
//    polygon -- The polygon
//
//    Returns:
//    An array or polygon objects.
//
//    """
//    edges = polygonGetCutEdges(polygon)
//    if len(edges) > 0:
//        return polygonSlice(polygon, edges)
//    else:
//        return [polygon]
//

pub fn decomp_polygon(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut edges := get_cut_edges(polygon)

	if edges.len > 0 {
		return slice_polygon(polygon, edges)
	} else {
		return [polygon]
	}
}

// def polygonQuickDecomp(polygon, result=None, reflexVertices=None, steinerPoints=None, delta=25, maxlevel=100, level=0):
//    """Quickly decompose the Polygon into convex sub-polygons.
//
//    Keyword arguments:
//    polygon -- The polygon to decompose
//    result -- Stores result of decomposed polygon, passed recursively
//    reflexVertices --
//    steinerPoints --
//    delta -- Currently unused
//    maxlevel -- The maximum allowed level of recursion
//    level -- The current level of recursion
//
//    Returns:
//    List of decomposed convex polygons
//
//    """
//    if result is None:
//        result = []
//    reflexVertices = reflexVertices or []
//    steinerPoints = steinerPoints or []
//
//    upperInt = [0, 0]
//    lowerInt = [0, 0]
//    p = [0, 0]         # Points
//    upperDist = 0
//    lowerDist = 0
//    d = 0
//    closestDist = 0 # scalars
//    upperIndex = 0
//    lowerIndex = 0
//    closestIndex = 0 # integers
//    lowerPoly = []
//    upperPoly = [] # polygons
//    poly = polygon
//    v = polygon
//
//    if len(v) < 3:
//        return result
//
//    level += 1
//    if level > maxlevel:
//        print("quickDecomp: max level ("+str(maxlevel)+") reached.")
//        return result
//
//    for i in xrange(0, len(polygon)):
//        if polygonIsReflex(poly, i):
//            reflexVertices.append(poly[i])
//            upperDist = float('inf')
//            lowerDist = float('inf')
//
//            for j in xrange(0, len(polygon)):
//                if isLeft(polygonAt(poly, i - 1), polygonAt(poly, i), polygonAt(poly, j)) and isRightOn(polygonAt(poly, i - 1), polygonAt(poly, i), polygonAt(poly, j - 1)): # if line intersects with an edge
//                    p = getIntersectionPoint(polygonAt(poly, i - 1), polygonAt(poly, i), polygonAt(poly, j), polygonAt(poly, j - 1)) # find the point of intersection
//                    if isRight(polygonAt(poly, i + 1), polygonAt(poly, i), p): # make sure it's inside the poly
//                        d = sqdist(poly[i], p)
//                        if d < lowerDist: # keep only the closest intersection
//                            lowerDist = d
//                            lowerInt = p
//                            lowerIndex = j
//
//                if isLeft(polygonAt(poly, i + 1), polygonAt(poly, i), polygonAt(poly, j + 1)) and isRightOn(polygonAt(poly, i + 1), polygonAt(poly, i), polygonAt(poly, j)):
//                    p = getIntersectionPoint(polygonAt(poly, i + 1), polygonAt(poly, i), polygonAt(poly, j), polygonAt(poly, j + 1))
//                    if isLeft(polygonAt(poly, i - 1), polygonAt(poly, i), p):
//                        d = sqdist(poly[i], p)
//                        if d < upperDist:
//                            upperDist = d
//                            upperInt = p
//                            upperIndex = j
//
//            # if there are no vertices to connect to, choose a point in the middle
//            if lowerIndex == (upperIndex + 1) % len(polygon):
//                #print("Case 1: Vertex("+str(i)+"), lowerIndex("+str(lowerIndex)+"), upperIndex("+str(upperIndex)+"), poly.size("+str(len(polygon))+")")
//                p[0] = (lowerInt[0] + upperInt[0]) / 2
//                p[1] = (lowerInt[1] + upperInt[1]) / 2
//                steinerPoints.append(p)
//
//                if i < upperIndex:
//                    #lowerPoly.insert(lowerPoly.end(), poly.begin() + i, poly.begin() + upperIndex + 1)
//                    polygonAppend(lowerPoly, poly, i, upperIndex+1)
//                    lowerPoly.append(p)
//                    upperPoly.append(p)
//                    if lowerIndex != 0:
//                        #upperPoly.insert(upperPoly.end(), poly.begin() + lowerIndex, poly.end())
//                        polygonAppend(upperPoly, poly, lowerIndex, len(poly))
//
//                    #upperPoly.insert(upperPoly.end(), poly.begin(), poly.begin() + i + 1)
//                    polygonAppend(upperPoly, poly, 0, i+1)
//                else:
//                    if i != 0:
//                        #lowerPoly.insert(lowerPoly.end(), poly.begin() + i, poly.end())
//                        polygonAppend(lowerPoly, poly, i, len(poly))
//
//                    #lowerPoly.insert(lowerPoly.end(), poly.begin(), poly.begin() + upperIndex + 1)
//                    polygonAppend(lowerPoly, poly, 0, upperIndex+1)
//                    lowerPoly.append(p)
//                    upperPoly.append(p)
//                    #upperPoly.insert(upperPoly.end(), poly.begin() + lowerIndex, poly.begin() + i + 1)
//                    polygonAppend(upperPoly, poly, lowerIndex, i+1)
//
//            else:
//                # connect to the closest point within the triangle
//                #print("Case 2: Vertex("+str(i)+"), closestIndex("+str(closestIndex)+"), poly.size("+str(len(polygon))+")\n")
//
//                if lowerIndex > upperIndex:
//                    upperIndex += len(polygon)
//
//                closestDist = float('inf')
//
//                if upperIndex < lowerIndex:
//                    return result
//
//                for j in xrange(lowerIndex, upperIndex+1):
//                    if isLeftOn(polygonAt(poly, i - 1), polygonAt(poly, i), polygonAt(poly, j)) and isRightOn(polygonAt(poly, i + 1), polygonAt(poly, i), polygonAt(poly, j)):
//                        d = sqdist(polygonAt(poly, i), polygonAt(poly, j))
//                        if d < closestDist:
//                            closestDist = d
//                            closestIndex = j % len(polygon)
//
//                if i < closestIndex:
//                    polygonAppend(lowerPoly, poly, i, closestIndex+1)
//                    if closestIndex != 0:
//                        polygonAppend(upperPoly, poly, closestIndex, len(v))
//
//                    polygonAppend(upperPoly, poly, 0, i+1)
//                else:
//                    if i != 0:
//                        polygonAppend(lowerPoly, poly, i, len(v))
//
//                    polygonAppend(lowerPoly, poly, 0, closestIndex+1)
//                    polygonAppend(upperPoly, poly, closestIndex, i+1)
//
//            # solve smallest poly first
//            if len(lowerPoly) < len(upperPoly):
//                polygonQuickDecomp(lowerPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
//                polygonQuickDecomp(upperPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
//            else:
//                polygonQuickDecomp(upperPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
//                polygonQuickDecomp(lowerPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
//
//            return result
//
//    result.append(polygon)
//
//    return result
//

pub fn quick_decomp(polygon []trnsfrm2d.Position) [][]trnsfrm2d.Position {
	mut result := [][]trnsfrm2d.Position{}
	mut reflex_vertices := []trnsfrm2d.Position{}
	mut steiner_points := []trnsfrm2d.Position{}

	mut upper_int := trnsfrm2d.Position{}
	mut lower_int := trnsfrm2d.Position{}
	mut p := trnsfrm2d.Position{}

	mut upper_dist := 0.0
	mut lower_dist := 0.0
	mut d := 0
	mut closest_dist := 0

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
			reflex_vertices << polygon[vertex_id]
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

				steiner_points << p

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

			//            # solve smallest poly first
			//            if len(lowerPoly) < len(upperPoly):
			//                polygonQuickDecomp(lowerPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
			//                polygonQuickDecomp(upperPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
			//            else:
			//                polygonQuickDecomp(upperPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
			//                polygonQuickDecomp(lowerPoly, result, reflexVertices, steinerPoints, delta, maxlevel, level)
			//
			//            return result
			if lower_poly < upper_poly.len {
			}
		}
	}
}

// def getIntersectionPoint(p1, p2, q1, q2, delta=0):
//    """Gets the intersection point
//
//    Keyword arguments:
//    p1 -- The start vertex of the first line segment.
//    p2 -- The end vertex of the first line segment.
//    q1 -- The start vertex of the second line segment.
//    q2 -- The end vertex of the second line segment.
//    delta -- Optional precision to check if lines are parallel (default 0)
//
//    Returns:
//    The intersection point.
//
//    """
//    a1 = p2[1] - p1[1]
//    b1 = p1[0] - p2[0]
//    c1 = (a1 * p1[0]) + (b1 * p1[1])
//    a2 = q2[1] - q1[1]
//    b2 = q1[0] - q2[0]
//    c2 = (a2 * q1[0]) + (b2 * q1[1])
//    det = (a1 * b2) - (a2 * b1)
//
//    if not scalar_eq(det, 0, delta):
//        return [((b2 * c1) - (b1 * c2)) / det, ((a1 * c2) - (a2 * c1)) / det]
//    else:
//        return [0, 0]
//

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

// def sqdist(a, b):
//    dx = b[0] - a[0]
//    dy = b[1] - a[1]
//    return dx * dx + dy * dy
//

fn sqdist(a trnsfrm2d.Position, b trnsfrm2d.Position) f64 {
	dx := b.x - a.x
	dy := b.y - a.y
	return dx * dx + dy * dy
}
