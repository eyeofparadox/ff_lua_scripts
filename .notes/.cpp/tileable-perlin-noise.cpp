// https://observablehq.com/@toja/tileable-perlin-noise
// Based on Stefan Gustavson's implementation: https://github.com/stegu/perlin-noise

p = {
  const permutation = [
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
  ];

  // avoid overflow
  const p = new Uint8Array(512);
  for (let i = 0; i < 256 ; i++) {
    p[i] = p[256 + i] = permutation[i];
  }
  
  return p
}

function perlin2(x, y, px, py) {
  
    // Integer part of x, y
    let xi = Math.floor(x);  
    let yi = Math.floor(y);
  
    // Fractional part of x, y
    let xf = x - xi;
    let yf = y - yi;
  
    // Wrap to 0..px-1 and wrap to 0..255
    let xi1 = (px ? ( xi + 1 ) % px : xi + 1) & 0xff;
    let yi1 = (py ? ( yi + 1 ) % py : yi + 1) & 0xff;
  
    xi = (px ? xi % px : xi) & 0xff;
    yi = (py ? yi % py : yi) & 0xff;

    let s = fade(xf);
    let t = fade(yf);

    return lerp(s,
                lerp(t,
                     grad2(p[xi + p[yi]], xf, yf),
                     grad2(p[xi + p[yi1]], xf, yf - 1)
                    ),
                lerp(t,
                     grad2(p[xi1 + p[yi]], xf - 1, yf),
                     grad2(p[xi1 + p[yi1]], xf - 1, yf - 1)
                    )
               );
}

function perlin3(x, y, z, px, py, pz) {
    
    // Integer part of x, y, z;
    let xi = Math.floor(x);
    let yi = Math.floor(y);
    let zi = Math.floor(z);
  
    // Fractional part of x, y, z
    let xf = x - xi;
    let yf = y - yi;
    let zf = z - zi;
  
    // Wrap to 0..px-1 and wrap to 0..255
    let xi1 = (px ? ( xi + 1 ) % px : xi + 1) & 0xff;
    let yi1 = (py ? ( yi + 1 ) % py : yi + 1) & 0xff;
    let zi1 = (pz ? ( zi + 1 ) % pz : zi + 1) & 0xff;
    
    xi = (px ? xi % px : xi) & 0xff;
    yi = (py ? yi % py : yi) & 0xff;
    zi = (pz ? zi % pz : zi) & 0xff;
    
    let r = fade(zf);
    let t = fade(yf);
    let s = fade(xf);
  
    let A = p[yi  + p[zi ]];
    let B = p[yi  + p[zi1]];
    let C = p[yi1 + p[zi ]];
    let D = p[yi1 + p[zi1]];
    
    return lerp(s,
                lerp(t,
                     lerp(r,
                          grad3(p[xi  + A], xf, yf, zf),
                          grad3(p[xi  + B], xf, yf, zf - 1)
                         ),
                     lerp(r,
                          grad3(p[xi  + C], xf, yf - 1, zf),
                          grad3(p[xi  + D], xf, yf - 1, zf - 1)
                          )
                    ),
                lerp(t,
                     lerp(r,
                          grad3(p[xi1 + A], xf - 1, yf, zf),
                          grad3(p[xi1 + B], xf - 1, yf, zf - 1)
                         ),
                     lerp(r,
                          grad3(p[xi1 + C], xf - 1, yf - 1, zf),
                          grad3(p[xi1 + D], xf - 1, yf - 1, zf - 1)
                         )
                    )
               );
}

