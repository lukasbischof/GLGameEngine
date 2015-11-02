#version 300 core

in vec3 in_position;
in vec2 in_texCoords;
in vec3 in_normals;

out vec3 inout_normal;
out vec2 inout_texCoords;
out vec3 inout_modelPosition;
out vec3 inout_lightDirection[4];
out float inout_visibility;
out vec2 inout_tiledTexCoords;

// VERTEX TRANSFORMATION
uniform mat4 u_transformationMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat3 u_normalMatrix;

// FOG
uniform float u_density;
uniform float u_gradient;

// LIGHT
uniform vec3 u_lightPosition[4];

void main(void) {
    vec4 modelPosition = u_viewMatrix * u_transformationMatrix * vec4(in_position.xyz, 1.0);
    gl_Position = u_projectionMatrix * modelPosition;
    
    inout_modelPosition = modelPosition.xyz;
    inout_texCoords = in_texCoords;
    inout_tiledTexCoords = in_texCoords * 46.0;
    inout_normal = u_normalMatrix * in_normals;
    
    for (int i = 0; i < 4; i++) {
        inout_lightDirection[i] = (u_viewMatrix * vec4(u_lightPosition[i], 1.0)).xyz - inout_modelPosition;
    }
    
    float vertDistance = length(modelPosition.xyz);
    inout_visibility = exp(-pow(vertDistance * u_density, u_gradient));
    inout_visibility = clamp(inout_visibility, 0.0, 1.0);
}