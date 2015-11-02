#version 300 core

precision mediump float;

in vec3 inout_texCoords;
out vec4 out_color;

uniform samplerCube u_cubeSampler1;
uniform samplerCube u_cubeSampler2;
uniform float u_blendFactor;
uniform vec3 u_fogColor;

const float c_lowerLimit = 0.0;
const float c_upperLimit = 30.0;

void main(void) {
    vec4 texture1 = texture(u_cubeSampler1, normalize(inout_texCoords));
    vec4 texture2 = texture(u_cubeSampler2, normalize(inout_texCoords));
    vec4 finalColor = mix(texture1, texture2, u_blendFactor);
    
    float factor = (inout_texCoords.y - c_lowerLimit) / (c_upperLimit - c_lowerLimit);
    factor = clamp(factor, 0.0, 1.0);
    
    out_color = mix(vec4(u_fogColor, 1.0), finalColor, factor);
}