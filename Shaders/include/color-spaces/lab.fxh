#include "include/color-spaces/cielab.fxh"
#include "include/color-spaces/oklab.fxh"

static const int oklab = 0;
static const int cielab = 1;

#define LAB_SELECTION_UI                                                                                               \
    uniform int _LabMode < __UNIFORM_COMBO_INT1 ui_label = "Lab Color Space";                                          \
    ui_items = "Oklab\0CIELAB\0";                                                                                      \
    > = oklab

float3 SRGBToLab(in float3 srgb, in int mode)
{
    switch (mode)
    {
    default:
        return SRGBToOklab(srgb);

    case cielab:
        return SRGBToCIELAB(srgb);
    }

    // so compiler doesn't freak out.
    return srgb;
}

float3 XYZToLab(in float3 ciexyz, in int mode)
{
    switch (mode)
    {
    default:
        return XYZToOklab(ciexyz);

    case cielab:
        return XYZToCIELAB(ciexyz);
    }

    return ciexyz;
}

float3 LabToSRGB(in float3 lab, in int mode)
{
    switch (mode)
    {
    default:
        return OklabToSRGB(lab);

    case cielab:
        return CIELABToSRGB(lab);
    }

    return lab;
}

float3 LabToXYZ(in float3 lab, in int mode)
{
    switch (mode)
    {
    default:
        return OklabToXYZ(lab);

    case cielab:
        return CIELABToXYZ(lab);
    }

    return lab;
}

float3 SRGBToLCh(in float3 srgb, in int mode)
{
    return LabToLCh(SRGBToLab(srgb, mode));
}

float3 XYZToLCh(in float3 ciexyz, in int mode)
{
    return LabToLCh(XYZToLab(ciexyz, mode));
}

float3 LChToSRGB(in float3 lch, in int mode)
{
    return LabToSRGB(LChToLab(lch), mode);
}

float3 LChToXYZ(in float3 lch, in int mode)
{
    return LabToXYZ(LChToLab(lch), mode);
}