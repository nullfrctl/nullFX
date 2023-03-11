/* nullFX: "Curves Enhanced" */

// This shader is in essence CeeJay.dk's Curves.fx shader made to use
// Oklch instead of SRGB-calculated chrominance and luminance values.

// Used: nullFX::BackBuffer, __pass(MACRO).
#include "intrinsics.fxh"

// Used: PostProcessVS()
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

// Used: SRGBToOklab(), OklabToSRGB(), ApplyToe(), RemoveToe().
#include "color-spaces/oklab.fxh"

// Used: all functions.
#include "sigmoids.fxh"

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

float3 PS_CurvesEnhanced(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;
    float3 oklch = SRGBToOklch(color);

    // Lr toe.
    if (_ApplyToe)
        oklch.x = ApplyToe(oklch.x);
    
    switch (_ContrastMode)
    {
    default:
        float l = ApplyContrast(oklch.x);
        oklch.x = lerp(oklch.x, l, _Contrast);
        break;
    case 1:
        float c = ApplyContrast(oklch.y);
        oklch.y = lerp(oklch.y, c, -_Contrast);
        break;
    case 2:
        float2 lc_pos = oklch.xy;
        lc_pos.x = ApplyContrast(lc_pos.x);
        lc_pos.y = ApplyContrast(lc_pos.y);
        oklch.xy = lerp(oklch.xy, lc_pos, float2(_Contrast, -_Contrast));
        break;
    case 3:
        float2 lc_neg = oklch.xy;
        lc_neg.x = ApplyContrast(lc_neg.x);
        lc_neg.y = ApplyContrast(lc_neg.y);
        oklch.xy = lerp(oklch.xy, lc_neg, _Contrast);
        break;
    }

    // Remove Lr toe.
    if (_ApplyToe)
        oklch.x = RemoveToe(oklch.x);

    // Go back to SRGB.
    color = OklchToSRGB(oklch);

    return color;
}

technique CurvesEnhanced < 
    ui_label = "Curves enhanced."; 
    ui_tooltip = "nullFX: Curves enhanced.\n"
                 "\n"
                 "This shader is CeeJay.dk's \"Curves.fx\" converted to work with\n"
                 "the Oklab perceptual color space.\n"
                 "\n"
                 "While the options are a bit reduced, the overall effect is subjectively enhanced.";
>
{
    __pass(PS_CurvesEnhanced, PostProcessVS)
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
