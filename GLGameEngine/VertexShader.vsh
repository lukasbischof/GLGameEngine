#version 300 core

in vec3 in_position;
in vec2 in_texCoords;

out vec2 inout_texCoords;

uniform mat4 u_transformationMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform vec3 u_lightPosition;

void main(void) {
    gl_Position = u_projectionMatrix * u_viewMatrix * u_transformationMatrix * vec4(in_position.xyz, 1.0);
    inout_texCoords = in_texCoords;
}