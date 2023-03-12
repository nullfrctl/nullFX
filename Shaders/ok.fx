// SPDX-License-Identifier: Unlicense

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "intrinsics.fxh"

#include "color-spaces/oklab.fxh"

// clang-format off
uniform bool _ApplyToe <
    ui_label = "Apply Lr Toe";
    ui_category = "Oklab settings.";
    ui_tooltip = "Apply Bjorn's Lr toe to the L channel to get a CIE-L*ab like lightness estimate.\n"
                 "\n"
                 "This could allow you to get a different style of luminance modification.";
> = true;

uniform float _Luminance < __UNIFORM_DRAG_FLOAT1
    ui_label = "Luminance";
    ui_min = 0.0;
    ui_category = "Oklab settings.";
    ui_tooltip = "The \"brightness\" of a color that does not affect its perceived chroma vibrancy.";
    ui_spacing = 3;
> = 1.0;

uniform float _Chrominance < __UNIFORM_DRAG_FLOAT1
    ui_label = "Chrominance";
    ui_min = 0.0;
    ui_category = "Oklab settings.";
    ui_tooltip = "Non-uniform \"vibrance\" of a color. Different from saturation due to the\n"
                 "fact that it is non-uniform, but also means that perceived luminance does not\n"
                 "change.";
> = 1.0;

uniform float _LChHue < __UNIFORM_SLIDER_FLOAT1
    ui_label = "Hue";
    ui_min = -180.0;
    ui_max = 180.0;
    ui_step = 1.0;
    ui_category = "Oklab settings.";
> = 0.0;

uniform float2 _OklabAB < __UNIFORM_DRAG_FLOAT2
    ui_label = "Green-Red (a) & Blue-Yellow (b)";
    ui_category = "Oklab settings.";
    ui_spacing = 5;
> = 1.0;
// clang-format on

float3 PS_Okcolor(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;
    float3 oklch = SRGBToOklch(color);

    if (_ApplyToe)
        oklch.x = ApplyToe(oklch.x);

    // Oklch operations.
    oklch.x *= _Luminance;
    oklch.y *= _Chrominance;
    oklch.z += (_LChHue / 180.0) * 6.3;

    if (_ApplyToe)
        oklch.x = RemoveToe(oklch.x);

    // Clamp to normal range.
    oklch.x = saturate(oklch.x);
    oklch.y = clamp(oklch.y, 0.0, 0.4);

    float3 oklab = LChToLab(oklch);

    // Change a & b.
    oklab.yz *= _OklabAB;
    oklab.yz = clamp(oklab.yz, -0.4, 0.4);

    color = OklabToSRGB(oklab);

    return color;
}

technique Okcolor < ui_label = "Ok color spaces.";
>
{
    pass
    {
        PixelShader = PS_Okcolor;
        VertexShader = PostProcessVS;
        SRGBWriteEnable = true;
    }
}

// END OF FILE.
