// John Linnane
//118227214
// CS6103

// 1. RUN THIS CODE BLOCK FIRST

(
// boot server
s.boot;

// run stereo level meter
s.meter;

// run spectral analyzer
FreqScope.new;

// run oscilloscope
Stethoscope.new;
)


//*********************************************************************************************


// 2. RUN THIS CODE BLOCK SECOND

(
// create XY synth
// track cursor position along x and y values (with values minval, maxval, warp, lag)
// create a sine wavetable oscillator
// create band limited pulse wave (with arguments frequency, width, mul, add)
// run both generators through a reverb (FreeVerb)
~myXYSyn = {FreeVerb.ar(SinOsc.ar(MouseX.kr(100,500, 0, 0),0 ,0.1)+Saw.ar(MouseY.kr(100,500, 0, 0),0.1,0.1), 0.7, 0.7, 0.2)};

// define XY synth
// write signal to bus 0
SynthDef.new("xyDef",{ Out.ar(0, ~myXYSyn) }).add;
)

//Synth(\xyDef);              // test XY synth


//*********************************************************************************************


// 3. RUN THIS CODE BLOCK THIRD (REMEMBER TO PRESS F KEY)

(
// create additive synth
//modified from https://composerprogrammer.com/teaching/supercollider/sctutorial/2.1%20Subtractive%20and%20Additive%20Synthesis.html
~myAddSynth = {
   // create an array of ten channels
	var wave = Mix.fill(10, {|i|
		// multiply signal by odd harmonics
		var harmonicnumber = 2*i+1;
		// fill the array with this function
		SinOsc.ar(50*harmonicnumber)/harmonicnumber
	})*0.25;

	// keep finger pressed on the 'F' key to bring in the right stereo channel
	// use wave array in panning ugen
	Pan2.ar(wave,KeyState.kr(3, -1, 1)); //stereo, panned centre
}

// define additive synth
// write signal to bus 0
SynthDef.new("addDef",{ Out.ar(0, ~myAddSynth) }).add;
)

//Synth(\addDef);           // test additive synth


//*********************************************************************************************


// 4. RUN THIS CODE BLOCK FOURTH

(
// create subtractive synth
// create band pass filter (with values input, cut off frequency, output multiply)
// generate brownian noise and input to filter
// noise is filtered from 500Hz to 1000Hz by moving mouse along y-axis
~mySubSyn = {BPF.ar(BrownNoise.ar(0.7),MouseY.kr(500, 1000),0.2)}

// define subtractive synth
// write signal to bus 0
SynthDef.new("subDef", { Out.ar(0, ~mySubSyn) }).add;
)

//Synth(\subDef);           // test subtractive synth



//*********************************************************************************************


// 5. RUN THIS CODE BLOCK FIFTH

// create audio filepath
(
~myAudio = Buffer.read(s,thisProcess.nowExecutingPath.dirname +/+"wind.aif");


// define audio file player
~synthAudioFile = SynthDef.new("playBuffer", {
	                             arg bufnum=~myAudio.bufnum;
	                             // play back sample in memory
	                             // add reverb, delay, and panning
	                             // i constrained the two channel stereo wav to a single buffer channel so that I could pan slightly to the right (0.5)
	                             Out.ar(0, Pan2.ar(DelayN.ar(FreeVerb.ar(PlayBuf.ar(1,bufnum,loop:1),1,0.4,mul:2), 1, 1, 1), 0.5))
                                 }).add;
)

~synthAudioFile.play;          // test audio file


//*********************************************************************************************

// i used the following function to determine the keycode for the 'F' key

//(
//w = Window.new("I catch keystrokes");
//w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;  [char, keycode].postln; };
//w.front;
//)


//*********************************************************************************************

// 6. RUN THIS CODE BLOCK SIXTH


// play everything
(
{~synthAudioFile.play;          // plays the wav file
1.wait;                                  // waits one second
Synth(\xyDef);                      // plays the XY synth
1.wait;
Synth(\addDef);                    // plays the additive synth
1.wait;
Synth(\subDef);                    // plays the subtractive synth
}.fork;
)


// 7. FINISH BY CLEARING THE BUFFER AND QUITTING THE SERVER

// clear the buffer
Buffer.freeAll;

// quit server
s.quit;

	