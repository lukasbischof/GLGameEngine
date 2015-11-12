#version 300 core

in vec2 in_position;

out vec2 inout_textureCoordinates;

uniform mat4 u_transformationMatrix;

void main(void) {
    gl_Position = u_transformationMatrix * vec4(in_position, 0.0, 1.0);
    inout_textureCoordinates = vec2((in_position.x + 1.0) / 2.0, 1.0 - (in_position.y + 1.0) / 2.0);
}