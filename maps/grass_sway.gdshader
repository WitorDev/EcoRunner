shader_type canvas_item;

// =============================
// Adjustable parameters (Inspector)
// =============================

// Maximum horizontal movement in pixels
uniform float wind_strength = 1.0;

// How fast the wind animation runs
uniform float wind_speed = 2.0;

// Portion of the sprite that stays still at the bottom.
// 0.4 = bottom 40% mostly static
uniform float height_mask = 0.1;


void fragment() {

    // =============================
    // 1️⃣ Get base UV coordinates
    // =============================
    // UV ranges from 0.0 to 1.0 across the texture
    vec2 uv = UV;


    // =============================
    // 2️⃣ Animate over time
    // =============================
    // TIME is a built-in Godot value (seconds since start)
    float time = TIME * wind_speed;


    // =============================
    // 3️⃣ Convert UV → pixel coordinates
    // =============================
    // TEXTURE_PIXEL_SIZE = size of 1 pixel in UV space
    // For 16x16 texture: 1 pixel = 1.0 / 16.0
    //
    // This gives us exact pixel row numbers (0–15 for 16x16)
    vec2 pixel_pos = floor(uv / TEXTURE_PIXEL_SIZE);

    // Extract the vertical pixel index
    float pixel_y = pixel_pos.y;


    // =============================
    // 4️⃣ Height-based movement mask
    // =============================
    // Makes the bottom part move less than the top.
    //
    // Below height_mask → value close to 0 (no movement)
    // Above it → gradually increases to 1 (full movement)
    float mask = clamp( (1.0 - height_mask),
        0.0,
        1.0
    );


    // =============================
    // 5️⃣ Create wind wave
    // =============================
    // sin() creates smooth oscillation
    //
    // pixel_y * 0.5 adds phase difference per row
    // → Each row moves slightly differently
    // → Prevents the sprite from sliding as one block
    float wave = sin(time + pixel_y * 0.5);


    // =============================
    // 6️⃣ Convert wave → pixel movement
    // =============================
    // Multiply by:
    // - wind_strength → how far it can move
    // - mask → how much that row is allowed to move
    //
    // round() is CRITICAL for pixel art.
    // It prevents subpixel blur.
    float offset_pixels = round(wave * wind_strength * mask);


    // =============================
    // 7️⃣ Convert pixel movement back to UV
    // =============================
    // We convert pixel offset → UV offset
    float uv_offset = offset_pixels * TEXTURE_PIXEL_SIZE.x;

    // Apply horizontal displacement
    uv.x += uv_offset;


    // =============================
    // 8️⃣ Draw final pixel
    // =============================
    COLOR = texture(TEXTURE, uv);
}
