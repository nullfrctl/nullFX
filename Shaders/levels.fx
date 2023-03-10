/* nullFX: "Levels" */

// Used: nullFX::BackBuffer, __pass(MACRO).
#include "intrinsics.fxh"

// Used: PostProcessVS()
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

// Used: SRGBToOklab(), OklabToSRGB(), ApplyToe(), RemoveToe().
#include "color-spaces/oklab.fxh"

uniform bool _ApplyToe <
    ui_label = "Apply Lr Toe";
    ui_tooltip = "This allows CIE-L*-like luminance estimate.";
> = true;

uniform float _BlackPointIn < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Black Point [IN]";
    __ui_category("Levels in.");
    ui_min = 0.0;
    ui_max = 1.0;
> = 0.0;

uniform float _WhitePointIn < __UNIFORM_SLIDER_FLOAT1
    ui_label = "White Point [IN]";
    __ui_category("Levels in.");
    ui_min = 0.0;
    ui_max = 1.0;
> = 1.0;

uniform float _BlackPointOut < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Black Point [OUT]";
    __ui_category("Levels out.");
    ui_min = 0.0;
    ui_max = 1.0;
> = 0.0;

uniform float _WhitePointOut < __UNIFORM_SLIDER_FLOAT1
    ui_label = "White Point [OUT]";
    __ui_category("Levels out.");
    ui_min = 0.0;
    ui_max = 1.0;
> = 1.0;

float ApplyLevelsIn(in float x, in float black_in, in float white_in)
{
    x = saturate(x - black_in) / max(white_in - black_in, nullFX::FP32Min);
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

    {
        // Convert to Oklab.
        float3 oklab = SRGBToOklab(color);

        // Lr toe.
        if (_ApplyToe)
        {
            oklab.x = ApplyToe(oklab.x);
        }

        // Apply levels.
        oklab.x = ApplyLevelsIn(oklab.x, _BlackPointIn, _WhitePointIn);
        oklab.x = ApplyLevelsOut(oklab.x, _BlackPointOut, _WhitePointOut);

        // Remove Lr toe.
        if (_ApplyToe)
        {
            oklab.x = RemoveToe(oklab.x);
        }

        // Go back to SRGB.
        color = OklabToSRGB(oklab);
    }

    return color;
}

technique Levels < ui_label = "Levels."; >
{
    __pass(PS_Levels, PostProcessVS)
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
