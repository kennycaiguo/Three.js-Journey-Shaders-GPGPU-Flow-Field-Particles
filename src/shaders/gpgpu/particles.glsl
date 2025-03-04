// We are going to handle the flow field here
uniform float uTime;
uniform float uDeltaTime;
uniform sampler2D uBase;
uniform float uFlowFieldInfluence;
uniform float uFlowFieldStrength;
uniform float uFlowFieldFrequency;

#include ../includes/simplexNoise4d.glsl

void main() {
    float time = uTime * 0.2;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 particle = texture(uParticles, uv); // we already have access to uParticles without importing the uniform
    vec4 base = texture(uBase, uv);

    if (particle.a >= 1.0) {
        particle.a = mod(particle.a, 1.0); // if it's more than 1.0 then the particle is dead, also modulo fixes browsers's induced bug of stopping the tick function once you change tab
        particle.xyz = base.xyz;
    } else {
        // Flow field strength
        float strength = simplexNoise4d(vec4(base.xyz * 0.2, time + 1.0));
        float influence = (uFlowFieldInfluence - 0.5) * (- 2.0);
        strength = smoothstep(influence, 1.0, strength);

        // Flow field (alive particles)
        vec3 flowField = vec3(
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 0.0, uTime)), // x
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 1.0, uTime)), // y
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 2.0, uTime)) // z
        ); // the direction towards which the particles should move
        flowField = normalize(flowField); // being a direction, directions need to be normalized
        particle.xyz += flowField * uDeltaTime * strength * uFlowFieldStrength; // we "nerf" the flow field by multiplying it

        // Decay
        particle.a += uDeltaTime * 0.3;
    }

    gl_FragColor = particle;
}