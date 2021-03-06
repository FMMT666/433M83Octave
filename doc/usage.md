
433M83Octave Mini Usage Doc
===========================


## Preface

 I am missing words here...


---
## Usage

### Installation

  As of now (1/2015) there is nothing to install.  
  Just start Octave, cd to the 433M83Octave directory and type
  
    source asSigTools.m

  to load all the functions [...].


---
## Waveform handling

### Signal

  A two dimensional array of size (2,n), containing a sampled waveform.
  
    (1,:) - time
    (2,:) - value
    

### Signal Cells

  An Octave cell {1,n}, containing n signals.

    {1,1} - signal1
    {1,2} - signal2
    {1,n} - signal<n>


### listPeaks

  A four dimensional array of size (4,n).

    (1,:) - time
    (2,:) - peakval
    (3,:) - length
    (4,:) - peaktime


### listDeltas

  A two dimensional array of size (2,n), containing absolute time stamps of "occurences" [time] and
  time differences to another "occurence".
  
    (1,:) - time
    (2,:) - time differences


### listPackets

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
   
  where 'n' is the number of samples of the loaded signal.  
 
    signal( 1, : ) contains the time in seconds
    signal( 2, : ) contains the real value of the sample

  Loading of stereo files or complex signals, e.g. IQ is and will not be supported.  
  This is all about decoding "simple" [...], time-domain protocols (for now).
  

#### asLoadWav()

  Loads a WAV file to a signal variable.

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


#### asDemo<n>()

  A quick demonstration to show off some of 433M82Octave's features.
  
    asDemo1()
    asDemo2()
    
    PARAMS: -
    RETURN: -
    

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


#### asSignalStack()

  Shifts one signal under a second one.  
  Useful for comparing multiple waveforms that just don't look good when plotted all
  over each other.
  
  The original signal will not be changed.
  
  To shift multiple signals, also take a look at asSignalStack().

    [ signalNew, offset ] = asSignalStack( signal1, signal2 )

    PARAMS: signal1   - the signal that should be shifted under the 2nd one
            signal2   - the reference signal, that will stay on top
            
    RETURN: signalNew - a copy of signal1, with an appropriate offset applied.
            offset    - the offset that was applied to signalNew
    
    EXAMPLES:
            sn = asSignalStack( s1, s2 )
            [ sn, offs ] = asSignalStack( s1, s2 )


#### asSignalStackCell()

  Shifts all signals of a cell array under each other, creating a stack of signals.  
  The first signal will be on top. Each following signal will be shifted under the previous one.

  The original signal cell will not be changed.
 
    newSigCell = asSignalStackCell( sigCell )

    PARAMS: sigCell    - a one dimensional cell of n signals {1,n}
        
    RETURN: newSigCell - a copy of sigCell with offsets applied to each of the signals
    
    EXAMPLES:
            cellStacked = asSignalStackCell( sigCell )   % lol, what are examples for :-)


#### asSignalAmplitude()

  Modifies a signal's amplitude bei either an absolute factor or to match another signal's
  amplitude, weighted by a factor.  
  Useful for comparing different signals or any other [time, value] arrays (signals, listDeltas,
  linePolys, etc...) to each other.

    sigAmp = asSignalAmplitude( signal, factor, [sigRef] )

    PARAMS: signal - the input signal 
            factor - factor to multiply signal with
            sigRef - optional; if given, the input signal's amplitude will be matched to fit
                     sigRef's amplitude.
                     Factor is then used as a normalized factor to sigRef's amplitude.
                     0.5 - half amplitude (50%)
                     0.7 - 70%
                     1.2 - 120%
          
    RETURN: sigAmp - a copy of signal with modified amplitude

  WARNING:  
   Make sure that you don't use modified deltaLists to to extract packets via
   asListPacketsByDeltas(). This _won't_ work because the shifted amplitude will
   create wrong time offsets and result in empty lists!
  
    EXAMPLES:
            % multiplies signal1's values with 2.34
            signal2 = asSignalAmplitude( signal1, 2.34 );
          
            % set lDelta1 amplitude to 75% of signal1 and draw both in the same plot
            lDelta2 = asSignalAmplitude( lDelta1, 0.75, signal1 );
            asPlot( signal1 );
            asLinePoly( lDelta2 );


