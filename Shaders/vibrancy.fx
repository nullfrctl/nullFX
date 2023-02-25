/* nullFX: "Vibrancy" */

// This is an arbitrary implementation of a vibrancy effect.
// It effectively uses the chrominance of a color to determine whether it should
// have its chrominance increased or decreased. 
//
// Values above 1.0 add "saturation" to low-chrominance colors, while
// "de-seturating" high-chrominance colors.
//
// The opposite is also true, values below 1.0 will desaturate low colors
// while emphasizing high colors.

// Used: nullFX::BackBuffer, __pass(MACRO).
#include "intrinsics.fxh"

// Used: PostProcessVS()
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

// Used: SRGBToOklch(), OklchToSRGB().
#include "color-spaces/oklab.fxh"

// Use gamut re-mapping/clipping. 
#ifndef VIB_GAMUT_CLIPPING_ENABLE
#   define VIB_GAMUT_CLIPPING_ENABLE 0
#endif

uniform float _Vibrancy <__UNIFORM_DRAG_FLOAT1
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

#if VIB_GAMUT_CLIPPING_ENABLE
// Used: GamutClip().
#include "color-spaces/gamut-clipping.fxh"

uniform int _GamutClippingMode < __UNIFORM_COMBO_INT1
    ui_label = "Gamut Clipping Mode";
    __ui_category("Gamut clipping.");
    ui_items = "None.\0"
               "Preserve chroma.\0"
               "Project to 0.5.\0"
               "Project to Lcusp.\0"
               "Project to L0/05.    [Adaptive]\0"
               "Project to L0/Lcusp. [Adaptive]\0";
    ui_tooltip = "How to map colors back into SRGB space if they exceed [0.0,1.0].\n"
                 "This would be useful if you need to set a really high chrominance/saturation\n"
                 "or really high luminance/vibrance, as well as really low luminance/vibrance.\n"
                 "\n"
                 "Gamut clipping would map the out-of-gamut colors to their closest equivalent in\n"
                 "SRGB space. The options above are for what method to find the closest equivalent\n"
                 "\n"
                 "Adaptive algorithms use the alpha variable below.";
> = 4;

uniform float _GamutClippingAlpha < __UNIFORM_DRAG_FLOAT1
    ui_label = "Gamut Clipping Alpha";
    ui_tooltip = "The alpha value to apply to the adaptive gamut clipping algorithms.\n"
                 "\n"
                 "This only applies for gamut clipping modes marked adaptive, otherwise\n"
                 "they have no effect\n"
				 "\n"
				 "Alpha can be used to accentuate the effects of the gamut clipping.";
    ui_min = 1.0;
    ui_step = 0.1;
    __ui_category("Gamut clipping.");
> = 1.0;
#endif

float3 PS_Vibrancy(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;
  
	// We don't access oklch outside of this scope.  
    {
    	float3 oklch = SRGBToOklch(color);
		
		// Get absolute of vibrancy to stop cheaters.
		float vib = abs(_Vibrancy) + nullFX::FP16Scale; // Add FP16Scale so no div. by 0.
		
		float lerpfact = oklch.y * 2.5; // equiv. C/0.4 to get [0.0,1.0]
        oklch.y = lerp(oklch.y * vib, oklch.y / vib, lerpfact);
		
    	color = OklchToSRGB(oklch);
    }

#   if VIB_GAMUT_CLIPPING_ENABLE
    // Clip.
	color = GamutClip(color, _GamutClippingMode, _GamutClippingAlpha);
#   endif

    return color;
}

technique Vibrancy < ui_label = "Vibrancy"; ui_label = "nullFX: Vibrancy."; >
{
    __pass(PS_Vibrancy, PostProcessVS)
}