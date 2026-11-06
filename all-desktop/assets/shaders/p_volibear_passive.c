vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    // shortcut: the mask follows this skin's baked colors; recalibrate if its texture changes.
    number chroma = max(tex.r, max(tex.g, tex.b)) - min(tex.r, min(tex.g, tex.b));
    number markings = smoothstep(0.28, 0.48, chroma) * smoothstep(0.58, 0.82, tex.r)
        * smoothstep(0.10, 0.25, tex.r - tex.g);
    tex.rgb = min(vec3(1.0), tex.rgb + vec3(1.0, 0.60, 0.22) * (0.50 * markings));
    return tex * color;
}
