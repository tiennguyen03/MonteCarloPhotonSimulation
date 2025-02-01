#ifndef PHOTON_H
#define PHOTON_H

#include <iostream>
#include <cmath>
#include <limits>
#include "CurrentTissueMedia.h"

class Photon {
public:
    // Photon position
    double pos_x = 0.0;
    double pos_y = 0.0;
    double pos_z = 0.0;

    // Photon direction cosines
    double cx = 0.0;
    double cy = 0.0;
    double cz = 1.0;

    // Photon properties
    double w = 1.0; // Weight
    double pathlength = 0.0; // Total path traveled
    double dimless_stepSize = 0.0; // Step size in tissue

    // Error handling
    int check = -1;
    int error = 0;

    // Initialize a photon
    void initialize(double Rsp) {
        pos_x = 0.0;
        pos_y = 0.0;
        pos_z = 0.0;
        cx = 0.0;
        cy = 0.0;
        cz = 1.0; // Photon starts moving downwards
        w = 1.0 - Rsp; // Initial weight after reflectance
        pathlength = 0.0;
        dimless_stepSize = 0.0;
        check = -1;
        error = 0;
    }

    // Print photon details (for debugging)
    void printDetails() const {
        std::cout << "Photon Details:\n";
        std::cout << "Position: (" << pos_x << ", " << pos_y << ", " << pos_z << ")\n";
        std::cout << "Direction: (" << cx << ", " << cy << ", " << cz << ")\n";
        std::cout << "Weight: " << w << "\n";
        std::cout << "Pathlength: " << pathlength << "\n";
    }
};

#endif // PHOTON_H