#### asSignalMatch()

  Modifies the offset and amplitude of a signal to match a 2nd one.  
  Useful for plotting signals in signals.
  
  The bottom of signal1 will be shifted to match the vertical position of signal2,
  anywhere from bottom (mode == 0) to top (move == 1) or beyond.
  
    sigMat = asSignalMatch( signal1, sigRef, move, [scale] )

    PARAMS: signal1 - the signal to be modified
            sigRef  - the reference signal
            move    - value from 0..1 (or more :-) to shift signal1 along the
                      vertical position of sigRef. From bottom to top, 0..1.
                      Smaller or greater values can also be used.
            scale   - optional; if given, the amplitude of signal1 can be matched to sigRef.
                      This calls asSignalAmplitude( signal1, scale, sigRef)
                    
    RETURN: sigMat  - a modified copy of signal1

  WARNING:  
   Make sure that you don't use modified deltaLists to to extract packets via
   asListPacketsByDeltas(). This _won't_ work because the shifted amplitude will
   create wrong time offsets and result in empty lists!

    EXAMPLES:
            % move the bottom of signal1 to the vertical middle of signal2.
            sm = asSignalMatch( signal1, signal2, 0.5 );

            % move and plot signal1 and listDelta, at 25% height in the middle (50%)
            asPlot( signal1 );
            ldm = asSignalMatch( listDeltas, signal1, 0.5, 0.25 );
            asLinePoly( ldm );

---
### Filter

#### asFilterLowPass()

  Applies a [Butterworth][1] low pass filter to a signal.  
  

    sigFilt = asFilterLowPass( signal, frequency, order )
    
    PARAMS: signal    - signal to which the filter should be applied
            frequency - corner frequency of the low pass filter
            order     - filter order
    RETURN: sigFilt   - the filtered signal
    
  The original signal will not be changed.
    
    EXAMPLES:
            sigFilt1 = asFilterLowPass( sigOrg, 50, 2 );


#### asFilterMinMax()

  Creates a new signal, that either follows (aka "clamps") all maximum or minimum peaks of a given signal.  
  Useful for calculating dynamic thresholds.
  
    sigMinMax = asFilterMinMax( signal, fallOff, [type] )
    
    PARAMS: signal    - the input signal
            fallOff   - value that specifies the peak falloff (see below)
                        A positive value follows the max peaks, whereas a negative one
                        follows the min peaks.
            type      - future upgrade, specifies the falloff curve shape
                        'linear', '1/x', 'exp', ...
                        defaults to 'linear' for now.
            
    RETURN: sigMinMax - a two-dimensional signal of [ time, value ] with either
                        min or max values

  As for now, only 'linear' falloff is supported and selected by default.
  
  linear:
   Depending on the sign of fallOff, which either selects if the max peaks (>0) or the min peaks
   (<0) should be followed, the output signal always follows a peak to its max/min value, but then
   falls off (either down or up) linear, with fallOff subtracted every sample
     sigMinMax(t) = peak - (t * fallOff)
   until the next peak appears.

  exponential:
   todo...
   
  halfed:
   todo...

  todo...



---
### Segmenting

#### asListPeaks()

  Creates and returns a list of peaks found in a signal. Useful for "Return to Zero" signals.  
  Not a perfect solution for now, but still helpful for finding pulses or determining bit lengths.
  
  For now, asListPeaks() uses a simple, static threshold level (without hysteresis) and
  no fancy dynamically adpated trigger levels (TODO).
  
    listPeaks = asListPeaks( signal, triggerLevel )

    PARAMS: signal       - the signal which should be analysed
            triggerLevel - the threshold level above which peak should be recognized
    RETURN: listPeaks    - an array of size (4, n) with [ time, peakval, length, peaktime ] pairs:
    
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


#### asListPeaksCell()

  Creates and returns a cell of peaks found in a cell of multiple signal.  
  A handy shortcut to calling asListPeaks() with a cell that may contain multiple signals.
  
    cellPeaks = asListPeaks( sigCell, triggerLevel )

    PARAMS: sigCell      - a one dimensional cell of size {1,n}, containing n signals
            triggerLevel - the threshold level above which peak should be recognized
    RETURN: cellPeaks - a cell of size {1,n}, containing an array of size (4, n) with  
                        [ time, peakval, length, peaktime ] pairs:
                time     - the time at which the threshold was exceeded
                peakval  - value of the topmost sample
                length   - time spent above the threshold level
                peaktime - time at which the point of the topmost sample was acquired

    
