// SPDX-License-Identifier: Unlicense
#pragma once

#include "include/intrinsics.fxh"

// clang-format off
static const float3x3 srgb_to_lms = float3x3(
    0.4122214708, 0.5363325363, 0.0514459929,
    0.2119034982, 0.6806995451, 0.1073969566,
    0.0883024619, 0.2817188376, 0.6299787005
);

static const float3x3 ciexyz_to_lms = float3x3(
    0.8189330101, 0.3618667424, -0.1288597137,
    0.0329845436, 0.9293118715, 0.0361456487,
    0.0482003018, 0.2643662691, 0.6338517070
);

static const float3x3 lms_to_oklab = float3x3(
    +0.2104542553, +0.7936177850, -0.0040720468,
    +1.9779984951, -2.4285922050, +0.4505937099,
    +0.0259040371, +0.7827717662, -0.8086757660
);

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

// row-major matrix from thi.ng/color.
static const float3x3 lms_to_ciexyz  = float3x3(
	+1.22701385110352119, -0.04058017842328059, -0.0763812845057069,
	-0.55779998065182220, +1.11225686961683020, -0.4214819784180127,
	+0.28125614896646783, -0.07167667866560119, +1.5861632204407950
);
// clang-format on

float3 SRGBToOklab(in float3 srgb)
{
    float3 lms = mul(srgb_to_lms, srgb);
    lms = cbrt(lms);

    float3 oklab = mul(lms_to_oklab, lms);
    return oklab;
}

float3 XYZToOklab(in float3 ciexyz)
{
    float3 lms = mul(ciexyz_to_lms, ciexyz);
    lms = cbrt(lms);

    float3 oklab = mul(lms_to_oklab, lms);
    return oklab;
}

float3 OklabToSRGB(in float3 oklab)
{
    float3 lms = mul(oklab_to_lms, oklab);
    lms = pow3(lms);

    float3 srgb = mul(lms_to_srgb, lms);
    return srgb;
}

float3 OklabToXYZ(in float3 oklab)
{
    float3 lms = mul(oklab_to_lms, oklab);
    lms = pow3(lms);

    // lms_to_ciexyz is row major.
    float3 ciexyz = mul(lms, lms_to_ciexyz);
    return ciexyz;
}

// Oklch conversion functions.
#include "include/color-spaces/lch.fxh"

float3 SRGBToOklch(in float3 srgb)
{
    return LabToLCh(SRGBToOklab(srgb));
}

float3 XYZToOklch(in float3 srgb)
{
    return LabToLCh(XYZToOklab(srgb));
}

float3 OklchToSRGB(in float3 oklch)
{
    return OklabToSRGB(LChToLab(oklch));
}

float3 OklchToXYZ(in float3 oklch)
{
    return OklabToXYZ(LChToLab(oklch));
}

// functions for Lr toe.
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
