#version 300 es

layout(location = 0) in vec3 in_position;

out vec4 inout_clipSpace;
out vec2 inout_textureCoordinates;
out vec3 inout_toCamera;
out vec3 inout_fromLight;

uniform mat4 u_transformationMatrix;
uniform mat4 u_projectionMatrix;
uniform mat4 u_viewMatrix;
uniform vec3 u_cameraPosition;
uniform vec3 u_lightPosition;

const float tiling = 4.0;

void main(void) {
    vec4 worldPosition = u_transformationMatrix * vec4(in_position, 1.0);
    inout_clipSpace = u_projectionMatrix * u_viewMatrix * worldPosition;
    inout_textureCoordinates = vec2(in_position.x / 2.0 + 0.5, in_position.z / 2.0 + 0.5) * tiling;
    inout_toCamera = u_cameraPosition - worldPosition.xyz;
    inout_fromLight = worldPosition.xyz - u_lightPosition;
    gl_Position = inout_clipSpace;
}
