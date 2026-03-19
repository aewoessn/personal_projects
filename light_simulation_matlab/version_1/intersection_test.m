clear, clc, close all

% Example usage:
A = [1, 1];
B = [10, 10];
C = [1, 10];
D = [10, 1];

% Compute the differences between points
dx1 = B(1) - A(1);
dy1 = B(2) - A(2);
dx2 = D(1) - C(1);
dy2 = D(2) - C(2);

% Set up the system of equations
denom = (dx1 * dy2) - (dy1 * dx2);

% If denom is 0, the lines are parallel or collinear
if denom == 0
    intersect = false;
    P = [];
    disp("The segments are collinear.");
    return;
end

% Compute the parameters t and u
dx3 = C(1) - A(1);
dy3 = C(2) - A(2);

t = (dx3 * dy2 - dy3 * dx2) / denom;
u = (dx3 * dy1 - dy3 * dx1) / denom;

% Check if the intersection point is within both line segments
if t >= 0 && t <= 1 && u >= 0 && u <= 1
    intersect = true;
    % Calculate the intersection point using t
    P = [A(1) + t * dx1, A(2) + t * dy1];
else
    intersect = false;
    P = [];
end

if intersect
    disp("The segments intersect at:");
    disp(P);
else
    disp("The segments do not intersect.");
end

