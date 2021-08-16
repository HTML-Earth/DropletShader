out vec4 fragColor;

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D buffer;
uniform sampler2D backgroundA;
uniform sampler2D backgroundB;

void main()
{
vec2 fragCoord = gl_FragCoord.xy;

    //Fixing aspect ratio
    float actualAspect = getAspect(iResolution);
    vec2 aspectOffsetBase = vec2((actualAspect / intendedAspect) * 0.5, 0);
    vec2 aspectOffset = aspectOffsetBase + vec2(-0.5,0.0);
    
    vec2 uv = fragCoord / iResolution.x;
    uv *= actualAspect;
    
    vec2 uvCorrected = uv * aspectScale - aspectOffset;
        
    //Blur the buffer
    vec2 uvBuffer = uv * vec2(1.0 / actualAspect, 1.0);
    vec3 dropBuffer = texture(buffer, uvBuffer).rgb;
    
    dropBuffer += texture(buffer, uvBuffer + vec2(0.0,1.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(0.0,-1.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(1.0,0.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(-1.0,0.0) * (1.0 / iResolution.x)).rgb;
    
    dropBuffer += texture(buffer, uvBuffer + vec2(0.0,4.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(0.0,-4.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(4.0,0.0) * (1.0 / iResolution.x)).rgb;
    dropBuffer += texture(buffer, uvBuffer + vec2(-4.0,0.0) * (1.0 / iResolution.x)).rgb;
    
    dropBuffer *= 0.1;
    
    float dropWave = dropBuffer.x - dropBuffer.y;
    
    //Warp images
    vec2 warpEffect = vec2(0.0, 0.0) + vec2(dFdx(dropWave), dFdy(dropWave)) * -warpAmount;
    vec2 uvWarped = uvCorrected + warpEffect;
    vec3 tex_a_warped = texture(backgroundA, uvWarped).rgb;
    vec3 tex_b_warped = texture(backgroundB, uvWarped).rgb;
    
    //Output color
    vec3 col = mix(vec3(0.0,0.0,0.0), tex_b_warped, clamp(dropBuffer.z, 0.0, 1.0));
    //vec3 col = vec3(0.5, 0.5, 0.5) + dropWave * 2.0;
    //vec3 col = vec3(warpEffect.x, warpEffect.y, 0.0);
        
    //Pillarboxing
    if (uvCorrected.x < 0.0 || uvCorrected.x > 1.0)
        col = vec3(0.0, 0.0, 0.0);
    
    fragColor.rgb = col;
    fragColor.a = 1.0;
}