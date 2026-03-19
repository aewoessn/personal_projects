clear, clc, close all

% Give the light some initial conditions
startPosition = [-0.5, -0.75];
startAngle = 45*(pi/180);
dDist = 0.01;

% Generate the environment
figure;
bounds = patch([-1.0, -1.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','none','EdgeColor','k','Linewidth',1.5);
xlim([-1.0 1.0]);
ylim([-1.0 1.0]);

hold on;
s = scatter(startPosition(1), startPosition(2),'r','filled');
p = plot(startPosition(1), startPosition(2), 'r-');
q = quiver(startPosition(1), startPosition(2), (cos(startAngle)*0.1), (sin(startAngle)*0.1));
hold off;

% Begin the simulation
simDone = false;
currentPos = startPosition;
currentAngle = startAngle;
numberOfTicks = 1;
while ~simDone

  % Advance the beam using the position and angle
  nextPos = currentPos + ([cos(currentAngle), sin(currentAngle)].*dDist);

  % Check to see if +x wall is hit
  if nextPos(1) >= 1.0
    % Calculate reflection vector
    normalVector = [-1.0, nextPos(2)];
    normalVector = normalVector ./ vecnorm(normalVector);
    reflectionVec = currentPos - (2.*dot(currentPos,normalVector).*normalVector);
    a
  endif

  currentPos = nextPos;

  % Update plot
  set(s,{'XData','YData'},{currentPos(1),currentPos(2)});
  set(p,{'XData','YData'},{[get(p,'XData'),currentPos(1)],[get(p,'YData'),currentPos(2)]});
  set(q,{'XData','YData','UData','VData'},{currentPos(1), currentPos(2), cos(currentAngle)*0.1, sin(currentAngle)*0.1});
  drawnow();

  % Advance the simulation by one tick
  numberOfTicks = numberOfTicks + 1;

  if numberOfTicks >= 1000
    break;
  endif
end
