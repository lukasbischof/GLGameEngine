#version 300 core

in vec3 in_position;
in vec2 in_texCoords;
in vec3 in_normals;

out vec3 inout_normal;
out vec2 inout_texCoords;
out vec3 inout_modelPosition;
out float inout_visibility;

// VERTEX TRANSFORMATION
uniform mat4 u_transformationMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat3 u_normalMatrix;

// FOG
uniform float u_density;
uniform float u_gradient;

// TEXTURE ATLAS
uniform float u_numberOfRows;
uniform vec2 u_offset;

// Die Property useFakeLighting fehlt, da ich der Meinung bin, dass es einfacher ist, Objekte direkt mit (0,1,0) Normalen zu exportieren...

void main(void) {
    vec4 modelPosition = u_viewMatrix * u_transformationMatrix * vec4(in_position.xyz, 1.0);
    gl_Position = u_projectionMatrix * modelPosition;
    
    inout_modelPosition = modelPosition.xyz;
    inout_texCoords = (in_texCoords / u_numberOfRows) + u_offset;
    inout_normal = normalize(u_normalMatrix * in_normals);
    
    float vertDistance = length(modelPosition.xyz);
    inout_visibility = exp(-pow(vertDistance * u_density, u_gradient));
    inout_visibility = clamp(inout_visibility, 0.0, 1.0);
}