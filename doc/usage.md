
433M83Octave Mini Usage Doc
===========================

---
## Preface

 Blablabla...


---
## Waveform handling

### Signal

  todo...

### Signal Cells

  todo...

### peakLists

  todo...

### deltaLists

  todo...

### bitLists

  todo...


---
## Functions

 Description of all available functions.

---
### Loading

 All signals in 433M83Octave are time-value arrays with the size of
 
   size( signal ) = 2, n
   
 where 'n' is the number of samples the loaded signal.  
 
   signal( 1, : ) contains the time in seconds
   signal( 2, : ) contains the real value of the sample

 Loading of stereo files or complex signals, e.g. IQ is and will not be supported.  
 This is all about decoding "simple" [...], time-domain protocols (for now).
  

#### asLoadWav()

  Loads a WAV file as a signal.

    [ signal, sampleRate ] = asLoadWav( fileName )

  or just
  
    signal = asLoadWav( fileName )
    
    PARAMS: filename   - a string with the file name to load
    RETURN: signal     - the loaded, two dimensional waveform
                         ( 1, : ) - time in seconds
                         ( 2, : ) - values
            sampleRate - optional, returns the WAV file's bitrate in bits/s

  Right now, only mono WAV files are supported.  
  On error, Octave is forced to crash (for now ;-)

    EXAMPLES:
            sig1 = asLoadWav( "recording.wav" );
            [sig2, bRate] = asLoadWav( "signals/Gurke.wav" );


---
### Plotting

#### asPlot()

  Plots one or more signals or signal cells.  
  Additionally, any Octave plot() command options may be entered too, but they
  will be valid for all signals. E.g. a "color" tag will change the color of _all_
  signals, not only the last one.

    asPlot( signal, [signal/option], ... )
    
    PARAMS: signal - one or more signals, comma separated
            option - any Octave plot() options (e.g. 'color', 'linewidth', etc...)
    RETURN: -


    EXAMPLES:
            asPlot( signal1 );
            asPlot( signal1, 'color', 'red' );
            asPlot( signal1, signal2, signal3 );
            asPlot( signalCell );
            
  Notice that the signals must have the same dimensions.  
  Use asSignalUnify() to create equal length signals in case they differ.
            
             
#### asLineHoriz()

    asLineHoriz( signal, level, [color], [linewidth] )

#### asLinePoly( signal, [color], [linewidth] )
#### asLinePoly( xs, ys, [color], [linewidth] )

---
### Math

#### asFilterLowPass( signal, frequency, order )
#### asListPeaks( signal, triggerLevel  )
#### asListDeltas( peakList )
#### asListPackets( deltaList, timeNoPeak )
#### asFindBitTime( deltaList, tolerancePercent, [ownBitLength] )
#### asFindSamplesByTime( signal, sTim, [varargin] )
#### asSignalSplit( signal, sampleStartEnd )
#### asSignalUnify( sigCell )
#### asSignalShiftUnder( signal1, signal2 )
#### asSignalStack( sigCell )

#### asTest( fileName )


---
## Examples


### Load and display a signal

### Snipping signals packets

### Comparing signals packets



