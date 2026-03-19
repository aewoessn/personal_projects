clear, clc, close all
polygon = [0.5, 0.5; 0.25, 0; 0.5, -0.5; -0.5, -0.5; -0.5, 0.5];
point = [0.4, 0.4];  % Point inside the concave region

figure; patch(polygon(:,1),polygon(:,2),'EdgeColor','k','FaceColor','none');
hold on; scatter(point(1),point(2),'ro','filled'); hold off;

  % point = (x, y) - the point to check
  % polygon = an Nx2 matrix of vertices [x1, y1; x2, y2; ...; xn, yn]

  % Extract the coordinates of the point
  x = point(1);
  y = point(2);

  % Get the number of vertices of the polygon
  n = size(polygon, 1);

  % Initialize the number of intersections
  intersections = 0;

  for i = 1:n
    % Get the current edge from the polygon
    x1 = polygon(i, 1);
    y1 = polygon(i, 2);
    x2 = polygon(mod(i, n) + 1, 1);  % Wrap around for the last vertex
    y2 = polygon(mod(i, n) + 1, 2);  % Wrap around for the last vertex

    % Check if the ray from point (x, y) intersects the edge (x1, y1) → (x2, y2)
    if ((y1 > y && y2 <= y) || (y2 > y && y1 <= y))  % Check if the point's y is between the edge's y-values
      % Calculate the x-coordinate of the intersection point of the ray with the edge
      intersect_x = (y - y1) * (x2 - x1) / (y2 - y1) + x1;

      % Check if the intersection point is to the right of the point
      if (intersect_x > x)
        intersections = intersections + 1;
      end
    end
  end

  % If the number of intersections is odd, the point is inside
  inside = mod(intersections, 2) == 1;

set(gca,'Title',int2str(inside));


