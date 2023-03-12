// SPDX-License-Identifier: Unlicense

#include "ReShade.fxh"
#include "ReShadeUI.fxh"
#include "color-spaces/oklab.fxh"
#include "intrinsics.fxh"

// clang-format off
uniform float _Vibrancy < __UNIFORM_DRAG_FLOAT1
    ui_label = "Vibrancy";
    ui_tooltip = "Values below 1.0 de-saturate low chrominance colors and\n"
                 "saturate high chrominance colors.\n"
                 "\n"
                 "Values above 1.0 saturates low chrominance colors and\n"
                 "de-saturate high chrominance colors the same.\n"
                 "\n"
                 "User Info: absolute value, negative values are the same as positives.";
    ui_min = 0.0;
> = 1.0;
// clang-format on

float3 PS_Vibrancy(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;
    float3 oklch = SRGBToOklch(color);

    // Get absolute of vibrancy to stop cheaters.
    float vib = abs(_Vibrancy) + nullFX::FP32Min; // Add FP32Min so no div. by 0.

    float lerpfact = oklch.y * 2.5; // equiv. C/0.4 to get [0.0,1.0]

    oklch.y = lerp(oklch.y * vib, oklch.y / vib, lerpfact);
    oklch.y = clamp(oklch.y, 0.0, 0.4); // clamp to normal range.

    color = OklchToSRGB(oklch);

    return color;
}

technique Vibrancy < ui_label = "Vibrancy";
>
{
    pass
    {
        PixelShader = PS_Vibrancy;
        VertexShader = PostProcessVS;
        SRGBWriteEnable = true;
    }
}

// END OF FILE.
