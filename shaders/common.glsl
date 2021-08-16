#version 300 es
precision highp float;

#define TAU 6.283185307179586476925286766559

struct Droplet
{
  float startTime;
  vec2 pos;
};

//Framerate
const float frameRate = 15.0;
const float frameDelta = 1.0 / frameRate;

//Aspect ratio
const float intendedAspect = 4.0/3.0;
const vec2 aspectScale = vec2(1.0 / intendedAspect, 1.0);

//Timing
const float startPause = 0.5;
const float duration = 3.5;
const float invDur = 1.0 / duration;
const float endPause = 0.5;

//Droplets
const int dropCount = 4;
const Droplet drops[] = Droplet[](
    Droplet(0.2, vec2(0.5,0.9)),
    Droplet(0.4, vec2(0.2,0.1)),
    Droplet(0.6, vec2(0.5,0.5)),
    Droplet(0.8, vec2(0.8,0.1)));
    
const float ringSinMult = 300.0;
const float ringSinAdd = 0.0;
const float warpAmount = 4.0;

float getLoopTime(float iTime) {
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