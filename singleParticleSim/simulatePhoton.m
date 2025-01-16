function [updatedXPath, updatedYPath, updatedZPath, updatedAbsorbedGrid, updatedFluenceGrid] = simulatePhoton(x, y, z, mu_a, mu_s, mu_t, g, maxStepCount, gridSize, tissueSize, absorbedGrid, fluenceGrid)

    % Initialize photon path
    updatedXPath = zeros(1, maxStepCount);
    updatedYPath = zeros(1, maxStepCount);
    updatedZPath = zeros(1, maxStepCount);

    % Probabilities
    p_absorbed = mu_a / mu_t;
    p_scattered = mu_s / mu_t;

    % Step counter
    stepCount = 0;

    while true
        stepCount = stepCount + 1;

        % Termination conditions (max steps, exiting tissue, or absorption)
        if stepCount > maxStepCount
            disp('Max Step Count Reached. Terminating.');
            break;
        elseif z < 0
            disp('Photon exited tissue. Terminating.');
            break;
        elseif rand() < p_absorbed
            disp('Photon absorbed. Terminating.');

            % Update absorbed energy grid
            voxelX = round((x / tissueSize) * gridSize);
            voxelY = round((y / tissueSize) * gridSize);
            voxelZ = round((z / tissueSize) * gridSize);

            if voxelX > 0 && voxelX <= gridSize && ...
               voxelY > 0 && voxelY <= gridSize && ...
               voxelZ > 0 && voxelZ <= gridSize
                absorbedGrid(voxelX, voxelY, voxelZ) = absorbedGrid(voxelX, voxelY, voxelZ) + mu_a;
            end
            break;
        end

        % Scattering phase
        polarAngle = calcPolarAngle(g);
        azimuthalAngle = calcAzimuthalAngle();
        stepSize = calcStepSize(mu_t);

        % Update position
        deltaX = stepSize * sin(polarAngle) * cos(azimuthalAngle);
        deltaY = stepSize * sin(polarAngle) * sin(azimuthalAngle);
        deltaZ = stepSize * cos(polarAngle);
        x = x + deltaX;
        y = y + deltaY;
        z = z + deltaZ;

        % Store the path
        updatedXPath(stepCount) = x;
        updatedYPath(stepCount) = y;
        updatedZPath(stepCount) = z;

        % Update fluence grid
        voxelX = round((x / tissueSize) * gridSize);
        voxelY = round((y / tissueSize) * gridSize);
        voxelZ = round((z / tissueSize) * gridSize);

        if voxelX > 0 && voxelX <= gridSize && ...
           voxelY > 0 && voxelY <= gridSize && ...
           voxelZ > 0 && voxelZ <= gridSize
            fluenceGrid(voxelX, voxelY, voxelZ) = fluenceGrid(voxelX, voxelY, voxelZ) + mu_a;
        end
    end

    % Trim unused path entries
    updatedXPath = updatedXPath(1:stepCount);
    updatedYPath = updatedYPath(1:stepCount);
    updatedZPath = updatedZPath(1:stepCount);

    % Assign updated grids to output variables
    updatedAbsorbedGrid = absorbedGrid;
    updatedFluenceGrid = fluenceGrid;
end
