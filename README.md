
433M83Octave
============

  A set of tools for [GNU Octave][1], to help analysing and decoding (not only 433MHz) [ISM band][2] signals.



  *Please notice that this is NOT complete yet!*



---

![Already 26°C?](/images/plot02.png?raw=true)

---

## What?

This is not a real-time protocol decoder, but a set of helpful tools to analyse recorded and already
demodulated signals from audio files.

Analysing unknown signals often requires "just looking at them", comparing waveforms, zooming in- and out,
as well as applying filters, offset corrections and many more...

These ISM protocols are all completely different and come in endless variations of

  - modulation
  - bitrate
  - number of bits
  - preambles
  - DC fillers
  - stuff-bits
  - time-coded bits
  - error corrections
  - ...

At least for simple, digital protocols, Octave (or 433M83Octave :) can be really helpful here.

It can

  - load waveforms
  - store as time-value format
  - apply filters
  - calculate offsets and moving thresholds
  - find peaks
  - estimate bitrates
  - extract packets from long recordings
  - split waveforms
  - stack plots to compare them
  - decode data
  - ...


## Prerequisites

In addition to an installation of GNU Octave, the following Octave packages are required:

  - octave-signal
  - ...


## Usage

  From within Octave

   - change to the directory where you copied the 433M83Octave tools
   - type *source asSigTools.m* to load the functions.

  Fire up a quick example by typing *asTest("signals/433M83_02.wav")*

  todo...


## Examples

  todo...
     

  
Have fun  
FMMT666(ASkr)    

---

[1]: https://www.gnu.org/software/octave
[2]: http://en.wikipedia.org/wiki/ISM_band
