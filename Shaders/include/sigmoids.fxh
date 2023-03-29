// SPDX-License-Identifier: Unlicense
#pragma once

/*
This file is a mess.

It's like this because of the hacky removal of the __overload_float macro, which
is surprisingly useful.
*/

#include "global.fxh"

namespace Sigmoids
{
float Sine(in float x)
{
    float y = sin(_PI * 0.5 * x);

    return pow2(y);
}

float2 Sine(in float2 x)
{
    float2 y = sin(_PI * 0.5 * x);

    return pow2(y);
}

float3 Sine(in float3 x)
{
    float3 y = sin(_PI * 0.5 * x);

    return pow2(y);
}

float AbsSplit(in float x)
{
    float y = x - 0.5;
    y = (y / (0.5 + abs(y))) + 0.5;

    return y;
}

float2 AbsSplit(in float2 x)
{
    float2 y = x - 0.5;
    y = (y / (0.5 + abs(y))) + 0.5;

    return y;
}

float3 AbsSplit(in float3 x)
{
    float3 y = x - 0.5;
    y = (y / (0.5 + abs(y))) + 0.5;

    return y;
}

float Smoothstep(in float x)
{
    float y = x * x * (3.0 - 2.0 * x);

    return y;
}

float2 Smoothstep(in float2 x)
{
    float2 y = x * x * (3.0 - 2.0 * x);

    return y;
}

float3 Smoothstep(in float3 x)
{
    float3 y = x * x * (3.0 - 2.0 * x);

    return y;
}

float Exp(in float x)
{
    float y = exp(6.0 * x);
    y = (1.0524 * y - 1.05248) / (y + 20.0855);

    return y;
}

float2 Exp(in float2 x)
{
    float2 y = exp(6.0 * x);
    y = (1.0524 * y - 1.05248) / (y + 20.0855);

    return y;
}

float3 Exp(in float3 x)
{
    float3 y = exp(6.0 * x);
    y = (1.0524 * y - 1.05248) / (y + 20.0855);

    return y;
}

float CatmullRom(in float x)
{
    float y = x * (x * (1.5 - x) + 0.5);

    return y;
}

float2 CatmullRom(in float2 x)
{
    float2 y = x * (x * (1.5 - x) + 0.5);

    return y;
}

float3 CatmullRom(in float3 x)
{
    float3 y = x * (x * (1.5 - x) + 0.5);

    return y;
}

float Smootherstep(in float x)
{
    float y = x * x * x * (x * (x * 6.0 - 15.0) + 10.0);

    return y;
}

float2 Smootherstep(in float2 x)
{
    float2 y = x * x * x * (x * (x * 6.0 - 15.0) + 10.0);

    return y;
}

float3 Smootherstep(in float3 x)
{
    float3 y = x * x * x * (x * (x * 6.0 - 15.0) + 10.0);

    return y;
}

float AbsAdd(in float x)
{
    float y = x - 0.5;
    y = y / ((abs(y) * 1.25) + 0.375) + 0.5;

    return y;
}

float2 AbsAdd(in float2 x)
{
    float2 y = x - 0.5;
    y = y / ((abs(y) * 1.25) + 0.375) + 0.5;

    return y;
}

float3 AbsAdd(in float3 x)
{
    float3 y = x - 0.5;
    y = y / ((abs(y) * 1.25) + 0.375) + 0.5;

    return y;
}

float Parabola(in float x)
{
    float y = x * 2.0 - 1.0;
    y = -0.5 * y * (abs(y) - 2.0) + 0.5;

    return y;
}

float2 Parabola(in float2 x)
{
    float2 y = x * 2.0 - 1.0;
    y = -0.5 * y * (abs(y) - 2.0) + 0.5;

    return y;
}

float3 Parabola(in float3 x)
{
    float3 y = x * 2.0 - 1.0;
    y = -0.5 * y * (abs(y) - 2.0) + 0.5;

    return y;
}
} // namespace Sigmoids

// vim: ts=4:sw=4:sts=4:et:
// END OF FILE.