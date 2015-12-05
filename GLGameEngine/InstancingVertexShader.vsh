//
//  InstancingVertexShader.vsh
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#version 300 es
#extension GL_APPLE_clip_distance : require

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_texCoords;
layout(location = 2) in vec3 in_normals;
layout(location = 3) in mat4 in_transformationMatrix;

out vec3 inout_normal;
out vec2 inout_texCoords;
out vec3 inout_modelPosition;
out vec3 inout_lightDirection[4];
out float inout_visibility;
out highp float gl_ClipDistance[1];

// VERTEX TRANSFORMATION
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform mat3 u_normalMatrix;

// FOG
uniform float u_density;
uniform float u_gradient;

// TEXTURE ATLAS
uniform float u_numberOfRows;
uniform vec2 u_offset;

// MISC
uniform vec3 u_lightPosition[4];
uniform vec4 u_clippingPlane;

// Die Property useFakeLighting fehlt, da ich der Meinung bin, dass es einfacher ist, Objekte direkt mit (0,1,0) Normalen zu exportieren...

void main(void) {
    vec4 worldPosition = in_transformationMatrix * vec4(in_position, 1.0);
    gl_ClipDistance[0] = dot(worldPosition, u_clippingPlane);
    
    vec4 modelPosition = u_viewMatrix * worldPosition;
    gl_Position = u_projectionMatrix * modelPosition;
    
    inout_modelPosition = modelPosition.xyz;
    inout_texCoords = (in_texCoords / u_numberOfRows) + u_offset;
    
    mat3 normalMat = transpose(inverse(mat3(u_viewMatrix * in_transformationMatrix)));
    
    inout_normal = normalize(normalMat * in_normals);
    
    for (int i = 0; i < 4; i++) {
        inout_lightDirection[i] = (u_viewMatrix * vec4(u_lightPosition[i], 1.0)).xyz - inout_modelPosition;
    }
    
    float vertDistance = length(modelPosition.xyz);
    inout_visibility = exp(-pow(vertDistance * u_density, u_gradient));
    inout_visibility = clamp(inout_visibility, 0.0, 1.0);
}

