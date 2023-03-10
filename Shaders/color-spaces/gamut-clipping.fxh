#pragma once

/* nullFX: (SRGB) Gamut re-mapping/clipping. */

// Used: cbrt(), nullFX::Pi
#include "intrinsics.fxh"

// Used: SRGBToOklab(), OklabToSRGB().
#include "oklab.fxh"

// Finds the maximum saturation possible for a given hue that fits in sRGB
// Saturation here is defined as S = C/L
// a and b must be normalized so a^2 + b^2 == 1
float ComputeMaxSaturation(float a, float b)
{
    // Max saturation will be when one of r, g or b goes below zero.

    // Select different coefficients depending on which component goes below zero first
    float k0, k1, k2, k3, k4, wl, wm, ws;

    if (-1.88170328f * a - 0.80936493f * b > 1.f)
    {
        // Red component
        k0 = +1.19086277f; k1 = +1.76576728f; k2 = +0.59662641f; k3 = +0.75515197f; k4 = +0.56771245f;
        wl = +4.0767416621f; wm = -3.3077115913f; ws = +0.2309699292f;
    }
    else if (1.81444104f * a - 1.19445276f * b > 1.f)
    {
        // Green component
        k0 = +0.73956515f; k1 = -0.45954404f; k2 = +0.08285427f; k3 = +0.12541070f; k4 = +0.14503204f;
        wl = -1.2684380046f; wm = +2.6097574011f; ws = -0.3413193965f;
    }
    else
    {
        // Blue component
        k0 = +1.35733652f; k1 = -0.00915799f; k2 = -1.15130210f; k3 = -0.50559606f; k4 = +0.00692167f;
        wl = -0.0041960863f; wm = -0.7034186147f; ws = +1.7076147010f;
    }

    // Approximate max saturation using a polynomial:
    float S = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;

    // Do one step Halley's method to get closer
    // this gives an error less than 10e6, except for some blue hues where the dS/dh is close to infinite
    // this should be sufficient for most applications, otherwise do two/three steps 

    float k_l = +0.3963377774f * a + 0.2158037573f * b;
    float k_m = -0.1055613458f * a - 0.0638541728f * b;
    float k_s = -0.0894841775f * a - 1.2914855480f * b;

    {
        float l_ = 1.f + S * k_l;
        float m_ = 1.f + S * k_m;
        float s_ = 1.f + S * k_s;

        float l = l_ * l_ * l_;
        float m = m_ * m_ * m_;
        float s = s_ * s_ * s_;

        float l_dS = 3.f * k_l * l_ * l_;
        float m_dS = 3.f * k_m * m_ * m_;
        float s_dS = 3.f * k_s * s_ * s_;

        float l_dS2 = 6.f * k_l * k_l * l_;
        float m_dS2 = 6.f * k_m * k_m * m_;
        float s_dS2 = 6.f * k_s * k_s * s_;

        float f = wl * l + wm * m + ws * s;
        float f1 = wl * l_dS + wm * m_dS + ws * s_dS;
        float f2 = wl * l_dS2 + wm * m_dS2 + ws * s_dS2;

        S = S - f * f1 / (f1 * f1 - 0.5f * f * f2);
    }

    return S;
}

// finds L_cusp and C_cusp for a given hue
// a and b must be normalized so a^2 + b^2 == 1
float2 FindCusp(float a, float b)
{
    // First, find the maximum saturation (saturation S = C/L)
    float S_cusp = ComputeMaxSaturation(a, b);

    // Convert to linear sRGB to find the first point where at least one of r,g or b >= 1:
    float3 rgb_at_max = OklabToSRGB(float3( 1, S_cusp * a, S_cusp * b ));
    float L_cusp = cbrt(1.f / max(max(rgb_at_max.r, rgb_at_max.g), rgb_at_max.b));
    float C_cusp = L_cusp * S_cusp;

    return float2( L_cusp , C_cusp );
}