function perlin4(x, y, z, w, px, py, pz, pw) {

    // Integer part of x, y, z, w
    let xi = Math.floor(x);
    let yi = Math.floor(y);
    let zi = Math.floor(z);
    let wi = Math.floor(w);
  
    // Fractional part of x, y, z, w
    let xf = x - xi;
    let yf = y - yi;
    let zf = z - zi;
    let wf = w - wi;
  
    // Wrap to 0..px-1 and wrap to 0..255
    let xi1 = (px ? (xi + 1) % px : xi + 1) & 0xff;
    let yi1 = (py ? (yi + 1) % py : yi + 1) & 0xff;
    let zi1 = (pz ? (zi + 1) % pz : zi + 1) & 0xff;
    let wi1 = (pw ? (wi + 1) % pw : wi + 1) & 0xff;
  
    xi = (px ? xi % px : xi) & 0xff;
    yi = (py ? yi % py : yi) & 0xff;
    zi = (pz ? zi % pz : zi) & 0xff;
    wi = (pw ? wi % pw : wi) & 0xff;

    let q = fade(wf);
    let r = fade(zf);
    let t = fade(yf);
    let s = fade(xf);
  
    let A = p[zi + p[wi]];
    let B = p[zi + p[wi1]];
    let C = p[zi1 + p[wi]];
    let D = p[zi1 + p[wi1]];
    
    let A1 = p[yi + A], A2 = p[yi1 + A];
    let B1 = p[yi + B], B2 = p[yi1 + B];
    let C1 = p[yi + C], C2 = p[yi1 + C];
    let D1 = p[yi + D], D2 = p[yi1 + D];

    return lerp(s,
                lerp(t,
                     lerp(r,
                          lerp(q,
                               grad4(p[xi + A1], xf, yf, zf, wf),
                               grad4(p[xi + B1], xf, yf, zf, wf - 1)
                              ),
                          lerp(q,
                               grad4(p[xi + C1], xf, yf, zf - 1, wf),
                               grad4(p[xi + D1], xf, yf, zf - 1, wf - 1)
                              )
                         ),
                     lerp(r,
                          lerp(q,
                               grad4(p[xi + A2], xf, yf - 1, zf, wf),
                               grad4(p[xi + B2], xf, yf - 1, zf, wf - 1)
                              ),
                          lerp(q,
                               grad4(p[xi + C2], xf, yf - 1, zf - 1, wf),
                               grad4(p[xi + D2], xf, yf - 1, zf - 1, wf - 1)
                              )
                         )
                    ),
                lerp(t,
                     lerp(r,
                          lerp(q,
                               grad4(p[xi1 + A1], xf - 1, yf, zf, wf),
                               grad4(p[xi1 + B1], xf - 1, yf, zf, wf - 1)
                              ),
                          lerp(q,
                               grad4(p[xi1 + C1], xf - 1, yf, zf - 1, wf),
                               grad4(p[xi1 + D1], xf - 1, yf, zf - 1, wf - 1)
                              )
                         ),
                     lerp(r,
                          lerp(q,
                               grad4(p[xi1 + A2], xf - 1, yf - 1, zf, wf),
                               grad4(p[xi1 + B2], xf - 1, yf - 1, zf, wf - 1)
                              ),
                          lerp(q,
                               grad4(p[xi1 + C2], xf - 1, yf - 1, zf - 1, wf),
                               grad4(p[xi1 + D2], xf - 1, yf - 1, zf - 1, wf - 1)
                              )
                         )
                    )
               );
}

function grad2(hash, x, y) {
    const h = hash & 7;       // Convert low 3 bits of hash code
    const u = h < 4 ? x : y;  // into 8 simple gradient directions,
    const v = h < 4 ? y : x;  // and compute the dot product with (x,y).
    return (h & 1 ? -u : u) + (h & 2 ? -v : v);
}

function grad3(hash, x, y, z) {
    const h = hash & 15;
    const u = h < 8 ? x : y;
    const v = h < 4 ? y : h === 12 || h === 14 ? x : z;
    return (h & 1 ? -u : u) + (h & 2 ? -v : v);
}

function grad4(hash, x, y, z, t) {
    const h = hash & 31;      // Convert low 5 bits of hash code into 32 simple
    const u = h < 24 ? x : y; // gradient directions, and compute dot product.
    const v = h < 16 ? y : z;
    const w = h < 8 ? z : t;
    return (h & 1 ? -u : u) + ( h & 2 ? -v : v) + (h & 4 ? -w : w);
}

function fade(t) {
  return t * t * t * (t * (t * 6 - 15) + 10);
}

function lerp(t, a, b) {
  return a + t * (b - a);
}


