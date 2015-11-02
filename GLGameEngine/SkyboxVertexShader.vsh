#version 300 core

in vec3 in_position;
out vec3 inout_texCoords;

uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;

void main(void) {
    gl_Position = u_projectionMatrix * u_viewMatrix * vec4(in_position, 1.0);
    inout_texCoords = normalize(in_position);
}