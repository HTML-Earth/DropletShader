out vec4 fragColor;

uniform vec2 iResolution;
uniform float iTime;
uniform sampler2D dropBuffer;
uniform sampler2D backgroundA;
uniform sampler2D backgroundB;

float sampleDropBuffer(sampler2D tex, vec2 uv, vec2 pixelStep) {
    float blurAmt = 5.0;
    vec2 kernel = vec2(blurAmt * getAspect(iResolution), blurAmt);
    vec3 rgb = vec3(0);
    vec3 count = vec3(0);

    for (float x = -kernel.x; x <= kernel.x; x++) {
        rgb += texture(tex, uv + vec2(x * pixelStep.x, 0.0)).rgb;
        count += 1.0;
    }

    for (float y = -kernel.y; y <= kernel.y; y++) {
        rgb += texture(tex, uv + vec2(0.0, y * pixelStep.y)).rgb;
        count += 1.0;
    }

    vec3 sum = rgb / count;

    return sum.r - sum.g;
}

float blurDropEffect(sampler2D tex, vec2 uv, vec2 blur) {
    vec3 p0 = texture(tex, uv).rgb;
    vec3 p1 = texture(tex, uv + blur).rgb;
    vec3 p2 = texture(tex, uv - blur).rgb;
    vec3 p3 = texture(tex, uv + vec2(-blur.x, blur.y)).rgb;
    vec3 p4 = texture(tex, uv + vec2(blur.x, -blur.y)).rgb;
    vec3 rgb = p0 + p1 + p2 / 5.0;
    return rgb.r - rgb.g;
}

void main()
{
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 pixelStep = vec2(1.0 / iResolution.x, 1.0 / iResolution.y);
    float invDur = 1.0 / duration;

    //Fixing aspect ratio
    float actualAspect = getAspect(iResolution);
    vec2 aspectOffsetBase = vec2((actualAspect / intendedAspect) * 0.5, 0);
    vec2 aspectOffset = aspectOffsetBase + vec2(-0.5,0.0);
    
    vec2 uv = fragCoord / iResolution.x;
    uv *= actualAspect;
        
    vec2 uvCorrected = uv * aspectScale - aspectOffset;
    
    vec2 derivativeStep = uvCorrected * 0.002;
        
    //Droplet buffer
    vec2 uvBuffer = uv * vec2(1.0 / actualAspect, 1.0);
    vec3 dropBufferTex = texture(dropBuffer, uvBuffer).rgb;

    float current = sampleDropBuffer(dropBuffer, uvBuffer, pixelStep);
    float dx = sampleDropBuffer(dropBuffer, uvBuffer + vec2(derivativeStep.x, 0.0), pixelStep) - current;
    //float dx = dFdx(sampleDropBuffer(dropBuffer, uvBuffer));
    float dy = sampleDropBuffer(dropBuffer, uvBuffer + vec2(0.0, derivativeStep.y), pixelStep) - current;
    //float dy = dFdy(sampleDropBuffer(dropBuffer, uvBuffer));
    
    //Warp images
    vec2 warpEffect = vec2(0.0, 0.0) + vec2(dx, dy) * -warpAmount;
    vec2 uvWarped = uvCorrected + warpEffect;
    vec3 tex_a_warped = texture(backgroundA, uvWarped).rgb;
    vec3 tex_b_warped = texture(backgroundB, uvWarped).rgb;
    
    //Output color
    vec3 col = vec3(0.0,0.0,0.0);
    col = mix(tex_a_warped, tex_b_warped, clamp(dropBufferTex.z, 0.0, 1.0));
    //col = tex_b_warped;
    //if (uvCorrected.x > 0.5)
    //col = vec3(warpEffect.x * 5.0, warpEffect.y * 5.0, 0.0);
    //col = dropBufferTex;
    //col = vec3(uvWarped.x * 1.0 - 0.0, uvWarped.y * 1.0 - 0.0, 0.0);
    
    //Pillarboxing
    if (uvCorrected.x < 0.0 || uvCorrected.x > 1.0)
        col = vec3(0.0, 0.0, 0.0);
    
    fragColor.rgb = col;
    fragColor.a = 1.0;
}