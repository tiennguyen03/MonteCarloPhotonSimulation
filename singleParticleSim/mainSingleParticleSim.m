clc, clearvars, close all;

%Photon Properties
x = input('Enter the current value of X(mm): '); 
y = input('Enter the current value of Y(mm): '); 
z = input('Enter the current value of Z(mm): '); 
mu_a = input('Enter the current value of muA: '); 
mu_s = input('Enter the current value of muS: ');
mu_t = mu_a + mu_s;
g = input('Enter the current value of g: '); 
numPhotons = input('How many photons would you like to simulate?: ');

% Step Configurations
maxStepCount = 1000;

% Initialize cell arrays to store paths for all photons
xPaths = cell(1, numPhotons);
yPaths = cell(1, numPhotons);
zPaths = cell(1, numPhotons);

%Tissue Dimensions
gridSize = input('Enter size of Grid: '); % Number of Grid Elements Per Access
tissueSize = input('Enter size of the tissue: '); %10mm per size
absorbedGrid = zeros(gridSize, gridSize, gridSize); % Creating the grid with values initialized as 0
fluenceGrid = zeros(gridSize, gridSize, gridSize); % Creating the grid with values initialized as 0
voxelSize = tissueSize / gridSize; % Size of Each Voxel
fprintf('\n'); % Add an extra newline for separation

% Photon simulation loop
for photon = 1:numPhotons
    fprintf('Simulating photon %d/%d...\n', photon, numPhotons);

    % Simulate photon
    [xPath, yPath, zPath, absorbedGrid, fluenceGrid] = simulatePhoton(x, y, z,mu_a, mu_s, mu_t, g, maxStepCount ,gridSize, tissueSize, absorbedGrid, fluenceGrid);

    % Store the trajectory for the current photon
    xPaths{photon} = xPath;
    yPaths{photon} = yPath;
    zPaths{photon} = zPath;
end

% Photon Visualization
figure;
hold on;  % Allow multiple photon trajectories on the same plot

% Plot each photon trajectory as dots
for photon = 1:numPhotons
    plot3(xPaths{photon}, yPaths{photon}, zPaths{photon}, '.', 'MarkerSize', 12, ...
        'DisplayName', sprintf('Photon %d', photon));  % Use dots for markers
end

% Label start and end points for each photon
for photon = 1:numPhotons
    % Starting point
    plot3(xPaths{photon}(1), yPaths{photon}(1), zPaths{photon}(1), 'go', 'MarkerSize', 10, 'DisplayName', 'Start Point');
    % Ending point
    plot3(xPaths{photon}(end), yPaths{photon}(end), zPaths{photon}(end), 'rx', 'MarkerSize', 10, 'DisplayName', 'End Point');
end

% Set labels and title
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
title('Photon Trajectories (Dots Only)');
grid on;
legend show;  % Display the legend for photons

% Enable interactive rotation
rotate3d on;  % Turn on 3D rotation interactivity
hold off;

%%
figure;
hold on;  % Allow multiple trajectories on the same plot

% Plot each photon trajectory
for photon = 1:numPhotons
    plot3(xPaths{photon}, yPaths{photon}, zPaths{photon}, '-o', 'LineWidth', 1, ...
        'DisplayName', sprintf('Photon %d', photon));  % Add a label for each photon
end

% Label start and end points for each photon
for photon = 1:numPhotons
    % Starting point
    plot3(xPaths{photon}(1), yPaths{photon}(1), zPaths{photon}(1), 'go', 'MarkerSize', 8, 'DisplayName', 'Start Point');
    % Ending point
    plot3(xPaths{photon}(end), yPaths{photon}(end), zPaths{photon}(end), 'rx', 'MarkerSize', 8, 'DisplayName', 'End Point');
end

% Set labels and title
xlabel('X (mm)');
ylabel('Y (mm)');
zlabel('Z (mm)');
title('Interactive Photon Trajectories');
grid on;
legend show;  % Display the legend for photons

% Enable interactive rotation
rotate3d on;  % Turn on 3D rotation interactivity
hold off;






























