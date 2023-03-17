// SPDX-License-Identifier: Unlicense

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "include/color-spaces/oklab.fxh"
#include "include/intrinsics.fxh"

// clang-format off
uniform bool _ApplyToe <
    ui_label = "Apply Lr Toe";
    ui_tooltip = "This allows CIE-L*-like luminance estimate.";
> = true;

uniform float _BlackPointIn < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Black Point [IN]";
    ui_category = "Levels in." __c;
    ui_min = 0.0;
    ui_max = 255.0;
    ui_step = 1.0;
> = 0.0;

uniform float _WhitePointIn < __UNIFORM_SLIDER_FLOAT1
    ui_label = "White Point [IN]";
    ui_category = "Levels in." __c;
    ui_min = 0.0;
    ui_max = 255.0;
    ui_step = 1.0;
> = 255.0;

uniform float _BlackPointOut < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Black Point [OUT]";
    ui_category = "Levels out." __c;
    ui_min = 0.0;
    ui_max = 255.0;
    ui_step = 1.0;
> = 0.0;

uniform float _WhitePointOut < __UNIFORM_SLIDER_FLOAT1
    ui_label = "White Point [OUT]";
    ui_category = "Levels out." __c;
    ui_min = 0.0;
    ui_max = 255.0;
    ui_step = 1.0;
> = 255.0;
// clang-format off

float ApplyLevelsIn(in float x, in float black_in, in float white_in)
{
    x = saturate(x - black_in) / min(1.0, white_in - black_in + nullFX::FP32Min);
    return x;
}

float ApplyLevelsOut(in float x, in float black_out, in float white_out)
{
    x = x * saturate(white_out - black_out) + black_out;
    return x;
}

float3 PS_Levels(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target 
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;
    float3 oklab = SRGBToOklab(color);

    if (_ApplyToe)
        oklab.x = ApplyToe(oklab.x);
    
    static const float rcp_255 = (1.0 / 255.0);
    oklab.x = ApplyLevelsIn(oklab.x, _BlackPointIn * rcp_255, _WhitePointIn * rcp_255);
    oklab.x = ApplyLevelsOut(oklab.x, _BlackPointOut * rcp_255, _WhitePointOut * rcp_255);

    if (_ApplyToe)
        oklab.x = RemoveToe(oklab.x);

    color = OklabToSRGB(oklab);
    return color;
}

technique Levels < ui_label = "Levels."; >
{
    pass
    {
        PixelShader = PS_Levels;
        VertexShader = PostProcessVS;
        SRGBWriteEnable = true;
    }
}

// vim:ts=4:sw=4:sts=4:et
// END OF FILE.
