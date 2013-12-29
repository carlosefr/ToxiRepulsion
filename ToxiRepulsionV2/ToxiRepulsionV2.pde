/*
 * ToxiRepulsion.pde
 *
 * Copyright (c) 2011 Carlos Rodrigues <cefrodrigues@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import processing.opengl.*;
import processing.video.*;

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;


static final int NUM_PARTICLES = 500;
static final int NUM_ATTRACTORS = 2;
static final color[] palette = { #F2B035, #F2921D, #D96704, #BF4904 };


VerletPhysics2D physics;
AttractionBehavior mouseAttractor;

Vec2D mouse;
Vec2D center;
Vec2D[] attractors;


void setup() {
  size(640, 480, OPENGL);
  frameRate(30);
  smooth();
  
  glSmooth(true);
  glSync(true);
  
  physics = new VerletPhysics2D();
  physics.setDrag(0.05);

  center = new Vec2D(width/2.0, height/2.0);

  // Don't let particles leave the frame...
  physics.setWorldBounds(new Rect(0, 0, width, height));
  
  // Repulsion at the center of the frame...
  physics.addBehavior(new AttractionBehavior(center, 200, -2.0));

  // Create the spinning attractors...
  attractors = new Vec2D[NUM_ATTRACTORS];

  for (int i = 0; i < attractors.length; i++) {
    Vec2D v = new Vec2D(width/4.0, 0);
    v.rotate(TWO_PI / attractors.length * (i + 1));
    v.addSelf(center);

    physics.addBehavior(new AttractionBehavior(v, 1000, 0.3));    
    attractors[i] = v;
  }
  
  // Create the particles at random positions...
  for (int i = 0; i < NUM_PARTICLES; i++) {
    VerletParticle2D p = new ColoredParticle(random(0, width), random(0, height),
                                             palette[int(random(0, palette.length - 1))]);

    physics.addParticle(p);
    physics.addBehavior(new AttractionBehavior(p, 20, -0.5, 0.02));
  }
    
  background(0);
}


void draw() {
  background(#260101);

  // Rotate the attractors around the center of the frame...
  for (Vec2D v : attractors) {
    v.subSelf(center);
    v.rotate(PI / 128);
    v.addSelf(center);
  }
  
  physics.update();  

  noFill();
  int nParticles = physics.particles.size();
 
  for (int i = 0; i < nParticles; i++) {
    ColoredParticle a = (ColoredParticle)physics.particles.get(i);
    stroke(a.getColor(), 64);
  
    for (int j = i + 1; j < nParticles; j++) {
      VerletParticle2D b = physics.particles.get(j);
      
      if (a.distanceToSquared(b) < 1600) {
        line(a.x, a.y, b.x, b.y);
      }
    }
  }

  /*
  for (VerletParticle2D p : physics.particles) {
    ColoredParticle cp = (ColoredParticle)p;  
    cp.draw();
  }
  */
  
  if (frameCount % 100 == 0) {
    println(frameRate + " fps");
  }
}


void mousePressed() {
  if (mouseAttractor == null) {
    mouse = new Vec2D(mouseX, mouseY);
  
    // The left mouse button repels particles, the right mouse button attracts them...
    mouseAttractor = new AttractionBehavior(mouse, 200, 2.0 * (mouseButton == LEFT ? -1 : 1));
    physics.addBehavior(mouseAttractor);
  }
}


void mouseDragged() {
  mouse.set(mouseX, mouseY);
}


void mouseReleased() {
  physics.removeBehavior(mouseAttractor);
  mouseAttractor = null;
}


void keyReleased() {
  // Save a snapshot...
  if (key == 'c') {
    saveFrame("repulsion-" + frameCount + ".png");
  }
}


/* EOF - ToxiRepulsion.pde */
