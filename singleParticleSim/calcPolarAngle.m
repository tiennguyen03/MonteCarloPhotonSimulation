function pA = calcPolarAngle(anisotropyFactor)
    cos_of_pA = 1 - (2*rand())*(1 - anisotropyFactor);
    pA = acos(cos_of_pA);
end