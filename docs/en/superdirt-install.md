# SuperDirt Installation Guide

SuperDirt is a SuperCollider extension for audio output in TidalCycles.

## Prerequisites
- SuperCollider must be installed
- For macOS: Download [SuperCollider.app](https://supercollider.github.io/download)

## Installation Methods

### Method 1: Install from SuperCollider (Recommended)

1. Launch SuperCollider
2. Execute the following code (Cmd+Enter to execute):

```supercollider
// Install Quarks (package manager)
Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.3"); thisProcess.recompile()})
```

3. Installation is complete when SuperCollider restarts

### Method 2: Manual Installation

1. Execute in SuperCollider:
```supercollider
// Open Quarks GUI
Quarks.gui
```

2. Find "SuperDirt" in the list and click the install button

### Method 3: Direct Installation from Git

```supercollider
Quarks.install("https://github.com/musikinformatik/SuperDirt.git");
```

## Verify Installation

Execute in SuperCollider:

```supercollider
// Start SuperDirt
SuperDirt.start
```

If successful, you'll see a message like:
```
SuperDirt: listening on port 57120
```

## Troubleshooting

### Error: "Class not found: SuperDirt"
- Restart SuperCollider
- Execute `Language > Recompile Class Library`

### Error: "Could not bind to requested port"
- Another process is using port 57120
- Restart SuperCollider or specify a different port:
```supercollider
~dirt = SuperDirt(2, s);
~dirt.start(57121); // Different port
```

### Samples Not Found
Download default samples:
```bash
cd ~/Library/Application\ Support/SuperCollider/downloaded-quarks/Dirt-Samples/
git clone https://github.com/musikinformatik/Dirt-Samples.git .
```

## Usage

1. Start SuperDirt in SuperCollider:
```supercollider
SuperDirt.start
```

2. Start TidalCycles (in a separate window)
3. You should hear sound!

## Useful Configuration

To automatically start SuperDirt when SuperCollider launches:

1. Select `File > Open startup file`
2. Add the following:

```supercollider
s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    ~dirt.start(57120);
}
```