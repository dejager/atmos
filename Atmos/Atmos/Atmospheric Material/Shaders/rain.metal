//
//  rain.metal
//  Atmos
//
//  Check out Martijn Steinrucken's video series which will walk you through the steps of drawing
//  rain! https://www.youtube.com/watch?v=EBrAdahFtuo You will see a simplified application of
//  the effect below.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;

float2 dropSurface(float2 uv, float time) {
    float2 pos = uv;

    uv.y += time * 0.75;

    float2 id = floor(uv * grid);

    uv.y += noise(id.x);

    float2 cell = floor(uv * grid);
    float3 noise = noiseCube(cell.x * 32.5 + cell.y * 2376.1);
    float2 cellPos = fract(uv * grid) - float2(0.5, 0.0);

    float x = noise.x - 0.5;

    float y = pos.y * 20.0;
    x += wobble(y) * (0.5 - abs(x)) * (noise.z - 0.5);
    x *= 0.7;

    float timeInterval = fract(time + noise.z);

    y = (offset(0.75, timeInterval) - 0.5) * 0.9 + 0.5;
    float2 p = float2(x, y);

    float dropSource = length((cellPos - p) * aspectRatio.yx);

    float drop = smoothstep(0.4, 0.0, dropSource);

    float r = sqrt(smoothstep(1.0, y, cellPos.y));
    float cd = abs(cellPos.x - x);
    float path = smoothstep(0.23 * r, 0.15 * r * r, cd);
    float tracer = smoothstep(-0.02, 0.02, cellPos.y - y);
    path *= tracer * r * r;

    y = pos.y;
    float interpolatedPath = smoothstep(0.2 * r, .0, cd);
    float droplets = max(0.0, (sin(y * (1.0 - y) * 120.0) - cellPos.y)) * interpolatedPath * tracer * noise.z;
    y = fract(y * 10.0) + (cellPos.y - 0.5);
    float diff = length(cellPos - float2(x, y));
    droplets = smoothstep(0.3, 0.0, diff);
    float m = drop + droplets * r * tracer;

    return float2(m, path);
}

float condensation(float2 uv, float time) {
    uv *= 40.0;

    float2 id = floor(uv);
    uv = fract(uv) - 0.5;
    float3 noise = noiseCube(id.x * 107.45 + id.y * 3543.654);
    float2 p = (noise.xy - 0.5) * 0.7;
    float d = length(uv - p);

    float timeInterval = fract(time + noise.z);
    float fade = offset(0.025, timeInterval);
    return smoothstep(0.3, 0.0, d) * fract(noise.z * 10.0) * fade;
}

float2 rainDrops(float2 uv, float time, float staticDrops, float dynamicDropsA, float dynamicDropsB) {
    float2 pos = float2(uv.x, uv.y * -1.0);
    float staticDrips = condensation(pos, time) * staticDrops;
    float2 dynamicDripsA = dropSurface(pos, time) * dynamicDropsA;
    float2 dynamicDripsB = dropSurface(pos * 1.85, time) * dynamicDropsB;

    float x = staticDrips + dynamicDripsA.x + dynamicDripsB.x;
    x = smoothstep(0.3, 1.0, x);

    return float2(x, max(dynamicDripsA.y * staticDrops, dynamicDripsB.y * dynamicDropsA));
}

kernel void rain(texture2d<float, access::write> o[[texture(0)]],
                                  texture2d<float, access::sample> i[[texture(1)]],
                                  texture2d<float, access::sample> j[[texture(2)]],
                                  constant float &time [[buffer(0)]],
                                  ushort2 gid [[thread_position_in_grid]]) {

    int width = o.get_width();
    int height = o.get_height();

    float2 resolution = float2(width, height);
    float2 position = float2(gid);

    float2 uv = (position - 0.5 * resolution) / resolution.y;
    uv *= 0.8 + scale * 0.4;

    float2 pos = ((position / resolution) - 0.5) * (0.8 + scale * 0.1) + 0.5;

    float progress = time * 0.2;
    float rainAmount = 1;

    float staticDrops = smoothstep(-0.5, 1.0, rainAmount) * 2.0;
    float dynamicDropsA = smoothstep(0.25, 0.75, rainAmount);
    float dynamicDropsB = smoothstep(0.0, 0.5, rainAmount);

    float2 drops = rainDrops(uv, progress, staticDrops, dynamicDropsA, dynamicDropsB);

    float cx = rainDrops(uv + epsilon2, progress, staticDrops, dynamicDropsA, dynamicDropsB).x;
    float cy = rainDrops(uv + epsilon2.yx, progress, staticDrops, dynamicDropsA, dynamicDropsB).x;
    float2 normals = float2(cx - drops.x, cy - drops.x);

    constexpr sampler bilinear_sampler (coord::normalized,
                                        address::clamp_to_edge,
                                        filter::linear);

    float4 result = i.sample(bilinear_sampler, pos + normals);
    o.write(result, gid);
}
