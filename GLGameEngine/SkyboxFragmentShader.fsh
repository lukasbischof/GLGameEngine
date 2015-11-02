#version 300 core

precision mediump float;

in vec3 inout_texCoords;
out vec4 out_color;

uniform samplerCube u_cubeSampler;

void main(void) {
    out_color = texture(u_cubeSampler, inout_texCoords);
}