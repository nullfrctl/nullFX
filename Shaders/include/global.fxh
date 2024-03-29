// SPDX-License-Identifier: Unlicense
#pragma once

#include "ReShade.fxh"
#define _PI 3.1415926535897932384

// Use preprocessor to allow constant folding, etc.
#define pow2(x) (x * x)
#define pow3(x) (x * x * x)

// Format for categories.
#define NL "\n\n"

// cube root: avoids division by zero.
float cbrt(in float x)
{
    static const float one_third = (1.0 / 3.0);
    float y = sign(x) * pow(abs(x), one_third);

    return y;
}

float2 cbrt(in float2 x)
{
    static const float one_third = (1.0 / 3.0);
    float2 y = sign(x) * pow(abs(x), one_third.xx);

    return y;
}

float3 cbrt(in float3 x)
{
    static const float one_third = (1.0 / 3.0);
    float3 y = sign(x) * pow(abs(x), one_third.xxx);

    return y;
}

// error < 0.2 degrees, saves about 40% vs atan2 developed by Lord of Lunacy and Marty McFly
float fast_atan2(float y, float x)
{
    bool a = abs(y) < abs(x);
    float i = (a) ? (y * (1.0 / x)) : (x * (1.0 / y));
    i = i * (1.0584 + abs(i) * -0.273);
    float piadd = y > 0.0 ? _PI : -_PI;
    i = a ? (x < 0.0 ? piadd : 0.0) + i : 0.5 * piadd - i;

    return i;
}

// nullFX-specific.
namespace nullFX
{
// Smallest 32-bit normal number.
static const float FP32Min = 1.1754943508 * 10e-38;

// Rec.709 luma coefficients.
static const float3 SRGBCoefficients = float3(0.2126, 0.7152, 0.0722);
} // namespace nullFX

// vim: ts=4:sw=4:sts=4:et
// END OF FILE.
