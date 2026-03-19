function intersection = line_intersects_polygon_with_normals()
    % Define the line segment (A(0.5, 0.5) to B(0.0, 0.0))
    A = [0.7, 0.7];
    B = [0.3, 0.3];

    % Define the polygon vertices (rectangle with 4 points)
    polygon = [-0.5, 0.05; 0.5, 0.05; 0.5, -0.05; -0.5, -0.05];

    intersection = false; % Initialize flag for intersection

    % Loop through each edge of the polygon
    for i = 1:size(polygon, 1)
        % Get the current edge of the polygon
        p1 = polygon(i, :);
        p2 = polygon(mod(i, size(polygon, 1)) + 1, :); % Next vertex (wrapping around)

        % Calculate the normal vector to the polygon edge
        edge_vector = p2 - p1;
        normal = [-edge_vector(2), edge_vector(1)]; % Perpendicular to edge_vector
        %[A,B,p1,p2,normal]
        % Check if the line segment AB intersects with edge p1p2
        if do_intersect_with_normal(A, B, p1, p2, normal)
            intersection = true;
            disp('Intersection detected!');
            break;
        end
    end

    % If no intersection is found
    if ~intersection
        disp('No intersection found.');
    end
end

function o = orientation(p, q, r)
    % Calculate the orientation of the triplet (p, q, r)
    val = (q(2) - p(2)) * (r(1) - q(1)) - (q(1) - p(1)) * (r(2) - q(2));
    if val == 0
        o = 0; % Collinear
    elseif val > 0
        o = 1; % Clockwise
    else
        o = 2; % Counterclockwise
    end
end

function on = on_segment(p, q, r)
    % Check if point q lies on the line segment pr
    on = (min(p(1), r(1)) <= q(1) && q(1) <= max(p(1), r(1))) && ...
         (min(p(2), r(2)) <= q(2) && q(2) <= max(p(2), r(2)));
end

function result = do_intersect_with_normal(A, B, p1, p2, normal)
    % Check if the line segment AB intersects with edge p1p2 using normals
    % Calculate vectors from p1 to A and from p1 to B
    v1 = A - p1;
    v2 = B - p1;

    % Calculate the dot products of the normal with the vectors v1 and v2
    dot1 = dot(normal, v1); % Dot product of normal and vector p1A
    dot2 = dot(normal, v2); % Dot product of normal and vector p1B

    % If the dot products have opposite signs, the line segment crosses the edge
    if dot1 * dot2 < 0
        result = true;  % Intersection occurs
    else
        result = false; % No intersection
    end
end
