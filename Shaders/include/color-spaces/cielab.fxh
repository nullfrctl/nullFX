// SPDX-License-Identifier: Unlicense
#pragma once

#include "include/color-spaces/ciexyz.fxh"
#include "include/intrinsics.fxh"

static const float epsilon = (216.0 / 24389.0);
static const float d65 = float3(0.95047, 1.0, 1.08883);

float3 XYZToCIELAB(in float3 ciexyz, in float3 reference_white)
{
    float3 xyz = ciexyz / reference_white;

    xyz.x = xyz.x > epsilon ? cbrt(xyz.x) : (7.787 * xyz.x + 16.0 / 116.0);
    xyz.y = xyz.y > epsilon ? cbrt(xyz.y) : (7.787 * xyz.y + 16.0 / 116.0);
    xyz.z = xyz.z > epsilon ? cbrt(xyz.z) : (7.787 * xyz.z + 16.0 / 116.0);

    float3 cielab;
    cielab.x = (116.0 * xyz.y) - 16.0;
    cielab.y = 500 * (xyz.x - xyz.y);
    cielab.z = 200 * (xyz.y - xyz.z);

    return cielab;
}

// default to D65.
float3 XYZToCIELAB(in float3 ciexyz)
{
    return XYZToCIELAB(ciexyz, d65);
}

float3 CIELABToXYZ(in float3 cielab, in float3 reference_white)
{
    float3 xyz;
    xyz.y = (cielab.x + 16.0) / 116.0;
    xyz.x = cielab.y / 500.0 + xyz.y;
    xyz.z = xyz.y - cielab.z / 200.0;

    float3 xyz3 = pow3(xyz);

    xyz.x = xyz3.x > epsilon ? xyz3.x : ((xyz.x - 16.0 / 116.0) / 7.787);
    xyz.y = xyz3.y > epsilon ? xyz3.y : ((xyz.y - 16.0 / 116.0) / 7.787);
    xyz.z = xyz3.z > epsilon ? xyz3.z : ((xyz.z - 16.0 / 116.0) / 7.787);

    float3 ciexyz = xyz * reference_white;
    return ciexyz;
}

// default to D65.
float3 CIELABToXYZ(in float3 cielab)
{
    return CIELABToXYZ(cielab, d65);
}

// CIELCh conversion functions.
#include "include/color-spaces/lch.fxh"

float3 XYZToCIELCh(in float3 ciexyz, in float3 reference_white)
{
    return LabToLCh(XYZToCIELAB(ciexyz, reference_white));
}

float3 XYZToCIELCh(in float3 ciexyz)
{
    return LabToLCh(XYZToCIELAB(ciexyz, d65));
}

float3 CIELChToXYZ(in float3 cielch, in float3 reference_white)
{
    return CIELABToXYZ(LChToLab(cielch, reference_white));
}

float3 CIELChToXYZ(in float3 cielch)
{
    return CIELABToXYZ(LChToLab(cielch, d65));
}

// END OF FILE.