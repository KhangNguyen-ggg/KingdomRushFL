vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    number light = max(tex.r, max(tex.g, tex.b));
    number hot = clamp((min(tex.r, min(tex.g, tex.b)) - 0.55) / 0.45, 0.0, 1.0);
    vec3 blue = mix(vec3(0.08, 0.62, 1.0), vec3(0.7, 0.95, 1.0), hot) * light;
    return vec4(blue, tex.a) * color;
}
