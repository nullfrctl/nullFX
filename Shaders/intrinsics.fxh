#pragma once

/* nullFX: Intrinsic functions alike to a common.fxh on other repositories. */

#define __overload_float(f) \
float2 f(in float2 x) { return float2(f(x.x), f(x.y)); } \
float3 f(in float3 x) { return float3(f(x.xy), f(x.z)); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); }

#define __overload_float2(f) \
float3 f(in float3 x) { return float3(f(x.xy), f(x.zz).y); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); } \

#define __overload_float3(f) \
float4 f(in float4 x) { return float4(f(x.xyz), f(x.www).z)}

// shortcut to x*x / x^2
float pow2(in float x)
{
    return x * x;
}
__overload_float(pow2);

// shortcut to x*x*x / x^3
float pow3(in float x)
{
    return x * x * x;
}
__overload_float(pow3);

// cube root: avoids division by zero.
float cbrt(in float x) 
{ 
    float y = sign(x) * pow(abs(x), 1.0 / 3.0); 

    return y;
}
__overload_float(cbrt);

// nullFX-specific.
namespace nullFX
{
    texture2D BackBufferTex : COLOR;

    sampler2D BackBuffer
    {
        Texture = BackBufferTex;
        SRGBTexture = true;
    };

    static const float Pi = 3.141592653589793115997963468544185161590576171875; // Accurate Pi.
    static const float FP16Scale = 2e-10; // Smallest number storable in a 16-bit float such as (0.0 + FP16Scale) != 0.0.
}

#define __pass(PS, VS) \
pass { PixelShader = PS; VertexShader = VS; SRGBWriteEnable = true; }

#define __ui_category(cat) ui_category = cat##"\n\n"

// END OF FILE.