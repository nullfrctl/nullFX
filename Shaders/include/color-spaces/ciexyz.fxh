// SPDX-License-Identifier: Unlicense
#pragma once

#include "include/intrinsics.fxh"

// clang-format off
static const float3x3 srgb_to_ciexyz = float3x3(
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
);

static const float3x3 cie_xyz_to_srgb = float3x3(
    +3.2406255, -1.5372080, -0.4986286,
    -0.9689307, +1.8757561, +0.0415175,
    +0.0557101, -0.2040211, +1.0569959
);
// clang-format on

float3 SRGBToXYZ(in float3 srgb)
{
    float3 xyz = mul(srgb_to_ciexyz, srgb);
    return xyz;
}

float3 XYZToSRGB(in float3 ciexyz)
{
    float3 srgb = mul(cie_xyz_to_srgb, ciexyz);
    return srgb;
}

// END OF FILE.