#version 100

precision mediump float;

attribute vec4 a_position;
attribute vec4 a_color;
attribute vec2 a_texcoord;

uniform vec2 u_resolution;

uniform float u_rotate_xy;
uniform float u_rotate_xz;
uniform float u_rotate_xw;
uniform float u_rotate_yz;
uniform float u_rotate_yw;
uniform float u_rotate_zw;

varying vec4 v_color;
varying vec2 v_texcoord;

mat4 gen_4d_projection_p(float LW, float W) {
    return mat4(
        1.0 / (LW + W), 0.0, 0.0, 0.0,
        0.0, 1.0 / (LW + W), 0.0, 0.0,
        0.0, 0.0, 1.0 / (LW + W), 0.0,
        0.0, 0.0, 0.0, 0.0
    );
}

mat3 gen_3d_projection_p(float LZ, float Z) {
    return mat3(
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 0.0, 0.0
    );
}

void main() {
    const float LW = 1.5;

    mat4 rotate_xy = mat4(
        cos(u_rotate_xy), -sin(u_rotate_xy), 0, 0,
        sin(u_rotate_xy), cos(u_rotate_xy), 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    ), rotate_xz = mat4(
        cos(u_rotate_xz), 0, -sin(u_rotate_xz), 0,
        0, 1, 0, 0,
        sin(u_rotate_xz), 0, cos(u_rotate_xz), 0,
        0, 0, 0, 1
    ), rotate_xw = mat4(
        cos(u_rotate_xw), 0, 0, -sin(u_rotate_xw),
        0, 1, 0, 0,
        0, 0, 1, 0,
        sin(u_rotate_xw), 0, 0, cos(u_rotate_xw)
    ), rotate_yz = mat4(
        1, 0, 0, 0,
        0, cos(u_rotate_yz), -sin(u_rotate_yz), 0,
        0, sin(u_rotate_yz), cos(u_rotate_yz), 0,
        0, 0, 0, 1
    ), rotate_yw = mat4(
        1, 0, 0, 0,
        0, cos(u_rotate_yw), 0, -sin(u_rotate_yw),
        0, 0, 1, 0,
        0, sin(u_rotate_yw), 0, cos(u_rotate_yw)
    ), rotate_zw = mat4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, cos(u_rotate_zw), -sin(u_rotate_zw),
        0, 0, sin(u_rotate_zw), cos(u_rotate_zw)
    );

    vec4 uv = rotate_xy * rotate_yz * rotate_xz
        * rotate_xw * rotate_yw * rotate_zw
        * a_position * 0.5;
    vec3 projected_4d = (gen_4d_projection_p(LW, uv.w) * uv).xyz;
    vec2 projected_3d = (gen_3d_projection_p(LW,  projected_4d.z) * projected_4d).xy;

    vec4 res = vec4(
        projected_3d.x * u_resolution.y / u_resolution.x,
        projected_3d.y,
        0.0,
        1.0
    );

    v_color = a_color;
    v_texcoord = a_texcoord;

    gl_Position = res;
}
