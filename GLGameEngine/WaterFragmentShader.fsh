#version 300 es

precision highp float;

in vec4 inout_clipSpace;
in vec2 inout_textureCoordinates;
in vec3 inout_toCamera;
in vec3 inout_fromLight;

layout(location = 0) out lowp vec4 out_color;

uniform sampler2D u_reflectionTexture;
uniform sampler2D u_refractionTexture;
uniform sampler2D u_dudvMap;
uniform sampler2D u_normalMap;
uniform sampler2D u_depthMap;
uniform float u_moveFactor;
uniform vec3 u_lightColor;

const float waveStrength = 0.025;
const float shineDamper = 50.0;
const float reflectivity = 0.6;

const float nearz = 1.5;
const float farz = 300.0;

float linearizeDepth(float depth) {
    return 2.0 * nearz * farz / (farz + nearz - (2.0 * depth - 1.0) * (farz - nearz));
}

float getWaterDepth(vec2 uv) {
    float depth = texture(u_depthMap, uv).r;
    float floorDistance = linearizeDepth(depth);
    
    depth = gl_FragCoord.z;
    float waterDistance = linearizeDepth(depth);
    
    return floorDistance - waterDistance;
}

void main(void) {
    vec2 normalizedDeviceSpace = (inout_clipSpace.xy / inout_clipSpace.w) / 2.0 + 0.5;
    vec2 refractTexCoords = vec2(normalizedDeviceSpace.x, normalizedDeviceSpace.y);
    vec2 reflectTexCoords = vec2(normalizedDeviceSpace.x, 1.0 - normalizedDeviceSpace.y);
    
    // depth
    float waterDepth = getWaterDepth(refractTexCoords);
    
    // distort
    highp vec2 distortedTexCoords = (texture(u_dudvMap, vec2(inout_textureCoordinates.x + u_moveFactor, inout_textureCoordinates.y)).rg * 0.3);
    distortedTexCoords = inout_textureCoordinates + vec2(distortedTexCoords.x, distortedTexCoords.y + u_moveFactor);
    vec2 totalDistort = (texture(u_dudvMap, distortedTexCoords).rg * 2.0 - 1.0) * waveStrength * clamp(waterDepth / 10.0, 0.0, 1.0);
    
    refractTexCoords += totalDistort;
    refractTexCoords = clamp(refractTexCoords, 0.001, 0.999);
    
    reflectTexCoords += totalDistort;
    reflectTexCoords = clamp(reflectTexCoords, 0.001, 0.999);
    
    // reflection + refraction
    vec4 reflectColor = texture(u_reflectionTexture, reflectTexCoords);
    vec4 refractColor = texture(u_refractionTexture, refractTexCoords);
    
    // normals
    vec4 normalMapColor = texture(u_normalMap, distortedTexCoords);
    vec3 normal = normalize(vec3(normalMapColor.r * 2.0 - 1.0, normalMapColor.b * 6.0, normalMapColor.g * 2.0 - 1.0));
    
    // fresnel
    vec3 viewVec = normalize(inout_toCamera);
    float refractiveFactor = pow(dot(viewVec, normal), 0.4);
    refractiveFactor = clamp(refractiveFactor, 0.0, 1.0);
    
    // light
    vec3 reflectedLight = reflect(normalize(inout_fromLight), normal);
    float specular = pow(max(dot(reflectedLight, viewVec), 0.0), shineDamper);
    vec4 specularHighlights = vec4(u_lightColor * specular * reflectivity * clamp(waterDepth / 5.0, 0.0, 1.0), 0.0);
    
    // final
    out_color = mix(reflectColor, refractColor, refractiveFactor) + vec4(0.0, 0.05, 0.1, 1.0) + specularHighlights;
    out_color.a = clamp(waterDepth / 5.0, 0.0, 1.0);
}

/** @works
 float ndcDepth = (2.0 * gl_FragCoord.z - nearz - farz) / (farz - nearz);
 float clipDepth = ndcDepth / gl_FragCoord.w;
 out_color = vec4((clipDepth * 0.5) + 0.5);
 return;*/
