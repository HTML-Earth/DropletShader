out vec4 fragColor;

uniform vec2 iResolution;
uniform float iTime;

const float ringSinMult = 300.0;

//const Droplet drops[] = Droplet[](
//    Droplet(0.2, vec2(0.5,0.9)),
//    Droplet(0.4, vec2(0.2,0.1)),
//    Droplet(0.6, vec2(0.5,0.5)),
//    Droplet(0.8, vec2(0.8,0.1)));
//
void main()
{
    vec2 fragCoord = gl_FragCoord.xy;
    float invDur = 1.0 / duration;

    float time = getLoopTime(iTime);

    //Fixing aspect ratio
    float actualAspect = getAspect(iResolution);
    vec2 aspectOffsetBase = vec2((actualAspect - intendedAspect) * 0.5, 0);
    
    vec2 uv = fragCoord / iResolution.x;
    uv *= actualAspect;

    Droplet drops[4];
    drops[0] = Droplet(dropTimings[0], dropPositions[0]);
    drops[1] = Droplet(dropTimings[1], dropPositions[1]);
    drops[2] = Droplet(dropTimings[2], dropPositions[2]);
    drops[3] = Droplet(dropTimings[3], dropPositions[3]);

    //Droplet Masks
    float dropEffectMask = 0.0;
    float dropAlphaMask = 0.0;
    
    for (int i = 0; i < dropCount; i++) {
        float dist = distance(uv, (drops[i].pos / aspectScale) + aspectOffsetBase) * 0.5;
        float dropTime = time - (drops[i].startTime * invDur);
        
        float singleDropMask = clamp((dropTime - dist) * 10.0, 0.0, 1.0);
        
        float ringFadeOut = clamp(1.0 - dropTime * 1.5, 0.0, 1.0);
        ringFadeOut *= ringFadeOut;
        
        float firstRingBase = dropTime-dist;
        float firstRingMult = ringSinMult * (1.0/TAU);
        float firstRing = sin(clamp(firstRingBase,0.0,0.25) * firstRingMult) * ringFadeOut;
        
        float secondRingBase = dropTime-dist - 0.04 * TAU;
        float secondRingMult = ringSinMult * (1.0/TAU);
        float secondRing = sin(clamp(secondRingBase,-0.0,0.25) * secondRingMult) * ringFadeOut;
        
        float thirdRingBase = dropTime-dist - 0.04 * TAU;
        float thirdRingMult = ringSinMult * (1.0/TAU);
        float thirdRing = sin(clamp(secondRingBase,-0.0,0.25) * secondRingMult) * ringFadeOut;
        
        float alphaNegative = sin(clamp(firstRingBase,-0.0,0.25) * firstRingMult) * 0.2 * ringFadeOut;
        dropAlphaMask += clamp((dropTime - dist) * 10.0, 0.0, 1.0) + clamp(alphaNegative,-1.0,0.0) * 5.0;
        
        //dropMask = (dropTime-dist) * 100.0;
        
        dropEffectMask += firstRing + secondRing;//singleDropMask * dropRings;
    }
   
    fragColor = vec4(dropEffectMask, -dropEffectMask, dropAlphaMask, 1.0);
}