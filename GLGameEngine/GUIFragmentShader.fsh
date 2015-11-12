#version 300 core

precision mediump float;

in vec2 inout_textureCoordinates;

out vec4 out_color;

uniform sampler2D u_guiTexture;

void main(void) {
    out_color = texture(u_guiTexture, inout_textureCoordinates);
}