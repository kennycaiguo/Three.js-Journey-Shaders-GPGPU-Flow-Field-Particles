// We are going to handle the flow field here
void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 particle = texture(uParticles, uv); // we already have access to uParticles without importing the uniform
    particle.y += 0.01;
    gl_FragColor = particle;
}