// Finds intersection of the line defined by 
// L = L0 * (1 - t) + t * L1;
// C = t * C1;
// a and b must be normalized so a^2 + b^2 == 1
float FindGamutIntersection(float a, float b, float L1, float C1, float L0, float2 cusp)
{
    // Find the intersection for upper and lower half seprately
    float t;
    if (((L1 - L0) * cusp.y - (cusp.x - L0) * C1) <= 0.f)
    {
        // Lower half

        t = cusp.y * L0 / (C1 * cusp.x + cusp.y * (L0 - L1));
    }
    else
    {
        // Upper half

        // First intersect with triangle
        t = cusp.y * (L0 - 1.f) / (C1 * (cusp.x - 1.f) + cusp.y * (L0 - L1));

        // Then one step Halley's method
        {
            float dL = L1 - L0;
            float dC = C1;

            float k_l = +0.3963377774f * a + 0.2158037573f * b;
            float k_m = -0.1055613458f * a - 0.0638541728f * b;
            float k_s = -0.0894841775f * a - 1.2914855480f * b;

            float l_dt = dL + dC * k_l;
            float m_dt = dL + dC * k_m;
            float s_dt = dL + dC * k_s;


            // If higher accuracy is required, 2 or 3 iterations of the following block can be used:
            {
                float L = L0 * (1.f - t) + t * L1;
                float C = t * C1;

                float l_ = L + C * k_l;
                float m_ = L + C * k_m;
                float s_ = L + C * k_s;

                float l = l_ * l_ * l_;
                float m = m_ * m_ * m_;
                float s = s_ * s_ * s_;

                float ldt = 3.f * l_dt * l_ * l_;
                float mdt = 3.f * m_dt * m_ * m_;
                float sdt = 3.f * s_dt * s_ * s_;

                float ldt2 = 6.f * l_dt * l_dt * l_;
                float mdt2 = 6.f * m_dt * m_dt * m_;
                float sdt2 = 6.f * s_dt * s_dt * s_;

                float r = 4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s - 1.f;
                float r1 = 4.0767416621f * ldt - 3.3077115913f * mdt + 0.2309699292f * sdt;
                float r2 = 4.0767416621f * ldt2 - 3.3077115913f * mdt2 + 0.2309699292f * sdt2;

                float u_r = r1 / (r1 * r1 - 0.5f * r * r2);
                float t_r = -r * u_r;

                float g = -1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s - 1.f;
                float g1 = -1.2684380046f * ldt + 2.6097574011f * mdt - 0.3413193965f * sdt;
                float g2 = -1.2684380046f * ldt2 + 2.6097574011f * mdt2 - 0.3413193965f * sdt2;

                float u_g = g1 / (g1 * g1 - 0.5f * g * g2);
                float t_g = -g * u_g;

                float b = -0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s - 1.f;
                float b1 = -0.0041960863f * ldt - 0.7034186147f * mdt + 1.7076147010f * sdt;
                float b2 = -0.0041960863f * ldt2 - 0.7034186147f * mdt2 + 1.7076147010f * sdt2;

                float u_b = b1 / (b1 * b1 - 0.5f * b * b2);
                float t_b = -b * u_b;

                t_r = u_r >= 0.f ? t_r : 10000.f;
                t_g = u_g >= 0.f ? t_g : 10000.f;
                t_b = u_b >= 0.f ? t_b : 10000.f;

                t += min(t_r, min(t_g, t_b));
            }
        }
    }

    return t;
}

float FindGamutIntersection(float a, float b, float L1, float C1, float L0)
{
    // Find the cusp of the gamut triangle
    float2 cusp = FindCusp(a, b);

    return FindGamutIntersection(a, b, L1, C1, L0, cusp);
}

