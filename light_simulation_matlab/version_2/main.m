clear, clc, close all
clear functions

% Initialize axis
figure; xlim([-2 2]); ylim([-2 2]);

% Create a simple scene with some glass and mirrors
%{
scene{1} = Material('position',[0.0,0.5,-0.5;0.5,-0.5,-0.5],...
                    'indexOfRefraction',1.52,...
                    'displayColor',[0.0, 0.0, 1.0, 0.2],...
                    'showNormals',true);
%}


%--- Lens ---%
% Parameters for the concave lens
R = 1;        % Radius of curvature (for spherical surface)
t = 0;         % Thickness of the lens
num_points = 20; % Number of points to plot the lens profile

% Create a vector of angles (in radians)
theta = linspace(-pi/2, pi/2, num_points);  % Half-circle for concave side

% Generate the concave surface (inside of the circle)
x1 = R * cos(theta); % x-coordinate (radius times cos(angle))
y1 = R * sin(theta); % y-coordinate (radius times sin(angle))

% Now, generate the other side of the lens (simulate thickness)
x2 = x1 + t;  % Shift the x-coordinates to the right by thickness
y2 = y1;      % Same y-coordinates

lensPosition = [-0.1,x2,-0.1;-1,y2,1];
scene{1} = Material('position',lensPosition,...
                    'indexOfRefraction',1.52,...
                    'displayColor',[0.0, 0.0, 1.0, 0.2],...
                    'showNormals',false,...
                    'scale',[0.7,1]);



%scene{1} = Material('position',[0.5,0.5,-0.5,-0.5;0.5,-0.5,-0.5,0.5],...
%                    'indexOfRefraction',1.52,...
%                    'displayColor',[0.0, 0.0, 1.0, 0.2],...
%                    'showNormals',true);


% Link scene objects to figure
set(gca,'userdata',scene);

% Create some rays
%Ray([-1.0,0.90],0*(pi/180));
Ray([-1.0,0.75],0*(pi/180));
%Ray([-1.0,0.50],0*(pi/180));
Ray([-1.0,0.25],0*(pi/180));
Ray([-1.0,0.00],0*(pi/180));
Ray([-1.0,-0.25],0*(pi/180));
%Ray([-1.0,-0.50],0*(pi/180));
Ray([-1.0,-0.75],0*(pi/180));
%Ray([-1.0,-0.90],0*(pi/180));
