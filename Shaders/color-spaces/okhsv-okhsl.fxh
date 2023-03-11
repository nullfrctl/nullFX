#pragma once

/* nullFX: Okhsv and Okhsl. */

// Used: nullFX::Pi.
#include "intrinsics.fxh"

// Used: ApplyToe(), RemoveToe(), GetCs(), FindCusp(), ToST().
#include "gamut-clipping.fxh"

float3 OkhslToSRGB(float3 hsl)
{
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;

    if (l == 1.0f)
    {
        return float3( 1.f, 1.f, 1.f );
    }

    else if (l == 0.f)
    {
        return float3( 0.f, 0.f, 0.f );
    }

    float a_ = cos(2.f * _PI * h);
    float b_ = sin(2.f * _PI * h);
    float L = RemoveToe(l);

    float3 cs = GetCs(L, a_, b_);
    float C_0 = cs.x;
    float C_mid = cs.y;
    float C_max = cs.z;

    float mid = 0.8f;
    float mid_inv = 1.25f;

    float C, t, k_0, k_1, k_2;

    if (s < mid)
    {
        t = mid_inv * s;

        k_1 = mid * C_0;
        k_2 = (1.f - k_1 / C_mid);

        C = t * k_1 / (1.f - k_2 * t);
    }
    else
    {
        t = (s - mid)/ (1.f - mid);

        k_0 = C_mid;
        k_1 = (1.f - mid) * C_mid * C_mid * mid_inv * mid_inv / C_0;
        k_2 = (1.f - (k_1) / (C_max - C_mid));

        C = k_0 + t * k_1 / (1.f - k_2 * t);
    }

    float3 rgb = OklabToSRGB(float3( L, C * a_, C * b_ ));
    return rgb;
}

float3 SRGBToOkhsl(float3 rgb)
{
    float3 lab = SRGBToOklab(rgb);

    float C = sqrt(lab.y * lab.y + lab.z * lab.z);
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    float L = lab.x;
    float h = 0.5f + 0.5f * atan2(-lab.z, -lab.y) / _PI;

    float3 cs = GetCs(L, a_, b_);
    float C_0 = cs.x;
    float C_mid = cs.y;
    float C_max = cs.z;

    // Inverse of the interpolation in OkhslToSRGB:

    float mid = 0.8f;
    float mid_inv = 1.25f;

    float s;
    if (C < C_mid)
    {
        float k_1 = mid * C_0;
        float k_2 = (1.f - k_1 / C_mid);

        float t = C / (k_1 + k_2 * C);
        s = t * mid;
    }
    else
    {
        float k_0 = C_mid;
        float k_1 = (1.f - mid) * C_mid * C_mid * mid_inv * mid_inv / C_0;
        float k_2 = (1.f - (k_1) / (C_max - C_mid));

        float t = (C - k_0) / (k_1 + k_2 * (C - k_0));
        s = mid + (1.f - mid) * t;
    }

    float l = ApplyToe(L);
    return float3( h, s, l );
}


float3 OkhsvToSRGB(float3 hsv)
{
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;

    float a_ = cos(2.f * _PI * h);
    float b_ = sin(2.f * _PI * h);
    
    float2 cusp = FindCusp(a_, b_);
    float2 ST_max = ToST(cusp);
    float S_max = ST_max.x;
    float T_max = ST_max.y;
    float S_0 = 0.5f;
    float k = 1.f- S_0 / S_max;

    // first we compute L and V as if the gamut is a perfect triangle:

    // L, C when v==1:
    float L_v = 1.f   - s * S_0 / (S_0 + T_max - T_max * k * s);
    float C_v = s * T_max * S_0 / (S_0 + T_max - T_max * k * s);

    float L = v * L_v;
    float C = v * C_v;

    // then we compensate for both ApplyToe and the curved top part of the triangle:
    float L_vt = RemoveToe(L_v);
    float C_vt = C_v * L_vt / L_v;

    float L_new = RemoveToe(L);
    C = C * L_new / L;
    L = L_new;

    float3 rgb_scale = OklabToSRGB(float3( L_vt, a_ * C_vt, b_ * C_vt ));
    float scale_L = cbrt(1.f / max(max(rgb_scale.r, rgb_scale.g), max(rgb_scale.b, 0.f)));

    L = L * scale_L;
    C = C * scale_L;

    float3 rgb = OklabToSRGB(float3( L, C * a_, C * b_ ));
    return rgb;
}

float3 SRGBToOkhsv(float3 rgb)
{
    float3 lab = SRGBToOklab(rgb);

    float C = sqrt(lab.y * lab.y + lab.z * lab.z);
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    float L = lab.x;
    float h = 0.5f + 0.5f * atan2(-lab.z, -lab.y) / _PI;

    float2 cusp = FindCusp(a_, b_);
    float2 ST_max = ToST(cusp);
    float S_max = ST_max.x;
    float T_max = ST_max.y;
    float S_0 = 0.5f;
    float k = 1.f - S_0 / S_max;

    // first we find L_v, C_v, L_vt and C_vt

    float t = T_max / (C + L * T_max);
    float L_v = t * L;
    float C_v = t * C;

    float L_vt = RemoveToe(L_v);
    float C_vt = C_v * L_vt / L_v;

    // we can then use these to invert the step that compensates for the ApplyToe and the curved top part of the triangle:
    float3 rgb_scale = OklabToSRGB(float3( L_vt, a_ * C_vt, b_ * C_vt ));
    float scale_L = cbrt(1.f / max(max(rgb_scale.r, rgb_scale.g), max(rgb_scale.b, 0.f)));

    L = L / scale_L;
    C = C / scale_L;

    C = C * ApplyToe(L) / L;
    L = ApplyToe(L);

    // we can now compute v and s:

    float v = L / L_v;
    float s = (S_0 + T_max) * C_v / ((T_max * S_0) + T_max * k * C_v);

    return float3 (h, s, v );
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
