#pragma mapbox: define highp vec4 color
#pragma mapbox: define mediump float radius
#pragma mapbox: define lowp float blur
#pragma mapbox: define lowp float opacity
#pragma mapbox: define highp vec4 stroke_color
#pragma mapbox: define mediump float stroke_width
#pragma mapbox: define lowp float stroke_opacity

varying vec3 v_data;

void main() {
    #pragma mapbox: initialize highp vec4 color
    #pragma mapbox: initialize mediump float radius
    #pragma mapbox: initialize lowp float blur
    #pragma mapbox: initialize lowp float opacity
    #pragma mapbox: initialize highp vec4 stroke_color
    #pragma mapbox: initialize mediump float stroke_width
    #pragma mapbox: initialize lowp float stroke_opacity

    vec2 extrude = v_data.xy;
    float extrude_length = length(extrude);

    lowp float antialiasblur = v_data.z;
    float antialiased_blur = -max(blur, antialiasblur);

    float opacity_t = smoothstep(0.0, antialiased_blur, extrude_length - 1.0);

    float color_t = stroke_width < 0.01 ? 0.0 : smoothstep(
        antialiased_blur,
        0.0,
        extrude_length - radius / (radius + stroke_width)
    );

    // ----- CUSTOM STARTS
    const float kInvPi = 1.0 / 3.14159265;
    // Play with the following values to see their effect.
    const float kArc = 0.5;
    const float kOffset = 1.0 - 0.6;

    float angle = atan( v_data.x, v_data.y ) * kInvPi * 0.5;
    angle = fract( angle - kOffset );

    float segment = step( angle, kArc );
    segment *= step( 0.0, angle );

    // opacity_t -= smoothstep( antialiased_blur-10, antialiased_blur+10, extrude_length - 1.0);
    opacity_t *= mix( segment, 1.0, step( 1.0, kArc ) );
    // ----- CUSTOM ENDS

    gl_FragColor = opacity_t * mix(color * opacity, stroke_color * stroke_opacity, color_t);

#ifdef OVERDRAW_INSPECTOR
    gl_FragColor = vec4(1.0);
#endif
}
