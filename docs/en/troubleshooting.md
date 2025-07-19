# Troubleshooting

## SuperDirt Sample Errors

### Error Messages
```
WARNING: SuperDirt: event falls out of existing orbits, index (1)
no synth or sample named 'hh' could be found.
module 'sound': instrument not found: hh
```

### Cause
SuperDirt's default samples are not installed or not loaded correctly.

### Solutions

#### Method 1: Install Dirt-Samples

1. Execute in SuperCollider:
```supercollider
Quarks.install("https://github.com/musikinformatik/Dirt-Samples.git");
```

2. Restart SuperCollider

3. Restart SuperDirt:
```supercollider
// Stop first
~dirt.stop;

// Restart
~dirt = SuperDirt(2, s);
~dirt.loadSoundFiles;
~dirt.start(57120, 0 ! 12);  // Create 12 orbits
```

#### Method 2: Manual Sample Download

1. Run in terminal:
```bash
cd ~/Library/Application\ Support/SuperCollider/downloaded-quarks/
git clone https://github.com/musikinformatik/Dirt-Samples.git
```

2. In SuperCollider:
```supercollider
// Load samples with specific path
~dirt.loadSoundFiles("~/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples/*");
```

#### Method 3: Add Custom Sample Directory

```supercollider
// Startup configuration
s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    
    // Load default samples
    ~dirt.loadSoundFiles;
    
    // Add custom samples
    ~dirt.loadSoundFiles("/path/to/your/samples/*");
    
    // Start with 12 orbits (default is 2)
    ~dirt.start(57120, 0 ! 12);
    
    // Check loaded samples
    ~dirt.postSampleInfo;
};
```

### Orbit Count Issues

The error "event falls out of existing orbits" indicates the orbit number you're trying to use doesn't exist.

```supercollider
// Start with 12 orbits (enables d1 through d12)
~dirt.start(57120, 0 ! 12);

// Or 16 orbits
~dirt.start(57120, 0 ! 16);
```

### Checking Samples

To verify loaded samples:
```supercollider
// List all samples
~dirt.postSampleInfo;

// Search for specific samples
~dirt.buffers.keys.select({|x| x.asString.contains("bd")}).postln;
```

### Common Sample Names

| Sample | Description |
|--------|-------------|
| bd | Bass drum |
| sn | Snare |
| hh | Hi-hat |
| cp | Clap |
| arpy | Arpeggio |
| bass | Bass |
| feel | Feel |
| future | Future |

If these are not available, you need to install Dirt-Samples.