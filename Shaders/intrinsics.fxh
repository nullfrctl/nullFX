#pragma once

/* nullFX: Intrinsic functions alike to a common.fxh on other repositories. */

// Resources used:
// https://www.khronos.org/opengl/wiki/Small_Float_Formats
// https://en.wikipedia.org/wiki/Single-precision_floating-point_format

#define __pass(PS, VS) \
pass { PixelShader = PS; VertexShader = VS; SRGBWriteEnable = true; }

// UI category formatter.
#define __ui_category(cat) ui_category = cat##"\n\n"

// Take a single-paramter float(1) function and expand it to use float2/3/4.
#define __overload_float(f) \
float2 f(in float2 x) { return float2(f(x.x), f(x.y)); } \
float3 f(in float3 x) { return float3(f(x.xy), f(x.z)); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); }

#define _PI 3.1415926535897932384

// Use preprocessor to allow constant folding, etc.
#define pow2(x) (x * x)
#define pow3(x) (x * x * x)

// cube root: avoids division by zero.
float cbrt(in float x)
{
    static const float one_third = (1.0 / 3.0);
    float y = sign(x) * pow(abs(x), one_third);

    return y;
}
__overload_float(cbrt)

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
    texture2D BackBufferTex : COLOR;

    sampler2D BackBuffer
    {
        Texture = BackBufferTex;
        SRGBTexture = true;
    };

    static const float Singularity = 1e-7; // Marty said any number smaller than this is truncated to 0.
    static const float FP32Min = 1.1754943508 * 10e-38; // Smallest (normal) 32-bit floating-point number.
    static const float3 SRGBCoefficients = float3(0.2126, 0.7152, 0.0722);
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
