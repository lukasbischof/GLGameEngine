#version 300 core

precision mediump float;

in vec2 inout_texCoords;
out vec4 out_color;

uniform sampler2D u_textureSampler;
uniform vec3 u_lightColor;

void main(void) {
    out_color = texture(u_textureSampler, inout_texCoords);
}
