clear, clc, close all

% Give the light some initial conditions
currentPosition = [0.5, -0.75];
previousPosition = currentPosition;
currentAngle = 10*(pi/180);
currentVector = [cos(currentAngle),sin(currentAngle)];
dDist = 0.05;
lengthOfTrail = 10; % in ticks

% Generate the environment
figure;
glass = patch([0.0, 0.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','blue','FaceAlpha',0.2,'EdgeColor','none');
bounds = patch([-1.0, -1.0, 1.0, 1.0],[1.0, -1.0, -1.0, 1.0],'FaceColor','none','EdgeColor','k','Linewidth',1.5);
xlim([-1.0 1.0]);
ylim([-1.0 1.0]);

hold on;
s = scatter(currentPosition(1), currentPosition(2),'r','filled');
p = plot(currentPosition(1), currentPosition(2),'r-');
q = quiver(currentPosition(1), currentPosition(2), currentVector(1)*0.1, currentVector(2)*0.1);
hold off;

% Give physical properties
n1 = 1.0;
n2 = 1.52;

% Begin the simulation
simDone = false;
numberOfTicks = 1;
while ~simDone

  % Check the current position of the ray...

  %--- Boundary conditions ---%
  % See if the ray is on/beyond the +x boundary
  if currentPosition(1) >= 1.0

    % Scoot the ray back to the boundary by solving the linear interpolation
    % equation:
    % (y - y0) / (x - x0) = (y1 - y0) / (x1 - x0)
    %
    % For this condition, x = 1.0 and we are solving for y:
    % y  = (((y1 - y0) / (x1 - x0)) * (x - x0)) + y0
    interpPosition = [1.0, 0.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    x = interpPosition(1);
    interpPosition(2) = (((y1 - y0) / (x1 - x0)) * (x - x0)) + y0;
    currentPosition = interpPosition;

    % Reflect the ray
    normVector = [-1.0, 0.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  % See if the ray is on/beyond the -x boundary
   if currentPosition(1) <= -1.0

    % Scoot the ray back to the boundary
    interpPosition = [-1.0, 0.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    x = interpPosition(1);
    interpPosition(2) = (((y1 - y0) / (x1 - x0)) * (x - x0)) + y0;
    currentPosition = interpPosition;

    % Reflect the ray
    normVector = [1.0, 0.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  % See if the ray is on/beyond the +y boundary
  if currentPosition(2) >= 1.0

    % Scoot the ray back to the boundary by solving the linear interpolation
    % equation:
    % (y - y0) / (x - x0) = (y1 - y0) / (x1 - x0)
    %
    % For this condition, x = 1.0 and we are solving for y:
    % x  = (((x1 - x0) / (y1 - y0)) * (y - y0)) + x0
    interpPosition = [0.0, 1.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    y = interpPosition(2);
    interpPosition(1) = (((x1 - x0) / (y1 - y0)) * (y - y0)) + x0;
    currentPosition = interpPosition;

    % Reflect the ray
    normVector = [0.0, -1.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  % See if the ray is on/beyond the -y boundary
   if currentPosition(2) <= -1.0

    % Scoot the ray back to the boundary
    interpPosition = [0.0, -1.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    y = interpPosition(2);
    interpPosition(1) = (((x1 - x0) / (y1 - y0)) * (y - y0)) + x0;
    currentPosition = interpPosition;

    % Reflect the ray
    normVector = [0.0, 1.0];
    currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
  endif

  %--- Material conditions ---%
  % Check to see if ray moved from air (left) to glass (right)
  % n1 -> n2
  if currentPosition(1) >= 0.0 && previousPosition(1) < 0.0

    % Scoot the ray back to the interface
    interpPosition = [0.0, 0.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    x = interpPosition(1);
    interpPosition(2) = (((y1 - y0) / (x1 - x0)) * (x - x0)) + y0;
    currentPosition = interpPosition;

    % Get the incident angle
    incidentAngle = currentAngle;

    % Check for total internal reflection
    if (n2 / n1) < 1
      % Total internal reflection is possible
      crit_theta = asin(n2 / n1);

      if incidentAngle > crit_theta
        % Total internal reflection

        % Reflect the ray
        normVector = [-1.0, 0.0];
        currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
      else
        % No total internal reflection
        new_theta = asin((n1 * sin(incidentAngle)) / n2);

        % Update the current angle and current vector
        currentAngle = new_theta;
        currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);
      endif

    else
      % Total internal reflection is not possible

      % Solve Snell's law:
      % sin(new_theta) = (n1 * sin(incidentAngle)) / n2
      new_theta = asin((n1 * sin(incidentAngle)) / n2);

      % Update the current angle and current vector
      currentAngle = new_theta;
      currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);
    endif
  endif

  % Check to see if ray moved from glass (right) to air (left)
  % n2 -> n1
  if currentPosition(1) <= 0.0 && previousPosition(1) > 0.0

    % Scoot the ray back to the interface
    interpPosition = [0.0, 0.0];

    x0 = previousPosition(1);
    y0 = previousPosition(2);
    x1 = currentPosition(1);
    y1 = currentPosition(2);
    x = interpPosition(1);
    interpPosition(2) = (((y1 - y0) / (x1 - x0)) * (x - x0)) + y0;
    currentPosition = interpPosition;

    % Get the incident angle
    incidentAngle = currentAngle;

    % Check for total internal reflection
    if (n1 / n2) < 1
      % Total internal reflection is possible
      crit_theta = asin(n1 / n2);

      if incidentAngle > crit_theta
        % Total internal reflection

        % Reflect the ray
        normVector = [1.0, 0.0];
        currentVector = currentVector - (2*dot(currentVector,normVector).*normVector);
      else
        % No total internal reflection
        new_theta = asin((n2 * sin(incidentAngle)) / n1);

        % Update the current angle and current vector
        currentAngle = new_theta;
        currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);
      endif

    else
      % Total internal reflection is not possible

      % Solve Snell's law:
      % sin(new_theta) = (n2 * sin(incidentAngle)) / n1
      new_theta = asin((n2 * sin(incidentAngle)) / n1);

      % Update the current angle and current vector
      currentAngle = new_theta;
      currentVector = [cos(currentAngle),sin(currentAngle)].*sign(currentVector);
    endif
  endif

  % Update plot
  set(s,{'XData','YData'},{currentPosition(1),currentPosition(2)});
  set(p,{'XData','YData'},{[get(p,'XData'),currentPosition(1)],[get(p,'YData'),currentPosition(2)]});
  set(q,{'XData','YData','UData','VData'},{currentPosition(1), currentPosition(2), currentVector(1)*0.1, currentVector(2)*0.1});
  drawnow();

  % Update the position based on the current position and the current vector
  previousPosition = currentPosition;
  currentPosition = currentPosition + (currentVector.*dDist);

  % Advance the simulation by one tick
  numberOfTicks = numberOfTicks + 1;
end

