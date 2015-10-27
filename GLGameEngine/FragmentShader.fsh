#version 300 core

precision mediump float;

in vec2 inout_texCoords;
in vec3 inout_normal;
in vec3 inout_modelPosition;
in float inout_visibility;
out vec4 out_color;

uniform sampler2D u_textureSampler;
uniform vec3 u_lightColor;
uniform vec3 u_lightPosition;
uniform vec3 u_skyColor;

float saturate(float f) {
    return min(max(f, 0.0), 1.0);
}

void main(void) {
    vec4 textureColor = texture(u_textureSampler, inout_texCoords);
    if (textureColor.a < 0.5)
        discard;
    
    vec3 lightDirection = normalize(u_lightPosition - inout_modelPosition);
    float diffuseWeight = max(dot(inout_normal, lightDirection), 0.2);
    
    vec3 reflectedLight = normalize(reflect(-lightDirection, inout_normal));
    vec3 eyeVec = normalize(-inout_modelPosition);
    float specularWeight = pow(max(dot(eyeVec, reflectedLight), 0.0), 45.0);
    
    // color + lighting
    out_color = textureColor * vec4(diffuseWeight * u_lightColor + specularWeight * vec3(1.0, 1.0, 1.0), 1.0);
    
    // fog
    out_color = mix(vec4(u_skyColor, 1.0), out_color, inout_visibility);
}
