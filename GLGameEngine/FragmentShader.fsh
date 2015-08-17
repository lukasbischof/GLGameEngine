#version 300 core

precision mediump float;

in vec2 inout_texCoords;
in vec3 inout_normal;
in vec3 inout_modelPosition;
out vec4 out_color;

uniform sampler2D u_textureSampler;
uniform vec3 u_lightColor;
uniform vec3 u_lightPosition;

float saturate(float f) {
    return min(max(f, 0.0), 1.0);
}

void main(void) {
    vec3 lightDirection = normalize(u_lightPosition - inout_modelPosition);
    float diffuseWeight = max(dot(inout_normal, lightDirection), 0.2);
    
    vec3 reflectedLight = normalize(reflect(-lightDirection, inout_normal));
    vec3 eyeVec = normalize(-inout_modelPosition);
    float specularWeight = pow(max(dot(eyeVec, reflectedLight), 0.0), 45.0);
    
    out_color = texture(u_textureSampler, inout_texCoords) * vec4(diffuseWeight * u_lightColor + specularWeight * vec3(1.0, 1.0, 1.0), 1.0);
    
//    vec3 lightDirection = normalize(u_lightPosition - inout_modelPosition);
//    vec3 eyeVec = normalize(-inout_modelPosition);
//    vec3 reflection = reflect(-lightDirection, inout_normal);
//    float specularWeight = pow(saturate(dot(reflection, eyeVec)), 50.0);
//    vec3 specularLight = specularWeight * vec3(1.0, 0.0, 0.0);
//    vec3 diffuseLight = saturate(dot(inout_normal, lightDirection)) * vec3(0.0, 1.0, 0.0);
//    
//    out_color += vec4(diffuseLight + specularLight, 1.0);
}
