#version 300 core

in vec3 in_position;
in vec2 in_texCoords;
in vec3 in_normals;

out vec3 inout_normal;
out vec2 inout_texCoords;
out vec3 inout_modelPosition;

uniform mat4 u_transformationMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat3 u_normalMatrix;

void main(void) {
    vec4 modelPosition = u_viewMatrix * u_transformationMatrix * vec4(in_position.xyz, 1.0);
    gl_Position = u_projectionMatrix * modelPosition;
    
    inout_modelPosition = modelPosition.xyz;
    inout_texCoords = in_texCoords;
    inout_normal = normalize(u_normalMatrix * in_normals);
}