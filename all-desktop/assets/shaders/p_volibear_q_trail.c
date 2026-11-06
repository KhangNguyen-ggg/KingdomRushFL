vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);
    number light = max(tex.r, max(tex.g, tex.b));
    vec3 gold = mix(vec3(1.0, 0.46, 0.10), vec3(1.0, 0.94, 0.68), smoothstep(0.3, 0.85, light));
    return vec4(gold, tex.a * light) * color;
}