#### asListDeltas()

  Creates a list of time differences from a list of peaks.  
  Useful for protocols, where the data is coded in terms of time or pulses, like, e.g.
  "Return to Zero" transfers.

    listDeltas = asListDeltas( listPeaks )
    
    PARAMS: listPeaks  - a list of peaks, e.g. as created by asListPeaks()
    
    RETURN: listDeltas - a two dimensional [ time, dtime ] array
                         time(n)  = tpeak(n)
                         dtime(n) = tpeak(n+1) - tpeak(n)

  Remembering that listPeaks is a (4,n) array with [ time, peakval, length, peaktime ],    
  asListDeltas() uses listPeaks's "time" (1,:) index to calculate the time differences.
    
    EXAMPLES:
            todo...


#### asListDeltasCell()

  Creates a cell of listDeltas from a cell of peaks.  
  A handy shortcut to calling asListDeltas() with a cell that may contain multiple listPeaks.

    cellDeltas = asListDeltas( cellPeaks )
    
    PARAMS: cellPeaks  - a cell of listPeak, as created by asListPeaksCell()
    
    RETURN: cellDeltas - a one dimensional cell of size {1,n}, containing listDeltas [ time, dtime ] arrays.
                         time(n)  = tpeak(n)
                         dtime(n) = tpeak(n+1) - tpeak(n)

    EXAMPLES:
            todo...
    
    
#### asListPacketsByDeltas()

  Fed with a deltaList and the timeout value "timeNoPeak", this function can be used to
  extract active area timings (presumably data packets) from a signal.  
  
  This will only work if
  
  - the peak to peak noise between the packets is lower than a [...] threshold level and
  - the active area is always busy and does not "time out" or show no activity for a
    period longer than timeNoPeak.
  - the delta list was _not_ modified by any of the amplitude or offset shifting plot
    functions!

  [...]

      +--+ +-+ +--+ +-+              +--+ +-+ +--+ +-+              +-+  
      |  | | | |  | | |              |  | | | |  | | |              | |  
      +  +-+ +-+  +-+ +--------------+  +-+ +-+  +-+ +--------------+ +  
      |< active area >|< timeNoPeak >|< active area >|< timeNoPeak >|


  This is useful for decoding time coded protocols (though it might even be used to decode
  ASK modulations) or gaining more information about occurrences of pulses.
  
  
    [ listPackets, deltaListShort ] = asListPacketsByDeltas( listDeltas, timeNoPeak )

    PARAMS: listDeltas - a list of delta times of peaks, e.g. created by asListDeltas()
            timeNoPeak - time of no activity in seconds
            
    RETURN: listPackets    - two dimensional (2,n) list with [ starttime, endtime ] of the active areas
            deltaListShort - same as deltaList, except that times > timeNoPeak are removed
    
    EXAMPLES:
            lp = asListPacketsByDeltas( listDeltas, 1.0 );

            lp =
              1.4045    2.3376
              4.9190    5.8541
              8.0133    8.9466
             11.8366   12.7883
             15.1104   16.0618
             ...

            [ lp, dl ] = asListPacketsByDeltas( listDeltas, 0.7 );
            
    
#### asFindBitTime()

  Tries to determine the bit time in a list of delta times.  
  Should be handle with care because the "algorithm" is not very clever yet...

    [ bitTime, bitDev, minTimeMatches ] = asFindBitTime ( listDeltas, tol, [ownBitTime] )

    PARAMS: listDeltas     - a list of delta times, e.g. from asListDeltas()
            tol            - a tolerance ranging from 0 to 1, equaling 0 to 100%
            ownBitTime     - overrides the min( listDeltas ) calculation (see below)
            
    RETURN: bitTime        - the calculated bit time
            bitDev         - the standard deviation of all discovered bits
            minTimeMatches - number of matches found for bittime +- the tolerance given
    
  As for now, this function looks for the shortest time in listDeltas via
  
    minBT = min( listDeltas(2,:) )
    
  and then searches for every time difference, that matches the bit time +- the given tolerance and
  returns the mean values of all occurrences.  
  Because the automatically extracted minBT is already the shortest time, only the +tolerance counts
  here.
  
  The automatic "algorithm" [hahaha] fails, if only a single time, shorter than the bit time is found
  in the delta list. In this case, one might override the min() extraction by specifying "ownBitTime"
  as a third argument in the call to asFindBitTime().
    
    EXAMPLES:
            bTime = asFindBitTime( listDeltas, 0.3 );
            ...


