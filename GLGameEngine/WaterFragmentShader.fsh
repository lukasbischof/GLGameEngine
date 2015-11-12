#version 300 es

precision mediump float;

in vec4 inout_clipSpace;
in vec2 inout_textureCoordinates;
in vec3 inout_toCamera;

layout(location = 0) out vec4 out_color;

uniform sampler2D u_reflectionTexture;
uniform sampler2D u_refractionTexture;
uniform sampler2D u_dudvMap;
uniform float u_moveFactor;

const float waveStrength = 0.02;

void main(void) {
    vec2 normalizedDeviceSpace = (inout_clipSpace.xy / inout_clipSpace.w) / 2.0 + 0.5;
    vec2 refractTexCoords = vec2(normalizedDeviceSpace.x, normalizedDeviceSpace.y);
    vec2 reflectTexCoords = vec2(normalizedDeviceSpace.x, 1.0 - normalizedDeviceSpace.y);
    
    vec2 distort1 = (texture(u_dudvMap, vec2(inout_textureCoordinates.x + u_moveFactor, inout_textureCoordinates.y)).rg * 2.0 - 1.0) * waveStrength;
    vec2 distort2 = (texture(u_dudvMap, vec2(-inout_textureCoordinates.x + u_moveFactor, inout_textureCoordinates.y + u_moveFactor)).rg * 2.0 - 1.0) * waveStrength;
    vec2 totalDistort = distort1 + distort2;
    
    refractTexCoords += totalDistort;
    refractTexCoords = clamp(refractTexCoords, 0.001, 0.999);
    
    reflectTexCoords += totalDistort;
    reflectTexCoords = clamp(reflectTexCoords, 0.001, 0.999);
    
    vec4 reflectColor = texture(u_reflectionTexture, reflectTexCoords);
    vec4 refractColor = texture(u_refractionTexture, refractTexCoords);
    
    float refractiveFactor = dot(normalize(inout_toCamera), vec3(0.0, 1.0, 0.0));
    refractiveFactor = pow(refractiveFactor, 0.5);
    
    out_color = mix(reflectColor, refractColor, refractiveFactor) + vec4(0.0, 0.05, 0.1, 1.0);
}