//
//  SIMDBridge.h
//  GLGameEngine
//
//  Converters between the GLKit math types used throughout the engine and
//  the simd types the Metal shaders consume. GLKMatrix4 and simd_float4x4
//  share the same column-major 16-float layout; GLKMatrix3 does NOT match
//  simd_float3x3 (9 packed floats vs. three 16-byte columns) and must be
//  expanded column by column.
//

#ifndef GLGameEngine_SIMDBridge_h
#define GLGameEngine_SIMDBridge_h

#import <GLKit/GLKMathTypes.h>
#include <simd/simd.h>
#include <string.h>

static inline simd_float4x4 SIMD_Matrix4(GLKMatrix4 m)
{
    simd_float4x4 result;
    memcpy(&result, m.m, sizeof(result));
    return result;
}

static inline simd_float3x3 SIMD_Matrix3(GLKMatrix3 m)
{
    return simd_matrix(simd_make_float3(m.m00, m.m01, m.m02),
                       simd_make_float3(m.m10, m.m11, m.m12),
                       simd_make_float3(m.m20, m.m21, m.m22));
}

static inline simd_float2 SIMD_Vector2(GLKVector2 v)
{
    return simd_make_float2(v.x, v.y);
}

static inline simd_float3 SIMD_Vector3(GLKVector3 v)
{
    return simd_make_float3(v.x, v.y, v.z);
}

static inline simd_float4 SIMD_Vector4(GLKVector4 v)
{
    return simd_make_float4(v.x, v.y, v.z, v.w);
}

#endif /* GLGameEngine_SIMDBridge_h */
