#ifndef CURRENT_TISSUE_MEDIA_H
#define CURRENT_TISSUE_MEDIA_H

#include <iostream>
#include <string>
#include <limits>

class CurrentTissueMedia {
public:
    // Tissue properties
    double Mu_a = 0.0;  // Absorption coefficient (1/cm)
    double Mu_s = 0.0;  // Scattering coefficient (1/cm)
    double g = 0.0;     // Anisotropy factor (0 to 1)
    double n = 1.0;     // Refractive index
    double thickness = 0.0; // Thickness of the tissue (cm)

    // Constructor
    CurrentTissueMedia() {}

    // Initialize tissue properties
    void initialize(double absorption, double scattering, double anisotropy, double refractiveIndex, double layerThickness) {
        Mu_a = absorption;
        Mu_s = scattering;
        g = anisotropy;
        n = refractiveIndex;
        thickness = layerThickness;
    }

    // Calculate total attenuation coefficient (Mu_t)
    double Mu_t() const {
        return Mu_a + Mu_s;
    }

    // Print tissue properties
    void printDetails() const {
        std::cout << "Tissue Properties:\n";
        std::cout << "Absorption coefficient (Mu_a): " << Mu_a << " 1/cm\n";
        std::cout << "Scattering coefficient (Mu_s): " << Mu_s << " 1/cm\n";
        std::cout << "Anisotropy factor (g): " << g << "\n";
        std::cout << "Refractive index (n): " << n << "\n";
        std::cout << "Thickness: " << thickness << " cm\n";
    }
};

#endif // CURRENT_TISSUE_MEDIA_H
