#pragma once

/* nullFX: Intrinsic functions alike to a common.fxh on other repositories. */

// Resources used:
// https://www.khronos.org/opengl/wiki/Small_Float_Formats
// https://en.wikipedia.org/wiki/Single-precision_floating-point_format

#define __pass(PS, VS) \
pass { PixelShader = PS; VertexShader = VS; SRGBWriteEnable = true; }

#define __ui_category(cat) \
ui_category = cat##"\n\n"

// Take a single-paramter float(1) function and expand it to use float2/3/4.
#define __overload_float(f) \
float2 f(in float2 x) { return float2(f(x.x), f(x.y)); } \
float3 f(in float3 x) { return float3(f(x.xy), f(x.z)); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); }

// Take a single-paramter float2 function and expand it to use float3/4.
#define __overload_float2(f) \
float3 f(in float3 x) { return float3(f(x.xy), f(x.zz).y); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); } \

// Take a single-paramter float3 function and expand it to use float4.
#define __overload_float3(f) \
float4 f(in float4 x) { return float4(f(x.xyz), f(x.www).x)}

#define _PI 3.14159265358979323846

// nullFX-specific.
namespace nullFX
{
    texture2D BackBufferTex : COLOR;

    sampler2D BackBuffer
    {
        Texture = BackBufferTex;
        SRGBTexture = true;
    };

    static const float FP32Min = 1.1754943508 * 10e-38; // Smallest (normal) 32-bit floating-point number.
    static const float3 SRGBCoefficients = float3(0.2126, 0.7152, 0.0722);
}

// shortcut to x*x / x^2
#define pow2(x) (x * x)

// Use preprocessor to allow constant folding, etc.
#define pow3(x) (x * x * x)

// cube root: avoids division by zero.
float cbrt(in float x)
{
    static const float one_third = (1.0 / 3.0);
    float y = sign(x) * pow(abs(x), one_third);

    return y;
}
__overload_float(cbrt)

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