float3 GamutClip_PreserveChroma(float3 rgb)
{
    if (rgb.r < 1.f && rgb.g < 1.f && rgb.b < 1.f && rgb.r > 0.f && rgb.g > 0.f && rgb.b > 0.f)
        return rgb;

    float3 lab = SRGBToOklab(rgb);

    float L = lab.x;
    float eps = 0.00001f;
    float C = max(eps, sqrt(lab.y * lab.y + lab.z * lab.z));
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    float L0 = clamp(L, 0.f, 1.f);

    float t = FindGamutIntersection(a_, b_, L, C, L0);
    float L_clipped = L0 * (1.f - t) + t * L;
    float C_clipped = t * C;

    return OklabToSRGB(float3( L_clipped, C_clipped * a_, C_clipped * b_ ));
}

float3 GamutClip_ProjectTo05(float3 rgb)
{
    if (rgb.r < 1.f && rgb.g < 1.f && rgb.b < 1.f && rgb.r > 0.f && rgb.g > 0.f && rgb.b > 0.f)
        return rgb;

    float3 lab = SRGBToOklab(rgb);

    float L = lab.x;
    float eps = 0.00001f;
    float C = max(eps, sqrt(lab.y * lab.y + lab.z * lab.z));
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    float L0 = 0.5;

    float t = FindGamutIntersection(a_, b_, L, C, L0);
    float L_clipped = L0 * (1.f - t) + t * L;
    float C_clipped = t * C;

    return OklabToSRGB(float3( L_clipped, C_clipped * a_, C_clipped * b_ ));
}

float3 GamutClip_ProjectToLcusp(float3 rgb)
{
    if (rgb.r < 1.f && rgb.g < 1.f && rgb.b < 1.f && rgb.r > 0.f && rgb.g > 0.f && rgb.b > 0.f)
        return rgb;

    float3 lab = SRGBToOklab(rgb);

    float L = lab.x;
    float eps = 0.00001f;
    float C = max(eps, sqrt(lab.y * lab.y + lab.z * lab.z));
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    // The cusp is computed here and in FindGamutIntersection, an optimized solution would only compute it once.
    float2 cusp = FindCusp(a_, b_);

    float L0 = cusp.x;

    float t = FindGamutIntersection(a_, b_, L, C, L0);

    float L_clipped = L0 * (1.f - t) + t * L;
    float C_clipped = t * C;

    return OklabToSRGB(float3( L_clipped, C_clipped * a_, C_clipped * b_ ));
}

float3 AdaptiveGamutClip_L0_05(float3 rgb, float alpha)
{
	alpha = min(0.0, alpha);

    if (rgb.r < 1.f && rgb.g < 1.f && rgb.b < 1.f && rgb.r > 0.f && rgb.g > 0.f && rgb.b > 0.f)
        return rgb;

    float3 lab = SRGBToOklab(rgb);

    float L = lab.x;
    float eps = 0.00001f;
    float C = max(eps, sqrt(lab.y * lab.y + lab.z * lab.z));
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    float Ld = L - 0.5f;
    float e1 = 0.5f + abs(Ld) + alpha * C;
    float L0 = 0.5f * (1.f + sign(Ld) * (e1 - sqrt(e1 * e1 - 2.f * abs(Ld))));

    float t = FindGamutIntersection(a_, b_, L, C, L0);
    float L_clipped = L0 * (1.f - t) + t * L;
    float C_clipped = t * C;

    return OklabToSRGB(float3( L_clipped, C_clipped * a_, C_clipped * b_ ));
}

