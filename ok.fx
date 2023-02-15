/* nullFX: "Ok color spaces." */

// Used: nullFX::BackBuffer(), __pass(MACRO).
#include "intrinsics.fxh"

// Used: PostProcessVS().a
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

// Use gamut re-mapping/clipping.
#ifndef OK_GAMUT_CLIPPING_ENABLE
#	define OK_GAMUT_CLIPPING_ENABLE 1
#endif

// Enable color alteration using Okhsv.
#ifndef OK_OKHSV_CORRECTION_ENABLE
#   define OK_OKHSV_CORRECTION_ENABLE 1
#endif

// Used: SRGBToOklab(), OklabToSRGB(), LabToLCh(), LChToLab(), SRGBToOklch(), OklchToSRGB().
#include "color-spaces/oklab.fxh"

uniform float _Luminance < __UNIFORM_DRAG_FLOAT1
    ui_label = "Luminance";
    ui_min = 0.0;
    ui_category = "Oklab settings.";
    ui_tooltip = "The \"brightness\" of a color that does not affect its perceived chroma vibrancy.";
> = 1.0;

uniform bool _ApplyToe <
    ui_label = "Apply Lr Toe";
    ui_category = "Oklab settings.";
    ui_tooltip = "Apply Bjorn's Lr toe to the L channel to get a CIE-L*ab like lightness estimate.\n"
                 "\n"
                 "This could allow you to get a different style of luminance modification.";
> = true;

uniform float _Chrominance < __UNIFORM_DRAG_FLOAT1
    ui_label = "Chrominance";
    ui_min = 0.0;
    ui_category = "Oklab settings.";
    ui_tooltip = "Non-uniform \"vibrance\" of a color. Different from saturation due to the\n"
                 "fact that it is non-uniform, but also means that perceived luminance does not\n"
                 "change.";
> = 1.0;

uniform float2 _OklabAB < __UNIFORM_DRAG_FLOAT2
    ui_label = "Green-Red (a) & Blue-Yellow (b)";
    ui_category = "Oklab settings.";
> = 1.0;

#if OK_OKHSV_CORRECTION_ENABLE
// Used: SRGBToOkhsv(), OkhsvToSRGB().
#include "color-spaces/okhsv-okhsl.fxh"

uniform float _Saturation < __UNIFORM_DRAG_FLOAT1
    ui_label = "Saturation";
    ui_min = 0.0;
    ui_category = "Okhsv settings.";
    ui_tooltip = "This is a perceptually accurate, yet uniform saturation.\n"
                 "It's difference from the chrominance above is that Okhsv is simply a\n"
                 "square representation of Oklch, meaning that the non-uniform chrominance\n"
                 "is repurposed into a saturation value that applies across all colors equally.\n"
                 "\n"
                 "Because we do not use something like normal HSV, though, perceived lightness does\n"
                 "not change as dramatically.";
> = 1.0;

uniform float _Vibrance < __UNIFORM_DRAG_FLOAT1
    ui_label = "Vibrance";
    ui_category = "Okhsv settings.";
    ui_tooltip = "This is the equivalent of saturation above but instead applied on the\n"
                 "\"brightness\" or \"value\" of a color. It's not the same as luminance.";
    ui_min = 0.0;
> = 1.0;
#endif

#if OK_GAMUT_CLIPPING_ENABLE
uniform int _GamutClippingMode < __UNIFORM_COMBO_INT1
    ui_label = "Gamut Clipping Mode";
    ui_items = "None.\0"
               "Preserve chroma.\0"
               "Project to 0.5.\0"
               "Project to Lcusp.\0"
               "[Adaptive] L0/05.\0"
               "[Adaptive] L0/Lcusp.\0";
    ui_category = "Gamut clipping.";
    ui_tooltip = "How to map colors back into SRGB space if they exceed [0.0,1.0].\n"
                 "This would be useful if you need to set a really high chrominance/saturation\n"
                 "or really high luminance/vibrance, as well as really low luminance/vibrance.\n"
                 "\n"
                 "Gamut clipping would map the out-of-gamut colors to their closest equivalent in\n"
                 "SRGB space. The options above are for what method to find the closest equivalent\n"
                 "\n"
                 "Adaptive algorithms use the alpha variable below.";
> = 5;

uniform float _GamutClippingAlpha < __UNIFORM_DRAG_FLOAT1
    ui_label = "Adaptive Gamut Clipping Alpha";
    ui_tooltip = "The alpha value to apply to the adaptive gamut clipping algorithms.\n"
                 "\n"
                 "This only applies for gamut clipping modes marked adaptive, otherwise\n"
                 "they have no effect";
    ui_min = 0.0;
    ui_category = "Gamut clipping.";
> = 1.0;

// Used: GamutClip().
#include "color-spaces/gamut-clipping.fxh"
#endif


float3 PS_Okcolor(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;

    // SRGB to Oklab.
    float3 ok = SRGBToOklch(color);

    // Apply toe to apply luminance changing operations using CIEL*ab-like luminance estimation.
    if (_ApplyToe)
    {
        ok.x = ApplyToe(ok.x);
    }

    // Oklch operations.
    ok.xy *= float2(_Luminance, _Chrominance); // Multiply Oklch's lc, but preserve h.
    ok = LChToLab(ok);

    // Oklab operations.
    ok.yz *= _OklabAB;

    // Remove the toe for Oklab to SRGB conversion to work as intended.
    if (_ApplyToe)
    {
        ok.x = RemoveToe(ok.x);
    }

#   if OK_OKHSV_CORRECTION_ENABLE
    // Oklab to SRGB.
    float3 okhsv = SRGBToOkhsv(OklabToSRGB(ok));
    okhsv.yz *= float2(_Saturation,_Vibrance);
    color = OkhsvToSRGB(okhsv);
#   endif

#   if OK_GAMUT_CLIPPING_ENABLE
    // Clip.
    color = GamutClip(color, _GamutClippingMode, _GamutClippingAlpha);
#   endif

    return color;
}

technique Okcolor < ui_label = "Ok color spaces"; >
{
    __pass (PS_Okcolor, PostProcessVS)
}