#!/bin/perl

# attempt to convert particleman.c to Perl
require "/usr/local/lib/bclib.pl";
use OpenGL qw(:all);

# originally main:
glutInit();

# use double buffering + depth buffering
glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);

# optional: window size
glutInitWindowSize(800,600);

# create the window
glutCreateWindow("Particle Man");

# glutDisplayFunc(): what to do when display is damaged
glutDisplayFunc(display);

# glutIdleFunc(): what to do when application is idle
# often same as glutDisplayFunc()
glutIdleFunc(display);

glutMainLoop();

<>;

sub display {
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
glPushMatrix();
glBegin(GL_POINTS);
glColor3f(128,128,128);
glVertex2f(10,10);
glEnd();
glPopMatrix();
glutSwapBuffers();
}
