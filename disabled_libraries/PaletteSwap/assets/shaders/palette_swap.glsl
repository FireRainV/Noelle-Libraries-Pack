extern number epsilon;

bool approxEqual(vec3 a, vec3 b, float e) {
    return abs(a.r - b.r) <= e &&
           abs(a.g - b.g) <= e &&
           abs(a.b - b.b) <= e;
}

bool inRange(vec3 c, vec3 a, vec3 b) {
    vec3 mn = min(a, b);
    vec3 mx = max(a, b);

    return c.r >= mn.r && c.r <= mx.r &&
           c.g >= mn.g && c.g <= mx.g &&
           c.b >= mn.b && c.b <= mx.b;
}

vec3 remapRange(vec3 c, vec3 s0, vec3 s1, vec3 d0, vec3 d1) {
    vec3 t;
    vec3 ds = s1 - s0;

    t.r = abs(ds.r) < 0.00001 ? 0.0 : (c.r - s0.r) / ds.r;
    t.g = abs(ds.g) < 0.00001 ? 0.0 : (c.g - s0.g) / ds.g;
    t.b = abs(ds.b) < 0.00001 ? 0.0 : (c.b - s0.b) / ds.b;

    t = clamp(t, 0.0, 1.0);

    return vec3(
        mix(d0.r, d1.r, t.r),
        mix(d0.g, d1.g, t.g),
        mix(d0.b, d1.b, t.b)
    );
}

bool applySwap(
    vec3 inputColor,
    vec3 sMin, vec3 sMax,
    vec3 dMin, vec3 dMax,
    out vec3 outputColor
) {
    bool singleSource = approxEqual(sMin, sMax, epsilon);
    bool singleDest   = approxEqual(dMin, dMax, epsilon);

    if (singleSource) {
        if (approxEqual(inputColor, sMin, epsilon)) {
            if (singleDest) {
                outputColor = dMin;
            } else {
                outputColor = mix(dMin, dMax, 0.5);
            }
            return true;
        }
    } else {
        if (inRange(inputColor, sMin, sMax)) {
            if (singleDest) {
                outputColor = dMin;
            } else {
                outputColor = remapRange(inputColor, sMin, sMax, dMin, dMax);
            }
            return true;
        }
    }

    return false;
}

