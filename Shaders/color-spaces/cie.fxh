#pragma once

/* nullFX/Color spaces: CIE color spaces. */

// Used: cbrt(), pow3(), pow2().
#include "intrinsics.fxh"

// Convert SRGB to CIE XYZ
static const float3x3 srgb_to_cie_xyz = float3x3(
    0.4124, 0.3576, 0.1805,
    0.2126, 0.7152, 0.0722,
    0.0193, 0.1192, 0.9505
);

float3 SRGBToXYZ(in float3 srgb)
{
    // Column-major matrix multiplication.
    float3 xyz = mul(srgb_to_cie_xyz, srgb);
    return xyz;
}

// Convert CIE XYZ to SRGB
static const float3x3 cie_xyz_to_srgb = float3x3(
    +3.2406255, -1.5372080, -0.4986286,
    -0.9689307, +1.8757561, +0.0415175,
    +0.0557101, -0.2040211, +1.0569959
);

float3 XYZToSRGB(in float3 xyz)
{
    // Column-major matrix multiplication.
    float3 srgb = mul(cie_xyz_to_srgb, xyz);
    return srgb;
}

/* "Abandon All Hope, Ye Who Enter Here." */

#ifdef CIE_LAB

// Used for CIE Lab calculation.
static const float e = 216.0 / 24389.0;
static const float k = 24389.0 / 27.0;

float3 XYZToLab(in float3 xyz, in float3 illuminant)
{

    float3 f = xyz / illuminant;

    f.x = f.x > e ? cbrt(f.x) : (k * f.x + 16.0) / 116.0;
    f.y = f.y > e ? cbrt(f.y) : (k * f.y + 16.0) / 116.0;
    f.z = f.z > e ? cbrt(f.z) : (k * f.z + 16.0) / 116.0;

    float L = 116.0 * f.y - 16.0;
    float a = 500.0 * (f.x - f.y);
    float b = 200.0 * (f.y - f.z);

    return float3(L, a, b);
}

float3 LabToXYZ(in float3 lab, in float3 illuminant)
{
    float3 f;
    f.y = (lab.x + 16.0) / 116.0;
    f.x = lab.y / 500.0 + f.y;
    f.z = f.y - lab.z / 200.0;
    float3 f3 = pow3(f);

    float3 r;
    r.x = f3.x > e ? f3.z : (116.0 * f.x - 16.0) / k;
    r.y = lab.x > (k * e) ? pow3((lab.x + 16.0) / 116.0) : lab.x / k;
    r.z = f3.z > e ? f3.z : (116.0 * f.z - 16.0) / k;

    float3 xyz = r * illuminant;

    return xyz;
}

static const float3 d65_illuminant = float3(0.950489, 1.0, 1.088840);

// Single-component overloads. Assumes D65.
float3 XYZToLab(in float3 xyz)
{
    return XYZToLab(xyz, d65_illuminant);
}

float3 LabToXYZ(in float3 lab)
{
    return LabToXYZ(lab, d65_illuminant);
}
#endif