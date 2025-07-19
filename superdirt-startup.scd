// SuperDirt startup file
// Copy this to SuperCollider and execute

// Increase memory allocation for samples
s.options.memSize = 8192 * 64;

// Start audio server
s.waitForBoot {
    // Start SuperDirt
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles;
    ~dirt.start(57120, 0 ! 12);
    
    // Optional: load additional samples
    // ~dirt.loadSoundFiles("/path/to/your/samples/*");
    
    "SuperDirt is ready!".postln;
};

// To stop SuperDirt: ~dirt.stop;