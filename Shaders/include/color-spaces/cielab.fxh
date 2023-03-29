// SPDX-License-Identifier: Unlicense
#pragma once

#include "include/color-spaces/ciexyz.fxh"
#include "include/global.fxh"

static const float epsilon = (216.0 / 24389.0);
static const float kappa = (24389.0 / 27.0);
static const float3 d65 = float3(0.95047, 1.00000, 1.08883);

float3 XYZToCIELAB(in float3 ciexyz, in float3 reference_white)
{
    float3 xyz = ciexyz / reference_white;

    xyz.x = xyz.x > epsilon ? cbrt(xyz.x) : (kappa * xyz.x + 16.0) / 116.0;
    xyz.y = xyz.y > epsilon ? cbrt(xyz.y) : (kappa * xyz.y + 16.0) / 116.0;
    xyz.z = xyz.z > epsilon ? cbrt(xyz.z) : (kappa * xyz.z + 16.0) / 116.0;

    float3 cielab;
    cielab.x = 116.0 * xyz.y - 16.0;
    cielab.y = 500.0 * (xyz.x - xyz.y);
    cielab.z = 200.0 * (xyz.y - xyz.z);

    return cielab;
}

float3 XYZToCIELAB(in float3 ciexyz)
{
    return XYZToCIELAB(ciexyz, d65);
}

float3 SRGBToCIELAB(in float3 srgb)
{
    return XYZToCIELAB(SRGBToXYZ(srgb));
}

float3 CIELABToXYZ(in float3 cielab, in float3 reference_white)
{
    float3 xyz;
    xyz.y = (cielab.x + 16.0) / 116.0;
    xyz.x = cielab.y / 500.0 + xyz.y;
    xyz.z = xyz.y - cielab.z / 200.0;

    float3 xyz3 = pow3(xyz);

    xyz.x = xyz3.x > epsilon ? xyz3.x : (116.0 * xyz.x - 16.0) / kappa;
    xyz.y = cielab.x > kappa * epsilon ? xyz3.y : cielab.x / kappa;
    xyz.z = xyz3.z > epsilon ? xyz3.z : (116.0 * xyz.z - 16.0) / kappa;

    float3 ciexyz = xyz * reference_white;
    return ciexyz;
}

float3 CIELABToXYZ(in float3 cielab)
{
    return CIELABToXYZ(cielab, d65);
}

float3 CIELABToSRGB(in float3 cielab)
{
    return XYZToSRGB(CIELABToXYZ(cielab));
}

// CIELCh conversion functions.
#include "include/color-spaces/lch.fxh"

float3 XYZToCIELCh(in float3 ciexyz, in float3 reference_white)
{
    return LabToLCh(XYZToCIELAB(ciexyz, reference_white));
}

float3 XYZToCIELCh(in float3 ciexyz)
{
    return LabToLCh(XYZToCIELAB(ciexyz));
}

float3 SRGBToCIELCh(in float3 srgb)
{
    return XYZToCIELCh(SRGBToXYZ(srgb));
}

float3 CIELChToXYZ(in float3 cielch, in float3 reference_white)
{
    return CIELABToXYZ(LChToLab(cielch), reference_white);
}

float3 CIELChToXYZ(in float3 cielch)
{
    return CIELABToXYZ(LChToLab(cielch));
}

float3 CIELChToSRGB(in float3 cielch)
{
    return CIELABToSRGB(LChToLab(cielch));
}

// END OF FILE.