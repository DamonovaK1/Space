#version 300 es

/*********
* Purple Stars with Trails - Neon Blue Galaxy
* Modified from original by Damon Novak
*/
precision highp float;
out vec4 O;
uniform vec2 resolution;
uniform float time;
uniform sampler2D pebbles;
#define FC gl_FragCoord.xy
#define T time
#define R resolution
#define MN min(R.x,R.y)

// Returns a pseudo random number for a given point (white noise)
float rnd(vec2 p) {
  p=fract(p*vec2(12.9898,78.233));
  p+=dot(p,p+34.56);
  return fract(p.x*p.y);
}

// Returns a pseudo random number for a given point (value noise)
float noise(in vec2 p) {
  vec2 i=floor(p), f=fract(p), u=f*f*(3.-2.*f);
  float
  a=rnd(i),
  b=rnd(i+vec2(1,0)),
  c=rnd(i+vec2(0,1)),
  d=rnd(i+1.);
  return mix(mix(a,b,u.x),mix(c,d,u.x),u.y);
}

// Returns a pseudo random number for a given point (fractal noise)
float fbm(vec2 p) {
  float t=.0, a=1.; mat2 m=mat2(1.,-.5,.2,1.2);
  for (int i=0; i<5; i++) {
    t+=a*noise(p);
    p*=2.*m;
    a*=.5;
  }
  return t;
}

float clouds(vec2 p) {
	float d=1., t=.0;
	for (float i=.0; i<3.; i++) {
		float a=d*fbm(i*10.+p.x*.2+.2*(1.+i)*p.y+d+i*i+p);
		t=mix(t,d,a);
		d=a;
		p*=2./(i+1.);
	}
	return t;
}

void main(void) {
	vec2 uv=(FC-.5*R)/MN,st=uv*vec2(2,1);
	vec3 col=vec3(0);
	
	// Neon blue galaxy background with black/grey tones
	float bg=clouds(vec2(st.x+T*.5,-st.y));
	vec3 galaxyColor = mix(vec3(0.0, 0.0, 0.0), vec3(0.1, 0.3, 0.8), bg * 0.3);
	galaxyColor = mix(galaxyColor, vec3(0.3, 0.3, 0.3), bg * 0.2);
	
	uv*=1.-.3*(sin(T*.2)*.5+.5);
	
	for (float i=1.; i<12.; i++) {
		uv+=.1*cos(i*vec2(.1+.01*i, .8)+i*i+T*.5+.1*uv.x);
		vec2 p=uv;
		float d=length(p);
		
		// Purple stars with varying intensity
		vec3 starColor = vec3(0.8, 0.2, 1.0); // Purple base color
		starColor *= (cos(sin(i)*3.0 + T*0.5) * 0.5 + 0.5); // Flickering
		col += .0015/d * starColor;
		
		// Star trails - smaller trailing stars
		for (float j = 1.; j < 4.; j++) {
			vec2 trailPos = p - vec2(cos(T * 0.3 + i) * j * 0.05, sin(T * 0.2 + i) * j * 0.03);
			float trailDist = length(trailPos);
			vec3 trailColor = starColor * (0.8 / j); // Dimmer trailing stars
			col += .0008/(trailDist * j) * trailColor;
		}
		
		float b=noise(i+p+bg*1.731);
		
		// Neon blue wisps and particles
		vec3 wispColor = vec3(0.0, 0.7, 1.0); // Neon blue
		col += .003*b*wispColor/length(max(p,vec2(b*p.x*.02,p.y)));
		
		// Mix with galaxy background
		col = mix(col, galaxyColor, d * 0.8);
	}
	
	// Final color adjustments for neon blue galaxy effect
	col = mix(col, vec3(0.0, 0.2, 0.6), length(uv) * 0.3);
	
	O=vec4(col,1);
}