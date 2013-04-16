float num = 1.; // particles generated per time interval
float life = 80000.; // life of each particle, in time units
float size_start = 0.001; // starting size of each particle
float size_end = 0.01; // ending size of each particle
VECTOR color_start = {1.,0.5,0.5}; // starting color of each particle
VECTOR color_end = {1.,0.5,0.5}; // ending color of each particle
VECTOR dir = {0.,0.01,0.}; // direction in which particles are emitted
VECTOR turb_dir = {.001,0,0}; // randomness of direction
VECTOR emitter = {0.75,0,0}; // location of particle emitter
VECTOR gravity = {-0.0001,0,0.}; // the force of gravity (or whatever)