#### asFindSamplesByTime()

  Finds indices of samples by time.  
  For a given sample time ts, a signal only contains discrete time-value samples at n*ts.
  This functions searches the nearest, lowest sample position that matches the given time sTim.

    sNum = asFindSamplesByTime( signal, sTim, [bitRate] )

    PARAMS: signal  - a signal or a list of signals in which the sample should be found
            sTim    - time of the sample position to find
                      can be a single time or an array of times, regardless of its dimension.
            bitRate - If given and > 0, a direct calculation is returned, regardless of the signals's
                      length or existance: sample = sTim*bitRate.
                      If given, but 0, the first two samples of the signals will be used to
                      calculate the bitRate and then return: sample = sTim* 1/(2ndSamp-1stSamp)
    RETURN: sNum    - number (index) of the sample which corresponds to the time sTim.
                      0 if nothing could be found.

  WARNING:  
  Using this without specifying the bitRate, either the real value, e.g. 44100 or 0, will take
  a very long time (yet)!
    
    EXAMPLES:
            sNum = asFindSamplesByTime( sig1, 0.45 )       % poor performance
            sNum = asFindSamplesByTime( sig2, 1.0, 0 )     % quick with auto bitrate calc
            sNum = asFindSamplesByTime( sig2, 1.0, 44100 ) % quick with given bitrate
            sNum = asFindSamplesByTime( sig, [1,2,3], 0 ); % multiple values are possible

    
#### asSignalSplit()

  Splits a signal with several packets into multiple, smaller signals, containing only the
  areas of interest.  
  All split signals are returned in a cell of size {1,n}, where n is the number of signals
  specified via listPackets. This list with packet start and end times can be obtained with
  the asListPackets...() functions.

    sigCell = asSignalSplit( signal, listPackets )
    
    PARAMS: signal      - the signal to split
            listPackets - a two-dimensional list of [ startTime, endTime ] values to split the signal.
    
    RETURN: sigCell   - an Octave cell of size {1,n}, containing n signals with [ time, value ] pairs.
    
    EXAMPLES:
            sig = asLoadWav("MySignal.wav");                % load a signal
            lPeaks = asListPeaks( sig, 0.2);                % extract a peak list
            lDeltas = asListDeltas( lPeaks );               % create a list of delta times
            lPacks = asListPacketsByDeltas( lDeltas, 2.1 ); % create a packet list
            sigCell = asSignalSplit( sig, lPacks );         % split the signals into smaller parts

  If startTime and endTime are equal, the "packet", actually only a single pulse, will be omitted.

  Notice that the signals in the cell will have different lengths. To unify them, e.g. for plotting
  or comparing them directly, use asSignalUnifyCell().
    
    
#### asSignalUnifyCell()

  Octave can't directly plot multiple signals which have a different length (dimensions).  
  This function extends all signals in sigCell to match the longest one by repeating the last
  sampled value.

    sigCellUnified = asSignalUnifyCell( sigCell )

    PARAMS: sigCell        - a cell with n signals of size {1,n}
    
    RETURN: sigCellUnified - returns a cell with all signals extended to match the longest signal
    
    EXAMPLES:
            cellNew = asSignalUnifyCell( sigCell );


#### asSignalBlend()

  Creates a new signal blend from a weighted mean of two signals.  
  Useful for creating dynamic threshold levels.
  
    sigBlend = asSignalBlend( signal1, signal2, blendFac )
    
    PARAMS: signal1  - first signal
            signal2  - second signal
            lendFac  - value 0..1; percentage/distribution of sigLo to sigHi
                       0   - fully signal1
                       1   - fully signal2
                       0.3 - 70% of signal1, 30% signal2
                       0.5 - 50% of both (half)

    RETURN: sigBlend - two dimensional signal of [ time, value ]
    

---
## Examples


### Load and display a signal

### Snipping signals packets

### Comparing signals packets


---
[1]: http://en.wikipedia.org/wiki/Butterworth_filter
