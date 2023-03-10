/* nullFX: Sigmoids from SweetFX ported for general use. */

// I generally just took the sigmoids from Curves.fx by CeeJay.dk and
// generalized them for more purposes.

// Used: nullFX::Pi, pow2(), __overload_float(MACRO).
#include "intrinsics.fxh"

// Use like Sigmoids::f(x).
namespace Sigmoids
{
    float Sine(in float x)
    {
        x = sin(nullFX::Pi * 0.5 * x);
        return pow2(x);
    }
    __overload_float(Sine)

    float AbsSplit(in float x)
    {
        x -= 0.5;
        return (x / (0.5 + abs(x))) + 0.5;
    }
    __overload_float(AbsSplit)

    float Smoothstep(in float x)
    {
        return x * x * (3.0 - 2.0 * x);
    }
    __overload_float(Smoothstep)

    float Exp(in float x)
    {
        x = exp(6.0 * x);
        return (1.0524 * x - 1.05248) / (x + 20.0855);
    }
    __overload_float(Exp)

    float CatmullRom(in float x)
    {
        return x * (x * (1.5 - x) + 0.5);
    }
    __overload_float(CatmullRom)

    float Smootherstep(in float x)
    {
        return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
    }
    __overload_float(Smootherstep)

    float AbsAdd(in float x)
    {
        x -= 0.5;
        return x / ((abs(x) * 1.25) + 0.375) + 0.5;
    }
    __overload_float(AbsAdd)

    float Parabola(in float x)
    {
        x = x * 2.0 - 1.0;
        return -0.5 * x * (abs(x) - 2.0) + 0.5;
    }
    __overload_float(Parabola)
}

// vim :set ts=4 sw=4 sts=4 et:
// END OF FILE.
