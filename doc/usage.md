
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
 
    size( signal ) = ( 2, n )
   
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

  Draws a horizontal line on a plotted signal.

    asLineHoriz( signal, level, [color], [linewidth] )
    
    PARAMS: signal    - the signal to draw the line on (reference for length and position)
            level     - the level at which the line should be drawn
            color     - any Octave plot color, e.g. 'red', 'blue', ...
            linewidth - width of the line (default is 2)
    RETURN: -

  Notice that the 'color' and 'linewidth' parameters are positional. If you need to specify
  the width of the line, you can not skip the 'color' parameter (yet).
    
    EXAMPLES:
            asLineHoriz( sig1, 0.4 );
            asLineHoriz( sig2, -2.1, 'red', 5 );


#### asLinePoly()

  Draws a polyline on the plot.  

    asLinePoly( signal, [color], [linewidth] )
    asLinePoly( xs, ys, [color], [linewidth] )
    
    PARAMS: signal    - a signal containing time-value pairs
            xs, ys    - two arrays with xs as time and ys as value data.
            color     - any Octave plot color, e.g. 'red', 'blue', ...
            linewidth - width of the line (default is 2)
    
    RETURN: -

  At a glance, this function equals asPlot(), but it allows
  
  - adding signals to an existing plot or
  - drawing signals of different lengths over each other.

  Keep in mind that xs and ys need to have the same dimensions.
  
  Also notice that the 'color' and 'linewidth' parameters are positional. If you need to specify
  the width of the line, you can not skip the 'color' parameter (yet).

    EXAMPLES:
            asLinePoly( sig1 );
            
            a = [ 0, 10, 20, 30 ];
            b = [ 1,  5, -3,  4 ];
            asLinePoly( a, b, 'red' );
    
---
### Math

#### asFilterLowPass()

  Applies a [Butterworth][1] low pass filter to a signal.  
  

    sigFilt = asFilterLowPass( signal, frequency, order )
    
    PARAMS: signal    - signal to which the filter should be applied
            frequency - corner frequency
            order     - filter order
    RETURN: sigFilt   - the filtered signal
    
  The original signal will not be changed.
    
    EXAMPLES:
            sigFilt1 = asFilterLowPass( sigOrg, 50, 2 );


#### asListPeaks()

  Creates and returns a list of peaks found in a signal.  
  Not a perfect solution for now, but still helpful for finding pulses or determining bit lengths.
  
  For now, asListPeaks() uses a simple, static threshold level (without hysterisis) and
  no fancy dynamically adpated trigger levels (TODO).
  
    listPeaks = asListPeaks( signal, triggerLevel )

    PARAMS: signal       - the signal which should be analysed
            triggerLevel - the threshold level above which peak should be recognized
    RETURN: an array of size (4, n) with [ time, peakval, length, peaktime ] pairs.
            time     - the time at which the threshold was exceeded
            peakval  - value of the topmost sample
            length   - time spent above the threshold level
            peaktime - time at which the point of the topmost sample was acquired

  The 1st index, "time", specifies the time at which the threshold level "triggerLevel" was exceeded.
  Usually (tm) true for the start of a bit or the beginning of a pulse, whereas the 4th index,
  "peaktime" determines the time at which the highest value occured.
   
    EXAMPLES:
            listPeaks = asListPeaks( sigFilt, 0.2 );
            
  To plot this list of peaks over a plot of "sigFilt":
  
    asPlot( sigFilt, 'linewidth', 2 );
    
    asLinePoly( listPeaks( 1:2, : ) );
    % or
    asLinePoly( listPeaks(1,:), listPeaks(2,:) );

  For an overview of (possible) bit length, try something like
  
    [ num, time ] = hist( listPeaks(3,:), bins );
    
  and experiment with the "bins" value. A good start is usually around the length of the
  "listPeaks" array, down to 1/10 of the length.
  
  Repetive bits of the same length form several peaks at n*bittime.

    
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



---
[1]: http://en.wikipedia.org/wiki/Butterworth_filter