// Swap 1
extern vec3 srcMin1; extern vec3 srcMax1; extern vec3 dstMin1; extern vec3 dstMax1; extern number enabled1;
// Swap 2
extern vec3 srcMin2; extern vec3 srcMax2; extern vec3 dstMin2; extern vec3 dstMax2; extern number enabled2;
// Swap 3
extern vec3 srcMin3; extern vec3 srcMax3; extern vec3 dstMin3; extern vec3 dstMax3; extern number enabled3;
// Swap 4
extern vec3 srcMin4; extern vec3 srcMax4; extern vec3 dstMin4; extern vec3 dstMax4; extern number enabled4;
// Swap 5
extern vec3 srcMin5; extern vec3 srcMax5; extern vec3 dstMin5; extern vec3 dstMax5; extern number enabled5;
// Swap 6
extern vec3 srcMin6; extern vec3 srcMax6; extern vec3 dstMin6; extern vec3 dstMax6; extern number enabled6;
// Swap 7
extern vec3 srcMin7; extern vec3 srcMax7; extern vec3 dstMin7; extern vec3 dstMax7; extern number enabled7;
// Swap 8
extern vec3 srcMin8; extern vec3 srcMax8; extern vec3 dstMin8; extern vec3 dstMax8; extern number enabled8;
// Swap 9
extern vec3 srcMin9; extern vec3 srcMax9; extern vec3 dstMin9; extern vec3 dstMax9; extern number enabled9;
// Swap 10
extern vec3 srcMin10; extern vec3 srcMax10; extern vec3 dstMin10; extern vec3 dstMax10; extern number enabled10;
// Swap 11
extern vec3 srcMin11; extern vec3 srcMax11; extern vec3 dstMin11; extern vec3 dstMax11; extern number enabled11;
// Swap 12
extern vec3 srcMin12; extern vec3 srcMax12; extern vec3 dstMin12; extern vec3 dstMax12; extern number enabled12;
// Swap 13
extern vec3 srcMin13; extern vec3 srcMax13; extern vec3 dstMin13; extern vec3 dstMax13; extern number enabled13;
// Swap 14
extern vec3 srcMin14; extern vec3 srcMax14; extern vec3 dstMin14; extern vec3 dstMax14; extern number enabled14;
// Swap 15
extern vec3 srcMin15; extern vec3 srcMax15; extern vec3 dstMin15; extern vec3 dstMax15; extern number enabled15;
// Swap 16
extern vec3 srcMin16; extern vec3 srcMax16; extern vec3 dstMin16; extern vec3 dstMax16; extern number enabled16;
// Swap 17
extern vec3 srcMin17; extern vec3 srcMax17; extern vec3 dstMin17; extern vec3 dstMax17; extern number enabled17;
// Swap 18
extern vec3 srcMin18; extern vec3 srcMax18; extern vec3 dstMin18; extern vec3 dstMax18; extern number enabled18;
// Swap 19
extern vec3 srcMin19; extern vec3 srcMax19; extern vec3 dstMin19; extern vec3 dstMax19; extern number enabled19;
// Swap 20
extern vec3 srcMin20; extern vec3 srcMax20; extern vec3 dstMin20; extern vec3 dstMax20; extern number enabled20;
// Swap 21
extern vec3 srcMin21; extern vec3 srcMax21; extern vec3 dstMin21; extern vec3 dstMax21; extern number enabled21;
// Swap 22
extern vec3 srcMin22; extern vec3 srcMax22; extern vec3 dstMin22; extern vec3 dstMax22; extern number enabled22;
// Swap 23
extern vec3 srcMin23; extern vec3 srcMax23; extern vec3 dstMin23; extern vec3 dstMax23; extern number enabled23;
// Swap 24
extern vec3 srcMin24; extern vec3 srcMax24; extern vec3 dstMin24; extern vec3 dstMax24; extern number enabled24;
// Swap 25
extern vec3 srcMin25; extern vec3 srcMax25; extern vec3 dstMin25; extern vec3 dstMax25; extern number enabled25;
// Swap 26
extern vec3 srcMin26; extern vec3 srcMax26; extern vec3 dstMin26; extern vec3 dstMax26; extern number enabled26;
// Swap 27
extern vec3 srcMin27; extern vec3 srcMax27; extern vec3 dstMin27; extern vec3 dstMax27; extern number enabled27;
// Swap 28
extern vec3 srcMin28; extern vec3 srcMax28; extern vec3 dstMin28; extern vec3 dstMax28; extern number enabled28;
// Swap 29
extern vec3 srcMin29; extern vec3 srcMax29; extern vec3 dstMin29; extern vec3 dstMax29; extern number enabled29;
// Swap 30
extern vec3 srcMin30; extern vec3 srcMax30; extern vec3 dstMin30; extern vec3 dstMax30; extern number enabled30;
// Swap 31
extern vec3 srcMin31; extern vec3 srcMax31; extern vec3 dstMin31; extern vec3 dstMax31; extern number enabled31;
// Swap 32
extern vec3 srcMin32; extern vec3 srcMax32; extern vec3 dstMin32; extern vec3 dstMax32; extern number enabled32;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 px = Texel(texture, texture_coords) * color;
    vec3 outColor;

    if (enabled1  > 0.5 && applySwap(px.rgb, srcMin1,  srcMax1,  dstMin1,  dstMax1,  outColor)) return vec4(outColor, px.a);
    if (enabled2  > 0.5 && applySwap(px.rgb, srcMin2,  srcMax2,  dstMin2,  dstMax2,  outColor)) return vec4(outColor, px.a);
    if (enabled3  > 0.5 && applySwap(px.rgb, srcMin3,  srcMax3,  dstMin3,  dstMax3,  outColor)) return vec4(outColor, px.a);
    if (enabled4  > 0.5 && applySwap(px.rgb, srcMin4,  srcMax4,  dstMin4,  dstMax4,  outColor)) return vec4(outColor, px.a);
    if (enabled5  > 0.5 && applySwap(px.rgb, srcMin5,  srcMax5,  dstMin5,  dstMax5,  outColor)) return vec4(outColor, px.a);
    if (enabled6  > 0.5 && applySwap(px.rgb, srcMin6,  srcMax6,  dstMin6,  dstMax6,  outColor)) return vec4(outColor, px.a);
    if (enabled7  > 0.5 && applySwap(px.rgb, srcMin7,  srcMax7,  dstMin7,  dstMax7,  outColor)) return vec4(outColor, px.a);
    if (enabled8  > 0.5 && applySwap(px.rgb, srcMin8,  srcMax8,  dstMin8,  dstMax8,  outColor)) return vec4(outColor, px.a);
    if (enabled9  > 0.5 && applySwap(px.rgb, srcMin9,  srcMax9,  dstMin9,  dstMax9,  outColor)) return vec4(outColor, px.a);
    if (enabled10 > 0.5 && applySwap(px.rgb, srcMin10, srcMax10, dstMin10, dstMax10, outColor)) return vec4(outColor, px.a);
    if (enabled11 > 0.5 && applySwap(px.rgb, srcMin11, srcMax11, dstMin11, dstMax11, outColor)) return vec4(outColor, px.a);
    if (enabled12 > 0.5 && applySwap(px.rgb, srcMin12, srcMax12, dstMin12, dstMax12, outColor)) return vec4(outColor, px.a);
    if (enabled13 > 0.5 && applySwap(px.rgb, srcMin13, srcMax13, dstMin13, dstMax13, outColor)) return vec4(outColor, px.a);
    if (enabled14 > 0.5 && applySwap(px.rgb, srcMin14, srcMax14, dstMin14, dstMax14, outColor)) return vec4(outColor, px.a);
    if (enabled15 > 0.5 && applySwap(px.rgb, srcMin15, srcMax15, dstMin15, dstMax15, outColor)) return vec4(outColor, px.a);
    if (enabled16 > 0.5 && applySwap(px.rgb, srcMin16, srcMax16, dstMin16, dstMax16, outColor)) return vec4(outColor, px.a);
    if (enabled17 > 0.5 && applySwap(px.rgb, srcMin17, srcMax17, dstMin17, dstMax17, outColor)) return vec4(outColor, px.a);
    if (enabled18 > 0.5 && applySwap(px.rgb, srcMin18, srcMax18, dstMin18, dstMax18, outColor)) return vec4(outColor, px.a);
    if (enabled19 > 0.5 && applySwap(px.rgb, srcMin19, srcMax19, dstMin19, dstMax19, outColor)) return vec4(outColor, px.a);
    if (enabled20 > 0.5 && applySwap(px.rgb, srcMin20, srcMax20, dstMin20, dstMax20, outColor)) return vec4(outColor, px.a);
    if (enabled21 > 0.5 && applySwap(px.rgb, srcMin21, srcMax21, dstMin21, dstMax21, outColor)) return vec4(outColor, px.a);
    if (enabled22 > 0.5 && applySwap(px.rgb, srcMin22, srcMax22, dstMin22, dstMax22, outColor)) return vec4(outColor, px.a);
    if (enabled23 > 0.5 && applySwap(px.rgb, srcMin23, srcMax23, dstMin23, dstMax23, outColor)) return vec4(outColor, px.a);
    if (enabled24 > 0.5 && applySwap(px.rgb, srcMin24, srcMax24, dstMin24, dstMax24, outColor)) return vec4(outColor, px.a);
    if (enabled25 > 0.5 && applySwap(px.rgb, srcMin25, srcMax25, dstMin25, dstMax25, outColor)) return vec4(outColor, px.a);
    if (enabled26 > 0.5 && applySwap(px.rgb, srcMin26, srcMax26, dstMin26, dstMax26, outColor)) return vec4(outColor, px.a);
    if (enabled27 > 0.5 && applySwap(px.rgb, srcMin27, srcMax27, dstMin27, dstMax27, outColor)) return vec4(outColor, px.a);
    if (enabled28 > 0.5 && applySwap(px.rgb, srcMin28, srcMax28, dstMin28, dstMax28, outColor)) return vec4(outColor, px.a);
    if (enabled29 > 0.5 && applySwap(px.rgb, srcMin29, srcMax29, dstMin29, dstMax29, outColor)) return vec4(outColor, px.a);
    if (enabled30 > 0.5 && applySwap(px.rgb, srcMin30, srcMax30, dstMin30, dstMax30, outColor)) return vec4(outColor, px.a);
    if (enabled31 > 0.5 && applySwap(px.rgb, srcMin31, srcMax31, dstMin31, dstMax31, outColor)) return vec4(outColor, px.a);
    if (enabled32 > 0.5 && applySwap(px.rgb, srcMin32, srcMax32, dstMin32, dstMax32, outColor)) return vec4(outColor, px.a);

    return px;
}