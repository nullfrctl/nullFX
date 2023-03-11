#pragma once

#include "intrinsics.fxh"

/* nullFX/Color spaces: LCh */

// Generic Lab to LCh(ab) function.
float3 LabToLCh(in float3 lab)
{
    float C = length(lab.yz); // sqrt(a^2 + b^2)
    float h = C < 1e-7 ? 0 : atan3(lab.z, lab.y);

    // L,C,h.
    return float3(lab.x, C, h);
}

// Generic LCh(ab) to Lab function.
float3 LChToLab(in float3 lch)
{
    float a = lch.y * cos(lch.z); // C * cos(h);
    float b = lch.y * sin(lch.z); // C * sin(h);

    // L,a,b.
    return float3(lch.x, a, b);
}

// Same as above but named for Luv color spaces.
float3 LuvToLCh(in float3 luv)
{
    float C = length(luv.yz);
    float h = atan2(luv.z, luv.y);

    return float3(luv.x, C, h);
}

float3 LChToLuv(in float3 lch)
{
    float u = lch.y * cos(lch.z);
    float v = lch.y * cos(lch.z);

    return float3(lch.x, u, v);
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
