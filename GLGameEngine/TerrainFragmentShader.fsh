#version 300 es

precision mediump float;

in vec2 inout_texCoords;
in vec2 inout_tiledTexCoords;
in vec3 inout_normal;
in vec3 inout_modelPosition;
in vec3 inout_lightDirection[4];
in float inout_visibility;
layout(location = 0) out lowp vec4 out_color;

uniform sampler2D u_backgroundSampler;
uniform sampler2D u_rSampler;
uniform sampler2D u_gSampler;
uniform sampler2D u_bSampler;
uniform sampler2D u_blendMapSampler;

uniform vec3 u_lightColor[4];
uniform vec3 u_attenuation[4];
uniform vec3 u_skyColor;

float saturate(float f) {
    return min(max(f, 0.0), 1.0);
}

float getAttenuation(int i, float lightDistance) {
    return (u_attenuation[i].x) + (u_attenuation[i].y * lightDistance) + (u_attenuation[i].z * lightDistance * lightDistance);
}

void main(void) {
    vec4 blendMapColor = texture(u_blendMapSampler, inout_texCoords);
    
    float backTextureAmount = 1.0 - (blendMapColor.r + /*blendMapColor.g +*/ blendMapColor.b);
    vec4 backgroundTextureColor = texture(u_backgroundSampler, inout_tiledTexCoords) * backTextureAmount;
    vec4 rTextureColor = texture(u_rSampler, inout_tiledTexCoords) * blendMapColor.r;
//    vec4 gTextureColor = texture(u_gSampler, inout_tiledTexCoords) * blendMapColor.g;
    vec4 bTextureColor = texture(u_bSampler, inout_tiledTexCoords) * blendMapColor.b;
    
    vec4 finalColor = backgroundTextureColor + rTextureColor /*+ gTextureColor */+ bTextureColor;
    
    vec3 totalDiffuse = vec3(0.0);
    
    for (int i = 0; i < 4; i++) {
        float lightDistance = length(inout_lightDirection[i]);
        vec3 unitLightDirection = normalize(inout_lightDirection[i]);
        float attenuationFactor = getAttenuation(i, lightDistance);
        
        float diffuseWeight = max(dot(normalize(inout_normal), unitLightDirection), 0.0);
        
        totalDiffuse += diffuseWeight * u_lightColor[i] / attenuationFactor;
    }
    
    // color + lighting
    out_color = finalColor * vec4(max(totalDiffuse, 0.2), 1.0);
    
    // fog
    //out_color = vec4(inout_normal, 1.0);
    out_color = mix(vec4(u_skyColor, 1.0), out_color, inout_visibility);
}
