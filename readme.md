
Structure:
```cpp
/* nullFX: "(the purpose of the shader)" */

// Used: (the functions, variables, and macros included from intrinsics)
#include "intrinsics.fxh"

// Used: (the parts of ReShade.fxh and ReShadeUI.fxh used)
#include "ReShade.fxh"
#include "ReShadeUI.fxh"

// (description of the #define)
#ifndef (ALL CAPS SHADER NAME OR PREFIX)_(FEATURE)_ENABLE
#   define (ALL CAPS SHADER NAME OR PREFIX)_(FEATURE)_ENABLE (1 or 0)
#endif

// Used: (the functions used from any other include)
#include "(header)"

uniform (type) _(TitleCaseWithNoSpaces) < __UNIFORM_(UI TYPE)_(VARIABLE TYPE)
    ui_label = "(Title Case With Spaces)";
    ui_min = (minimum value);
    ui_max = (maximum value);
    ui_category = "§ (Normal sentence case with period at the end.)";
    ui_items = "(Items in the variable)";
    ui_tooltip = "(Info about the UI variable)";
> = (default value)

#if (ALL CAPS SHADER NAME OR PREFIX)_(FEATURE)_ENABLE
#include "(header associated with FEATURE)"

uniform (type) _(TitleCaseWithNoSpaces) < __UNIFORM_(UI TYPE)_(VARIABLE TYPE)
    ui_label = "(Title Case With Spaces)";
    ui_min = (minimum value);
    ui_max = (maximum value);
    ui_category = "§ (Normal sentence case with period at the end.)";
    ui_tooltip = "(Info about the UI variable)";
> = (default value)
#endif

static const float (TitleCaseWithNoSpaces) = 0.0;

float (TitleCaseWithNoSpaces)()
{
    return 0;
}

float3 PS_(TitleCaseWithNoSpaces)(in float4 position : SV_Position, in float2 texcoord : TEXCOORD) : SV_Target
{
    float3 color = tex2D(nullFX::BackBuffer, texcoord).rgb;

    float (lowercase_with_underline_separators);

    (the code)

    return color;
}

technique (TitleCaseWithNoSpaces) < ui_label = "(Sentence case with period at the end)"; >
{
    __pass((The PixelShader), PostProcessVS)
}