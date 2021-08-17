#version 300 es
precision highp float;

#define TAU 6.283185307179586476925286766559

struct Droplet
{
  float startTime;
  vec2 pos;
};

//Aspect ratio
const float intendedAspect = 4.0/3.0;
const vec2 aspectScale = vec2(1.0 / intendedAspect, 1.0);

//Framerate
uniform float frameRate;

//Timing
uniform float startPause;
uniform float duration;
uniform float endPause;

//Droplets
const int maxDrops = 8;
uniform int dropCount;
uniform float dropTimings[maxDrops];
uniform vec2 dropPositions[maxDrops];
    
uniform float warpAmount;

float getLoopTime(float iTime) {
    float frameDelta = 1.0 / frameRate;
    float invDur = 1.0 / duration;
    float loopTime = mod(floor(iTime * frameRate) * frameDelta, startPause + duration + endPause);
    return clamp(loopTime * invDur - startPause * invDur, 0.0, 1.0);
}

float getAspect(vec2 iResolution) {
    return iResolution.x / iResolution.y;
}

// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*k*(1.0/4.0);
}