// SPDX-License-Identifier: Unlicense

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "include/color-spaces/oklab.fxh"
#include "include/global.fxh"
#include "include/sigmoids.fxh"
#include "include/linearized/Linearize.fxh"

// clang-format off
uniform bool _ApplyToe <
    ui_label = "Apply Lr Toe";
    ui_tooltip = "This allows CIE-L*-like luminance estimate.";
> = true;

uniform int _ContrastMode < __UNIFORM_COMBO_INT1
    ui_label = "Mode";
    ui_tooltip = "Positive chrominance will desaturate the image, while\n"
                 "Negative chrominance will saturate the image.\n"
                 "\n"
                 "Negative chrominance will mimic Curves.fx behavior.";
    ui_items = "Luminance\0"
               "Chrominance\0"
               "Luminance and Chrominance    [Neg. C Contrast]\0"
               "Luminance and Chrominance    [Pos. C Contrast]\0";
> = 0;

uniform int _ContrastFormula < __UNIFORM_COMBO_INT1
    ui_label = "Formula / Sigmoid Function";
    ui_tooltip = "What sigmoid to apply to the selected channels?\n"
                 "Different formulas will give you different results, e.g.\n"
                 "Perlin's Smootherstep will give you more harsh contrast while\n"
                 "Sine will give you smooth, uniform contrast.";
    ui_items = "Sine\0"
               "Abs split\0"
               "Smoothstep\0"
               "Exp formula\0"
               "Simplified Catmull-Rom (0,0,1,1)\0"
               "Perlins Smootherstep\0"
               "Abs add\0"
               "Parabola\0";
> = 0;

uniform float _Contrast < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Contrast / Lerpfact";
    ui_tooltip = "The amount of contrast to apply.";
    ui_min = -1.0;
    ui_max = 1.0;
> = 0.5;
// clang-format on

float ApplyContrast(in float x)
{
    // A monster.
    switch (_ContrastFormula)
    {
    default: // Sine (default).
        return Sigmoids::Sine(x);

    case 1: // Abs split.
        return Sigmoids::AbsSplit(x);

    case 2: // Smoothstep.
        return Sigmoids::Smoothstep(x);

    case 3: // Exp.
        return Sigmoids::Exp(x);

    case 4: // Catmull-Rom.
        return Sigmoids::CatmullRom(x);

    case 5: // Smootherstep.
        return Sigmoids::Smootherstep(x);

    case 6: // Abs add.
        return Sigmoids::AbsAdd(x);

    case 7: // Parabola.
        return Sigmoids::Parabola(x);
    }

    // Redundant return case so compiler doesn't freak out.
    return x;
}

float3 PS_CurvesEnhanced(in float4 position : SV_POSITION, in float2 texcoord : TEXCOORD) : SV_TARGET
{
    float3 color = GetBackBuffer(texcoord.xy).rgb;
    float3 oklch = SRGBToOklch(color);

    if (_ApplyToe)
        oklch.x = ApplyToe(oklch.x);

    float2 lc = oklch.xy;
    lc.x = ApplyContrast(lc.x);
    lc.y = ApplyContrast(lc.y);

    switch (_ContrastMode)
    {
    default:
        oklch.x = lerp(oklch.x, lc.x, _Contrast);
        break;

    case 1: // Used negative contrast to match Curves.fx.
        oklch.y = lerp(oklch.y, lc.y, -_Contrast);
        break;

    case 2:
        oklch.xy = lerp(oklch.xy, lc, float2(_Contrast, -_Contrast));
        break;

    case 3:
        oklch.xy = lerp(oklch.xy, lc, _Contrast);
        break;
    }

    if (_ApplyToe)
        oklch.x = RemoveToe(oklch.x);

    color = OklchToSRGB(oklch);
    return DisplayBackBuffer(color);
}

technique CurvesEnhanced < ui_label = "Curves enhanced.";
ui_tooltip = "nullFX: Curves enhanced.\n"
             "\n"
             "This shader is CeeJay.dk's \"Curves.fx\" converted to work with\n"
             "the Oklab perceptual color space.\n"
             "\n"
             "While the options are a bit reduced, the overall effect is subjectively enhanced.";
>
{
    pass
    {
        PixelShader = PS_CurvesEnhanced;
        VertexShader = PostProcessVS;
        SRGBWriteEnable = true;
    }
}

// END OF FILE.