float3 AdaptiveGamutClip_L0_Lcusp(float3 rgb, float alpha)
{
	alpha = min(0.0, alpha);

    if (rgb.r < 1.f && rgb.g < 1.f && rgb.b < 1.f && rgb.r > 0.f && rgb.g > 0.f && rgb.b > 0.f)
        return rgb;

    float3 lab = SRGBToOklab(rgb);

    float L = lab.x;
    float eps = 0.00001f;
    float C = max(eps, sqrt(lab.y * lab.y + lab.z * lab.z));
    float a_ = lab.y / C;
    float b_ = lab.z / C;

    // The cusp is computed here and in FindGamutIntersection, an optimized solution would only compute it once.
    float2 cusp = FindCusp(a_, b_);

    float Ld = L - cusp.x;
    float k = 2.f * (Ld > 0.f ? 1.f - cusp.x : cusp.x);

    float e1 = 0.5f * k + abs(Ld) + alpha * C / k;
    float L0 = cusp.x + 0.5f * (sign(Ld) * (e1 - sqrt(e1 * e1 - 2.f * k * abs(Ld))));

    float t = FindGamutIntersection(a_, b_, L, C, L0);
    float L_clipped = L0 * (1.f - t) + t * L;
    float C_clipped = t * C;

    return OklabToSRGB(float3( L_clipped, C_clipped * a_, C_clipped * b_ ));
}

float2 ToST(float2 cusp)
{
    float L = cusp.x;
    float C = cusp.y;
    return float2( C / L, C / (1.f - L) );
}

// Returns a smooth approximation of the location of the cusp
// This polynomial was created by an optimization process
// It has been designed so that S_mid < S_max and T_mid < T_max
float2 GetSTMid(float a_, float b_)
{
    float S = 0.11516993f + 1.f / (
        +7.44778970f + 4.15901240f * b_
        + a_ * (-2.19557347f + 1.75198401f * b_
            + a_ * (-2.13704948f - 10.02301043f * b_
                + a_ * (-4.24894561f + 5.38770819f * b_ + 4.69891013f * a_
                    )))
        );

    float T = 0.11239642f + 1.f / (
        +1.61320320f - 0.68124379f * b_
        + a_ * (+0.40370612f + 0.90148123f * b_
            + a_ * (-0.27087943f + 0.61223990f * b_
                + a_ * (+0.00299215f - 0.45399568f * b_ - 0.14661872f * a_
                    )))
        );

    return float2( S, T );
}

float3 GetCs(float L, float a_, float b_)
{
    float2 cusp = FindCusp(a_, b_);

    float C_max = FindGamutIntersection(a_, b_, L, 1.f, L, cusp);
    float2 ST_max = ToST(cusp);
    
    // Scale factor to compensate for the curved part of gamut shape:
    float k = C_max / min((L * ST_max.x), (1.f - L) * ST_max.y);

    float C_mid;
    {
        float2 ST_mid = GetSTMid(a_, b_);

        // Use a soft minimum function, instead of a sharp triangle shape to get a smooth value for chroma.
        float C_a = L * ST_mid.x;
        float C_b = (1.f - L) * ST_mid.y;
        C_mid = 0.9f * k * sqrt(sqrt(1.f / (1.f / (C_a * C_a * C_a * C_a) + 1.f / (C_b * C_b * C_b * C_b))));
    }

    float C_0;
    {
        // for C_0, the shape is independent of hue, so float2 are constant. Values picked to roughly be the average values of float2.
        float C_a = L * 0.4f;
        float C_b = (1.f - L) * 0.8f;

        // Use a soft minimum function, instead of a sharp triangle shape to get a smooth value for chroma.
        C_0 = sqrt(1.f / (1.f / (C_a * C_a) + 1.f / (C_b * C_b)));
    }

    return float3( C_0, C_mid, C_max );
}

float3 GamutClip(in float3 srgb, in int mode, in float alpha)
{
	// Limit to 0.0, +inf instead of -inf, +inf.
	alpha = min(0.0, alpha);

    switch (mode)
    {
    case 0:
        return GamutClip_PreserveChroma(srgb);
    case 1:
        return GamutClip_ProjectTo05(srgb);
    case 2:
        return GamutClip_ProjectToLcusp(srgb);
    case 3:
        return AdaptiveGamutClip_L0_05(srgb, alpha);
    case 4:
        return AdaptiveGamutClip_L0_Lcusp(srgb, alpha);
    default:
        return srgb;
    }

    // else return srgb.
    return srgb;
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
