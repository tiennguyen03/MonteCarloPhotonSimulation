while true  %photon absorbed or boundary condition breaks it
    stepCount = stepCount + 1;
    if(stepCount > maxStepCount)
        disp('Max Step Count Reached. Terminating.');
        break;

    %Photon Exists Tissue
    elseif(z < 0) 
        disp('Photon exited tissue. Terminating');
        break;

    % Photon is Absorbed
    elseif(rand() < p_absorbed)
        disp('Photon absorbed. Terminating');
        
        % Calculate where we will map to the grid
        voxelX = round((x / tissueSize) * gridSize);
        voxelY = round((y / tissueSize) * gridSize);
        voxelZ = round((z / tissueSize) * gridSize);

        % Once absorbed, check if photon is within the tissue
        if((voxelX > 0 && voxelX <= gridSize)&&(voxelY > 0 && voxelY <= gridSize)&&(voxelZ > 0 && voxelZ <= gridSize))
            %Map the absorbed energy to the grid
            absorbedGrid(voxelX, voxelY, voxelZ) = absorbedGrid(voxelX, voxelY, voxelZ) + mu_a;  
        end
        break;

    % Photon is Scattered
    else 
        disp('Photon Scattered. Continued travelling.')
    
        %Update direction & stepSize for continued travel
        polarAngle = calcPolarAngle(g);
        azimuthalAngle = calcAzimuthalAngle();
        stepSize = calcStepSize(mu_t);

        % Validate step size
        if stepSize <= 0
            disp('Invalid step size. Terminating.');
            break;
        end
    
        % Update Position of Photon
        deltaX = stepSize*sin(polarAngle)*cos(azimuthalAngle);
        deltaY = stepSize*sin(polarAngle)*sin(azimuthalAngle);
        deltaZ = stepSize*cos(polarAngle);
    
        % New Position of Photon
        x = x + deltaX;
        y = y + deltaY;
        z = z + deltaZ;

        % Store the current position in the path
        xPath(stepCount) = x;
        yPath(stepCount) = y;
        zPath(stepCount) = z;

        % Displaying the step information
        fprintf('Step: %d\n', stepCount);
        fprintf('X: %.3f mm\n', x);
        fprintf('Y: %.3f mm\n', y);
        fprintf('Z: %.3f mm\n',z);
        fprintf('\n'); % Add an extra newline for separation


        % Calculate where we will map to the grid
        voxelX = round((x / tissueSize) * gridSize);
        voxelY = round((y / tissueSize) * gridSize);
        voxelZ = round((z / tissueSize) * gridSize);

        % Once absorbed, check if photon is within the tissue
        if((voxelX > 0 && voxelX <= gridSize)&&(voxelY > 0 && voxelY <= gridSize)&&(voxelZ > 0 && voxelZ <= gridSize))
            %Map the absorbed energy to the grid
            fluenceGrid(voxelX, voxelY, voxelZ) = fluenceGrid(voxelX, voxelY, voxelZ) + 1;  
        end
    end
end