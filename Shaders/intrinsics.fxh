// Accepted #defines: _HALLEY_ITERATION [0/1]
#pragma once

/* nullFX: Intrinsic functions--alike to a common.fxh on other repositories. */

#define __overload_float( f ) \
float2 f(in float2 x) { return float2(f(x.x), f(x.y)); } \
float3 f(in float3 x) { return float3(f(x.xy), f(x.z)); } \
float4 f(in float4 x) { return float4(f(x.xy), f(x.zw)); }

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

    // If the code requires us to do a halley iteration to compensate for the innacuracy of 1/3.
#   if _HALLEY_ITERATION
    float y3 = pow3(y);
    y *= (y3 + 2.0 * x) / (2.0 * y3 + x);
#   endif

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

    shared static const float Pi = 3.141592653589793115997963468544185161590576171875; // Accurate Pi.
}

#define __pass(PS, VS) \
pass { PixelShader = PS; VertexShader = VS; SRGBWriteEnable = true; }

#define __ui_category(cat) ui_category = cat##"\n\n"

// END OF FILE.