class SynthEngine {
    constructor() {
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = 0.5;
        this.masterGain.connect(this.ctx.destination);
        
        // Track active instruments by ID
        this.activeInstruments = {}; 
        this.currentBaseFreq = 432.0;
        
        // Base noise buffer for instruments that need it (water/breath)
        const bufferSize = this.ctx.sampleRate * 2.0; // 2 seconds
        this.noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const output = this.noiseBuffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            output[i] = Math.random() * 2 - 1;
        }
    }

    // Stop a specific instrument
    stop(instrumentId) {
        if (!this.activeInstruments[instrumentId]) return;
        
        const inst = this.activeInstruments[instrumentId];
        const now = this.ctx.currentTime;
        
        // Fade out
        inst.master.gain.setTargetAtTime(0.001, now, 0.1);
        
        setTimeout(() => {
            inst.nodes.forEach(n => {
                try { n.stop(); } catch(e) {}
                try { n.disconnect(); } catch(e) {}
            });
            try { inst.master.disconnect(); } catch(e) {}
            delete this.activeInstruments[instrumentId];
        }, 150);
    }

    play(instrumentId) {
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
        
        // Stop it if it's already playing so we restart cleanly
        this.stop(instrumentId);
        
        // Create an instrument container
        const instMaster = this.ctx.createGain();
        instMaster.gain.value = 0.001; // Start silent
        instMaster.connect(this.masterGain);
        
        this.activeInstruments[instrumentId] = {
            master: instMaster,
            nodes: []
        };
        
        // Fade in
        instMaster.gain.setTargetAtTime(1.0, this.ctx.currentTime, 0.1);
        
        this._buildInstrument(instrumentId, this.currentBaseFreq);
    }

    setFrequency(freq) {
        this.currentBaseFreq = freq;
        const now = this.ctx.currentTime;
        
        // Update all playing oscillators across all active instruments
        Object.values(this.activeInstruments).forEach(inst => {
            inst.nodes.forEach(node => {
                if (node instanceof OscillatorNode && node.harmonicRatio) {
                    node.frequency.setTargetAtTime(freq * node.harmonicRatio, now, 0.1);
                }
            });
        });
    }
    
    // Internal helper to create and connect nodes for the specific instrument
    _addOsc(instId, freqRatio, type, gainValue, lfoNode = null, detune = 0) {
        const inst = this.activeInstruments[instId];
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        
        osc.type = type;
        osc.frequency.value = this.currentBaseFreq * freqRatio;
        osc.detune.value = detune;
        osc.harmonicRatio = freqRatio; 
        
        gain.gain.value = gainValue;
        
        if (lfoNode) {
            const lfoGain = this.ctx.createGain();
            lfoGain.gain.value = gainValue; 
            lfoNode.connect(lfoGain.gain);
            osc.connect(lfoGain);
            lfoGain.connect(inst.master);
            inst.nodes.push(lfoGain);
        } else {
            osc.connect(gain);
            gain.connect(inst.master);
        }
        
        osc.start();
        inst.nodes.push(osc);
        inst.nodes.push(gain);
        
        return osc;
    }
    
    _addLfo(instId, freq) {
        const inst = this.activeInstruments[instId];
        const lfo = this.ctx.createOscillator();
        lfo.type = 'sine';
        lfo.frequency.value = freq;
        lfo.start();
        inst.nodes.push(lfo);
        return lfo;
    }
    
    _addNoise(instId, gainValue, lfoNode = null) {
        const inst = this.activeInstruments[instId];
        const noise = this.ctx.createBufferSource();
        noise.buffer = this.noiseBuffer;
        noise.loop = true; 
        
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 1000;
        
        const gain = this.ctx.createGain();
        gain.gain.value = gainValue;
        
        noise.connect(filter);
        
        if (lfoNode) {
            const lfoGain = this.ctx.createGain();
            lfoGain.gain.value = gainValue; 
            lfoNode.connect(lfoGain.gain);
            filter.connect(lfoGain);
            lfoGain.connect(inst.master);
            inst.nodes.push(lfoGain);
        } else {
            filter.connect(gain);
            gain.connect(inst.master);
        }
        
        noise.start();
        inst.nodes.push(noise);
        inst.nodes.push(filter);
        inst.nodes.push(gain);
    }

    _buildInstrument(id, freq) {
        switch(id) {
            case 'tanpura':
                const tanpuraLfo = this._addLfo(id, 0.5);
                this._addOsc(id, 1.0, 'sawtooth', 0.2, tanpuraLfo);
                this._addOsc(id, 2.0, 'sine', 0.15, tanpuraLfo);
                this._addOsc(id, 3.0, 'sine', 0.1, tanpuraLfo);
                this._addOsc(id, 4.0, 'sine', 0.05, tanpuraLfo);
                break;
                
            case 'sarangi':
                const vibrato = this._addLfo(id, 5.0);
                const vibGain = this.ctx.createGain();
                vibGain.gain.value = 5.0;
                vibrato.connect(vibGain);
                this.activeInstruments[id].nodes.push(vibGain);
                
                const s1 = this._addOsc(id, 1.0, 'sawtooth', 0.15);
                const s2 = this._addOsc(id, 2.0, 'sine', 0.1);
                const s3 = this._addOsc(id, 3.0, 'triangle', 0.1);
                
                vibGain.connect(s1.frequency);
                vibGain.connect(s2.frequency);
                vibGain.connect(s3.frequency);
                
                const bowLfo = this._addLfo(id, 1.0);
                this._addNoise(id, 0.02, bowLfo);
                break;
                
            case 'root':
                const rootPulse = this._addLfo(id, 1.0);
                this._addOsc(id, 1.0, 'sine', 0.4);
                this._addOsc(id, 2.0, 'sine', 0.1);
                this._addOsc(id, 0.5, 'sine', 0.3, rootPulse);
                break;
                
            case 'sacral':
                const sacralLfo = this._addLfo(id, 0.2);
                this._addOsc(id, 1.0, 'sine', 0.3);
                this._addOsc(id, 1.5, 'sine', 0.15);
                this._addOsc(id, 2.5, 'sine', 0.1);
                this._addNoise(id, 0.05, sacralLfo);
                break;
                
            case 'solar_plexus':
                const bowlLfo = this._addLfo(id, 1.5);
                this._addOsc(id, 1.0, 'sine', 0.4);
                this._addOsc(id, 2.8, 'sine', 0.1, bowlLfo);
                this._addOsc(id, 5.4, 'sine', 0.05, bowlLfo);
                break;
                
            case 'heart':
                const breath = this._addLfo(id, 0.5);
                this._addOsc(id, 1.0, 'sine', 0.3, breath);
                this._addOsc(id, 2.0, 'triangle', 0.1, breath);
                this._addNoise(id, 0.01, breath);
                break;
                
            case 'throat':
                const swell = this._addLfo(id, 0.2);
                this._addOsc(id, 1.0, 'sine', 0.4, swell);
                this._addOsc(id, 1.0, 'sine', 0.4, swell, 2.0);
                this._addOsc(id, 3.0, 'sine', 0.05, swell);
                break;
                
            case 'third_eye':
                const eyeLfo = this._addLfo(id, 3.0);
                this._addOsc(id, 1.0, 'sine', 0.3);
                this._addOsc(id, 2.01, 'sine', 0.15, eyeLfo);
                this._addOsc(id, 3.02, 'sine', 0.05, eyeLfo);
                break;
                
            case 'crown':
                this._addOsc(id, 1.0, 'sine', 0.2);
                this._addOsc(id, 2.1, 'sine', 0.1);
                this._addOsc(id, 3.2, 'sine', 0.05);
                this._addOsc(id, 4.4, 'sine', 0.02);
                break;
                
            default:
                this._addOsc(id, 1.0, 'sine', 0.5);
                break;
        }
    }
}

// Make it available globally for Dart interop
window.synthEngine = new SynthEngine();
