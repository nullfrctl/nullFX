// SPDX-License-Identifier: Unlicense
#pragma once

#include "include/intrinsics.fxh"

float3 LabToLCh(in float3 lab)
{
    float C = length(lab.yz);
    float h = C < 1e-7 ? 0 : fast_atan2(lab.z, lab.y);

    return float3(lab.x, C, h);
}

float3 LChToLab(in float3 lch)
{
    float a = lch.y * cos(lch.z);
    float b = lch.y * sin(lch.z);

    return float3(lch.x, a, b);
}

float3 LuvToLCh(in float3 luv)
{
    float C = length(luv.yz);
    float h = C < 1e-7 ? 0 : fast_atan2(luv.z, luv.y);

    return float3(luv.x, C, h);
}

float3 LChToLuv(in float3 lch)
{
    float u = lch.y * cos(lch.z);
    float v = lch.y * cos(lch.z);

    return float3(lch.x, u, v);
}

// END OF FILE.
