#version 300 core

precision mediump float;

in vec2 inout_texCoords;
in vec3 inout_normal;
in vec3 inout_lightDirection[4];
in vec3 inout_modelPosition;
in float inout_visibility;
out vec4 out_color;

uniform sampler2D u_textureSampler;
uniform vec3 u_lightColor[4];
uniform vec3 u_attenuation[4];
uniform vec3 u_skyColor;
uniform float u_damper;
uniform float u_reflectivity;

float saturate(float f) {
    return min(max(f, 0.0), 1.0);
}

float getAttenuation(int i, float lightDistance) {
    return (u_attenuation[i].x) + (u_attenuation[i].y * lightDistance) + (u_attenuation[i].z * lightDistance * lightDistance);
}

void main(void) {
    vec4 textureColor = texture(u_textureSampler, inout_texCoords);
    if (textureColor.a < 0.5)
        discard;
    
    vec3 eyeVec = normalize(-inout_modelPosition);
    vec3 totalDiffuse = vec3(0.0);
    vec3 totalSpecular = vec3(0.0);
    
    for (int i = 0; i < 4; i++) {
        float lightDistance = length(inout_lightDirection[i]);
        vec3 unitLightDirection = normalize(inout_lightDirection[i]);
        float attenuationFactor = getAttenuation(i, lightDistance);
        float diffuseWeight = max(dot(inout_normal, unitLightDirection), 0.0);
        
        totalDiffuse += diffuseWeight * u_lightColor[i] / attenuationFactor;
        
        if (u_reflectivity <= 0.0)
            continue;
        
        vec3 reflectedLight = normalize(reflect(-unitLightDirection, inout_normal));
        float specularWeight = pow(max(dot(eyeVec, reflectedLight), 0.0), u_damper) * u_reflectivity;
        
        totalSpecular += (specularWeight * vec3(1.0)) / attenuationFactor;
    }
    
    // color + lighting
    out_color = textureColor * vec4(max(totalDiffuse, 0.2) + totalSpecular, 1.0);
    
    // fog
    out_color = mix(vec4(u_skyColor, 1.0), out_color, inout_visibility);
}
