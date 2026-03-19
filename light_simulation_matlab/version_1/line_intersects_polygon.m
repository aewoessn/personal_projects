function intersection = line_intersects_polygon()
    % Define the line segment (A(0.5, 0.5) to B(0.0, 0.0))
    A = [0.5, 0.5];
    B = [0.0, 0.0];

    % Define the polygon vertices (rectangle with 4 points)
    polygon = [-0.5, 0.05; 0.5, 0.05; 0.5, -0.05; -0.5, -0.05];

    intersection = false; % Initialize flag for intersection

    % Loop through each edge of the polygon
    for i = 1:size(polygon, 1)
        % Get the current edge of the polygon
        p1 = polygon(i, :);
        p2 = polygon(mod(i, size(polygon, 1)) + 1, :); % Next vertex (wrapping around)

        % Check if the line segment AB intersects with edge p1p2
        if do_intersect(A, B, p1, p2)
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

function result = do_intersect(p1, q1, p2, q2)
    % Check if the line segments p1q1 and p2q2 intersect
    o1 = orientation(p1, q1, p2);
    o2 = orientation(p1, q1, q2);
    o3 = orientation(p2, q2, p1);
    o4 = orientation(p2, q2, q1);

    % General case
    if o1 != o2 && o3 != o4
        result = true;
    % Special cases
    elseif o1 == 0 && on_segment(p1, p2, q1)
        result = true;
    elseif o2 == 0 && on_segment(p1, q2, q1)
        result = true;
    elseif o3 == 0 && on_segment(p2, p1, q2)
        result = true;
    elseif o4 == 0 && on_segment(p2, q1, q2)
        result = true;
    else
        result = false;
    end
end
