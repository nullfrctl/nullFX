#pragma once

/* nullFX/Color spaces: Oklab */

// Used: cbrt(), pow3().
#include "intrinsics.fxh"

// Convert SRGB to "LMS" values.
static const float3x3 srgb_to_lms = float3x3(
    0.4122214708, 0.5363325363, 0.0514459929,
    0.2119034982, 0.6806995451, 0.1073969566,
    0.0883024619, 0.2817188376, 0.6299787005
);

// Convert "LMS" values to Oklab color.
static const float3x3 lms_to_oklab = float3x3(
    +0.2104542553, +0.7936177850, -0.0040720468,
    +1.9779984951, -2.4285922050, +0.4505937099,
    +0.0259040371, +0.7827717662, -0.8086757660
);

float3 SRGBToOklab(in float3 srgb)
{
    // HLSL assumes column-major when using float3, so this multiplication is optimzied.
    float3 lms = mul(srgb_to_lms, srgb);
    lms = cbrt(lms); // Apply Oklab non-linearity.
    
    // Again, column-major assumption.
    float3 oklab = mul(lms_to_oklab, lms);

    return oklab;
}

static const float3x3 oklab_to_lms = float3x3(
    +1.0000000000, +0.3963377774, +0.2158037573,
    +1.0000000000, -0.1055613458, -0.0638541728,
    +1.0000000000, -0.0894841775, -1.2914855480
);

static const float3x3 lms_to_srgb = float3x3(
    +4.0767416621, -3.3077115913, +0.2309699292,
    -1.2684380046, +2.6097574011, -0.3413193965,
    -0.0041960863, -0.7034186147, +1.7076147010
);

float3 OklabToSRGB(in float3 oklab)
{
    // Convert our Oklab values back to LMS. 
    // Since in the original math there is no multiplication done on the L channel, 
    // we just set it to 1.0.
    float3 lms = mul(oklab_to_lms, oklab);
    lms = pow3(lms); // Reverse Oklab curve.

    // Convert "LMS" values to SRGB
    float3 srgb = mul(lms_to_srgb, lms);

    return srgb;
}

// Generic Lab to LCh function.
float3 LabToLCh(in float3 lab)
{
    float C = sqrt(pow2(lab.y) + pow2(lab.z)); // sqrt(a^2 + b^2)
    float h = atan2(lab.z, lab.y); // atan(b/a)

    // L,C,h.
    return float3(lab.x, C, h);
}

// Generic LCh to Lab function.
float3 LChToLab(in float3 lch)
{
    float a = lch.y * cos(lch.z); // C * cos(h);
    float b = lch.y * sin(lch.z); // C * sin(h);

    // L,a,b.
    return float3(lch.x, a, b);
}

// These are essentially shortcuts.
float3 SRGBToOklch(in float3 srgb)
{
    return LabToLCh(SRGBToOklab(srgb));
}

// . . .
float3 OklchToSRGB(in float3 oklch)
{
    return OklabToSRGB(LChToLab(oklch));
}

// Lr toe.
float ApplyToe(float x)
{
    float k_1 = 0.206f;
    float k_2 = 0.03f;
    float k_3 = (1.f + k_1) / (1.f + k_2);
    return 0.5f * (k_3 * x - k_1 + sqrt((k_3 * x - k_1) * (k_3 * x - k_1) + 4.f * k_2 * k_3 * x));
}

float RemoveToe(float x)
{
    float k_1 = 0.206f;
    float k_2 = 0.03f;
    float k_3 = (1.f + k_1) / (1.f + k_2);
    return (x * x + k_1 * x) / (k_3 * (x + k_2));
}

// END OF FILE.