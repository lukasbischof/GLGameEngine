#version 300 core

precision mediump float;

in vec2 inout_texCoords;
in vec2 inout_tiledTexCoords;
in vec3 inout_normal;
in vec3 inout_modelPosition;
in float inout_visibility;
out vec4 out_color;

uniform sampler2D u_backgroundSampler;
uniform sampler2D u_rSampler;
uniform sampler2D u_gSampler;
uniform sampler2D u_bSampler;
uniform sampler2D u_blendMapSampler;

uniform vec3 u_lightColor;
uniform vec3 u_lightPosition;
uniform vec3 u_skyColor;

float saturate(float f) {
    return min(max(f, 0.0), 1.0);
}

void main(void) {
    vec4 blendMapColor = texture(u_blendMapSampler, inout_texCoords);
    
    float backTextureAmount = 1.0 - (blendMapColor.r + blendMapColor.g + blendMapColor.b);
    vec4 backgroundTextureColor = texture(u_backgroundSampler, inout_tiledTexCoords) * backTextureAmount;
    vec4 rTextureColor = texture(u_rSampler, inout_tiledTexCoords) * blendMapColor.r;
    vec4 gTextureColor = texture(u_gSampler, inout_tiledTexCoords) * blendMapColor.g;
    vec4 bTextureColor = texture(u_bSampler, inout_tiledTexCoords) * blendMapColor.b;
    
    vec4 finalColor = backgroundTextureColor + rTextureColor + gTextureColor + bTextureColor;
    
    vec3 lightDirection = normalize(u_lightPosition - inout_modelPosition);
    float diffuseWeight = max(dot(inout_normal, lightDirection), 0.2);
    
    // color + lighting
    out_color = finalColor * vec4(diffuseWeight * u_lightColor, 1.0);
    
    // fog
    out_color = mix(vec4(u_skyColor, 1.0), out_color, inout_visibility);
}
