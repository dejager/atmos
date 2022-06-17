//
//  Common.h
//  Atmos
//
//

#ifndef Common_h
#define Common_h

#include <metal_stdlib>

using namespace metal;

#define aspectRatio float2(7.0, 1.0)
#define grid aspectRatio * 2.0
#define scale 0.5
#define epsilon2 float2(0.001, 0.0)

// noise generators by Dave Hoskins

float noise(float pos) {
    return fract(sin(pos * 12345.564) * 7658.76);
}

float3 noiseCube(float pos) {
    float3 pos3 = fract(float3(pos) * float3(0.1031, 0.11369, 0.13787));
    pos3 += dot(pos3, pos3.yzx + 19.19);
    return fract(float3((pos3.x + pos3.y) * pos3.z,
                        (pos3.x + pos3.z) * pos3.y,
                        (pos3.y + pos3.z) * pos3.x));
}

float offset(float bounds, float time) {
    return smoothstep(0.0, bounds, time) * smoothstep(1.0, bounds, time);
}

float wobble(float pos) {
    return sin(pos + sin(pos));
}

#endif /* Common_h */
