#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <random>
#include "Photon.h"
#include "CurrentTissueMedia.h"

#define M_PI 3.14159265358979323846

const double EPSILON = 1e-4; // Threshold weight for roulette
const int M = 10;           // Roulette survival multiplier
const int NPHOTONS = 100;   // Number of photons to simulate
const double RHO = 3.5;     // Source-detector separation (cm)
const double RHO_ERROR = RHO * 0.1; // Allowable detector error

std::random_device rd;
std::mt19937 gen(rd());
std::uniform_real_distribution<> dis(0.0, 1.0);

int main() {
    std::cout << "Monte Carlo Simulation of Photon-Tissue Interaction\n";
    std::cout << "-------------------------------------------------\n\n";

    // Load Tissue Layers from CSV
    std::ifstream inputFile("Gardener_Inputs.csv");
    if (!inputFile.is_open()) {
        std::cerr << "Error: Could not open Gardener_Inputs.csv\n";
        return 1;
    }

    std::vector<CurrentTissueMedia> tissueLayers;
    std::string line;
    std::getline(inputFile, line); // Skip header

    while (std::getline(inputFile, line)) {
        double Mu_a, Mu_s, g, n, thickness;
        sscanf(line.c_str(), "%lf,%lf,%lf,%lf,%lf", &Mu_a, &Mu_s, &g, &n, &thickness);

        CurrentTissueMedia layer;
        layer.initialize(Mu_a, Mu_s, g, n, thickness);
        tissueLayers.push_back(layer);
    }
    inputFile.close();
    std::cout << "Loaded " << tissueLayers.size() << " tissue layers from Gardener_Inputs.csv\n\n";

    // Spectral reflectance (Rsp)
    double ambientRefractiveIndex = 1.0; // Surrounding media refractive index
    double Rsp = pow((ambientRefractiveIndex - tissueLayers[0].n) /
                     (ambientRefractiveIndex + tissueLayers[0].n), 2);

    // Initialize results
    double totalReflectance = 0.0, totalTransmittance = 0.0;
    std::vector<double> totalPathLengths(NPHOTONS, 0.0);
    std::vector<std::vector<double>> layerPathLengths(NPHOTONS, std::vector<double>(tissueLayers.size(), 0.0));
    std::vector<double> photonWeights(NPHOTONS, 0.0);

    // Monte Carlo simulation
    for (int n = 0; n < NPHOTONS; ++n) {
        Photon photon;
        photon.initialize(Rsp);

        while (photon.pos_z >= 0 && photon.pos_z <= tissueLayers.back().thickness && photon.w > 0) {
            // Determine step size and check position
            int currentLayer = -1;
            for (size_t i = 0; i < tissueLayers.size(); ++i) {
                if (photon.pos_z <= tissueLayers[i].thickness) {
                    currentLayer = i;
                    break;
                }
            }

            if (currentLayer == -1) break; // Photon is out of bounds

            double stepSize = -log(dis(gen)) / tissueLayers[currentLayer].Mu_t();
            photon.pos_x += stepSize * photon.cx;
            photon.pos_y += stepSize * photon.cy;
            photon.pos_z += stepSize * photon.cz;
            totalPathLengths[n] += stepSize;
            layerPathLengths[n][currentLayer] += stepSize;

            // Photon absorption
            double absorbedWeight = photon.w * tissueLayers[currentLayer].Mu_a / tissueLayers[currentLayer].Mu_t();
            photon.w -= absorbedWeight;

            // Photon scattering
            double theta = acos(1 - 2 * dis(gen)); // Random scattering angle
            double phi = 2 * M_PI * dis(gen);      // Random azimuthal angle
            photon.cx = sin(theta) * cos(phi);
            photon.cy = sin(theta) * sin(phi);
            photon.cz = cos(theta);

            // Roulette logic for photon survival
            if (photon.w < EPSILON) {
                if (dis(gen) <= 1.0 / M) {
                    photon.w *= M;
                } else {
                    photon.w = 0;
                }
            }
        }

        // Check if photon is reflected
        if (photon.pos_z < 0) {
            totalReflectance += photon.w;
        }

        // Check if photon is transmitted
        if (photon.pos_z > tissueLayers.back().thickness) {
            totalTransmittance += photon.w;
        }

        photonWeights[n] = photon.w;
    }

    // Normalize results
    totalReflectance /= NPHOTONS;
    totalTransmittance /= NPHOTONS;

    // Save results to CSV
    std::ofstream outFile("simulation_results.csv");
    if (outFile.is_open()) {
        outFile << "PhotonID,TotalPathlength,";
        for (size_t i = 0; i < tissueLayers.size(); ++i) {
            outFile << "Layer" << i + 1 << "Pathlength,";
        }
        outFile << "PhotonWeight\n";

        for (int n = 0; n < NPHOTONS; ++n) {
            outFile << n + 1 << "," << totalPathLengths[n] << ",";
            for (size_t i = 0; i < tissueLayers.size(); ++i) {
                outFile << layerPathLengths[n][i] << ",";
            }
            outFile << photonWeights[n] << "\n";
        }
        outFile.close();
    } else {
        std::cerr << "Error: Could not open output file.\n";
    }

    // Output summary
    std::cout << "Simulation complete.\n";
    std::cout << "Total Reflectance: " << totalReflectance << "\n";
    std::cout << "Total Transmittance: " << totalTransmittance << "\n";
    return 0;
}
