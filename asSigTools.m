%
%  asSigTools for Octave
% =======================
%
%   https://github.com/FMMT666/433M83Octave
%   FMMT666(ASkr)
%
%
% CHANGES V02:
%  - swapped row 2 and 3 of listPeaks
%    It's now more compatible to all other signals, that have
%    1 -> time and 2 -> y (was peak length before)
%
% CHANGES V03:
%  - asPlot() now accepts a cell of signals as argument
%
% CHANGES V04:
%  - I obviously managed to delete most of the code I wrote during the
%    last 6..7 months :-/
%
% CHANGES Vxy:
%  - see Github
%
%
% TODO:
%  - bit-window-time detection
%  - optional length for asSignalUnifyCell(); (snip or extend)
%  - check if signal split function can use an additional length (wat???)
%  - rewrite all the missing stuff AGAIN *raaage*
%  - function to return a length in seconds
%  - signal to signal-cell function (if not already present)
%  - low/mid/high signal follower
%  - bit times counter (preambles, etc...)
%


%*****************************************************************************
%*** asWork
%*****************************************************************************
function asWork( )

  wavName = "signals/433M83_02.wav";
  
  sig = asLoadWav( wavName );
  listPeaks = asListPeaks( sig, 0.2 );
  listDeltas = asListDeltas( listPeaks );
  listPack = asListPacketsByDeltas( listDeltas, 0.025 );

  sigCell = asSignalSplit( sig, listPack );
  sigCellU = asSignalUnifyCell( sigCell );
  sigCellS = asSignalStackCell( sigCellU );

  figure( 1 );
  asPlot( sigCellS, 'linewidth', 2 );

  for i = 1:size( sigCellU, 2 );

    s1  = sigCellU{ i };
    lp1 = asListPeaks( s1, 0.2 );
    ld1 = asListDeltas( lp1 );

%    figure( 2 );
%    asPlot( s1 );
%    figure( 3 );
%    asPlot( ld1 );

    lpck1 = asListPacketsByDeltas( ld1, 0.008 );
    
    s1c  = asSignalSplit( s1, lpck1 );
    s1cu = asSignalUnifyCell( s1c );
    s1cs = asSignalStackCell( s1cu );

    figure( 2 + i-1 );
    asPlot( s1cs, 'linewidth', 2 );

  end
  
endfunction


%*****************************************************************************
%*** asDemo1
%*****************************************************************************
%function asDemo1( wavName )
function asDemo1( )

  % override wav name for a demo
  wavName = "signals/433M83_02.wav";

  % load the signal from disk
  [ sigOrg, sigRate ] = asLoadWav( wavName );

  % create base line via heavy low pass fitlering
  sigBase = asFilterLowPass( sigOrg, 50, 2 );

  % create a nicer, low pass filtered signal
  sigFilt = asFilterLowPass( sigOrg, 2000, 2 );

  % plot all three signals
  figure( 1 );
  asPlot( sigOrg, sigBase, sigFilt, 'linewidth', 2 );

  % create a list of peaks (absolute trigger level)
  listPeaks = asListPeaks( sigFilt, 0.2 );
  
  % create a list of times between the peaks
  listDeltas = asListDeltas( listPeaks );
  
  % try to estimate the bit time
  [ bitTime, bitDev ] = asFindBitTime( listDeltas, 0.3 );
  
  % isolate multiple packets by time (two peaks > 0.025s)
  [ listPack, listDeltasShort ] = asListPacketsByDeltas( listDeltas, 0.025 );

  % plot a line for the peaks
  asLinePoly( listPeaks(1:2,:), 'green' );  
  
  % plot a line for the times
  asLinePoly( listDeltasShort, 'black' );

  % create a new waveform "plotDS" from 1st arg and shift it under "sigOrg"
  [ plotDS, plotOffs ] = asSignalStack( listDeltasShort, sigOrg );
  asLinePoly( plotDS );
  
  % create indices of the packet start and end samples from the time list
  listPackSams = asFindSamplesByTime( sigFilt, listPack, 0 );

  % create a signal cell with signal split into multiple packets
  sigCell = asSignalSplit( sigFilt, listPack );
  
  % unify the length of the signals in the cell for plotting
  sigCellU = asSignalUnifyCell( sigCell );
  
  % stack all signals from the unified signal cell
  sigCellS = asSignalStackCell( sigCellU );

  % and plot it
  figure( 2 );
  asPlot( sigCellS, 'linewidth', 2 );
  
endfunction



%*****************************************************************************
%*** asSignalStackCell( cellSignal )
%*** Creates a new signal cell with each of the signals
%*** shifted under the previous one.
%*** Useful for comparing waveforms in a plot.
%*****************************************************************************
function newCell = asSignalStackCell( cellSignal )

	newCell = cellSignal;
	
	n = size( cellSignal, 2 );
	
	if n > 1
		for i = 1:n-1
			[ newCell{i+1}, dummy ] = asSignalStack( newCell{i+1}, newCell{i} );
		end
	end

endfunction



%*****************************************************************************
%*** asSignalUnifyCell( signalCell )
%*** Fed with a cell array of signals, all of them will be extended to the
%*** size of the largest one.
%*****************************************************************************
function sigCellNew = asSignalUnifyCell( sigCell )
  
  sigCellNew = {};

  n = size( sigCell, 2 );

  if n < 2
    return
  end
  
  % find the largest signal
  maxLen = 0;
  maxID  = 0;
  for i = 1:n
    if size( sigCell{i}(1,:), 2 ) > maxLen
      maxLen = size( sigCell{i}(1,:), 2 );
      maxID  = i;
    end
  end

  % unify all signals
  for i = 1:n

    % TODO: don't create empty signals in a cell
  
    sigCellNew{i} = sigCell{i};

    endMark = size( sigCellNew{i}(1,:), 2 );
    if endMark < maxLen
      sigCellNew{i}(2, endMark:maxLen) = 0;
      sigCellNew{i}(1,:) = sigCell{maxID}(1,:) - sigCell{maxID}(1,1);
    end
  
  end

endfunction


%*****************************************************************************
%*** asSignalSplit( signal, splitList )
%*** Extracts a part of a longer signal.
%*** sampleStartEnd is an ( n , 2 ) array
%*** (n,1) sampleStart, (n,2) sampleEnd
%*** This returns a cell array!
%*****************************************************************************
function sigCell = asSignalSplit( signal, splitList )

  sigCell = {};

  % do not create empty signal in the signal cell if start- and stop-times
  % are equal
  sI = 0; 

  for i = 1 : size( splitList, 1 )
    
    sampleStart = asFindSamplesByTime( signal, splitList(i,1), 0 );
    sampleEnd   = asFindSamplesByTime( signal, splitList(i,2), 0 );

    if sampleEnd == sampleStart
      sI++;
    else
    
      if sampleStart > 0 && sampleStart < sampleEnd && sampleEnd <= size(signal(1,:),2)
        sigCell{i - sI} = signal(:, sampleStart:sampleEnd );
      else
        sigCell{i - sI} = [];
      end
    end
  
  end

endfunction



%*****************************************************************************
%*** asLinePoly( signal, [color], [linewidth] )
%*** asLinePoly( xs, ys, [color], [linewidth] )
%*** Draws polylines in the current plot (time-value pairs).
%*****************************************************************************
function asLinePoly( varargin )

  dThick = 2;
  dColor = 'red';
  
  if size( varargin{1}, 1 ) == 2
    xs = varargin{1}(1,:);
    ys = varargin{1}(2,:);
    parOffset = 1;
  else
    xs = varargin{1};
    ys = varargin{2};
    parOffset = 2;
  end
  
  if length( varargin ) > parOffset + 0
    dColor = varargin{ parOffset + 1 };
  end
  
  if length( varargin ) > parOffset + 1
    dThick = varargin{ parOffset + 2 };
  end

  line( xs, ys, 'linewidth', dThick, 'color', dColor );

endfunction




%*****************************************************************************
%*** asLineHoriz( signal, level )
%*** ...
%*****************************************************************************
function asLineHoriz( signal, level, varargin )

  dThick = 2;
  dColor = 'red';
  
  if length( varargin ) > 0
    dColor = varargin{1};
  end
  
  if length( varargin ) > 1
    dThick = varargin{2};
  end

  line( [ signal(1,1), max( signal(1,:) ) ], [ level, level ],
         'linewidth', dThick,
         'color', dColor );

endfunction



%*****************************************************************************
%*** asFindSamplesByTime( sTim, sTim, [bitRate] )
%*** Returns the number of the sample that matches the time given by <sTim>.
%*** If there's no direct match, the last sample with t < sTim is returned.
%*** If nothing usefule was found, this function returns 0.
%*** If bitRate > 0 is given, nothing is looked up but directly calculated.
%*** This also allows sTim being a complete packet list from
%*** asListPacketsByDeltas().
%*** If bitRate == 0 given, the sample rate is calculates by the time 
%*** difference of the first two samples.
%*****************************************************************************
function sNum = asFindSamplesByTime( signal, sTim, varargin )

  sNum = 0;

  % TESTING
  % consider an offset
  if signal(1,1) > 0
    sTim -= signal(1,1);
  end

  if length( varargin ) > 0
    % CALCULATE TIME (3rd arg)
    if varargin{1} > 1
      % sample rate was given
      sNum = 1 + sTim * varargin{1};
      if sNum > size( signal(1,:), 2 )
        sNum = 0;
      end
    else
      % calc sample rate from first two samples
      if length(signal) < 2
        sNum = 0;
      else
        sNum = 1 + sTim * 1 / ( signal(1,2)-signal(1,1) );
      end
    end
  else
    % SEARCH FOR TIME (no 3rd arg)
    for i = 1 : size( signal(1,:), 2 )
      
      val = signal(1,i);
      if val == sTim
        sNum = i;
        break;
      elseif val > sTim
        sNum = i - 1; 
        break;
      end
    end
  end
  sNum = uint64( sNum );
  
endfunction



%*****************************************************************************
%*** asListPacketsByDeltas
%*** Assuming that several packets have a long time between them,
%*** this function returns a list of "active areas", which are separated
%*** by a time longer than <timeNoPeak>.
%*** Returns: - (j,2) j number of packets, (j,1) start times (j,2) end times
%***          - a shortened deltaListShort with all long times removed
%*****************************************************************************
function [ actList, deltaListShort ] = asListPacketsByDeltas( deltaList, timeNoPeak )
	
  actList        = [];
  
  deltaListShort = deltaList;
  snipped        = 0;
  
  n  = size( deltaList( 1 , : ), 2 );
  
  pNr   = 1;   % number of current packet
  
  % Save the start time of the first packet.
  % deltaList was derived from a peakList, so this is always true.
  % TODO: maybe, but it fails if deltaList(1,2) > timeNoPeak; creates
  %       an empty packet in this case
  actList( pNr, 1 ) = deltaList( 1, 1 );

  for i = 1:n

    if i == n
      actList( pNr    , 2 ) = deltaList( 1, i ) + deltaList( 2, i );
      break;
    end
  
    if deltaList( 2, i ) > timeNoPeak
    
      deltaListShort( :, i - snipped ) = [];
      snipped = snipped + 1;
      
      actList( pNr    , 2 ) = deltaList( 1, i );
      actList( pNr + 1, 1 ) = deltaList( 1, i ) + deltaList( 2, i );
      pNr = pNr + 1;
    end
  
  end
 

endfunction



%*****************************************************************************
%*** asSignalStack
%*** Creates a new waveform of "data1" that plots under "data2".
%*****************************************************************************
function [ data, offset ] = asSignalStack( data1, data2 )
  offset = max( data1(2,:) ) - min( data2(2,:) );
  data(1,:) = data1(1,:);
  data(2,:) = data1(2,:) - offset;
endfunction




%*****************************************************************************
%*** asFindBitTime
%*** ...
%*****************************************************************************
function [ bitTime, bitDev, minTimeMatches ] = asFindBitTime ( listDeltas, tol, varargin )
  
  if length( varargin ) > 0 then
    ownBitTime = varargin{1};
  else
    ownBitTime = 0;
  end
  
  if ownBitTime > 0 then
    minTime = ownBitTime;
  else
    minTime = min( listDeltas(2,:) );
  end
  
  minTimeMatches = find( listDeltas(2,:) < (1 + tol) * minTime & listDeltas(2,:) > (1 - tol) * minTime );
  minTimes = listDeltas(2, minTimeMatches );
  
  bitTime = mean( minTimes );
  bitDev  = std( minTimes );
  
endfunction






%*****************************************************************************
%*** asPlot
%*** Just a time saver for less typing while experimenting.
%*** This function plots one or more signals, including any optional
%*** parameters (e.g. 'linewidth', etc...).
%*** It can be called with either one or multiple arguments, each containing
%*** a size(2,n) signal, or a cell, containing m * size(2,n) signals.
%*****************************************************************************
function asPlot( varargin )

	% we also support a cell as input argument now
	if iscell( varargin{1} )
		myargs = {};
		cellLen = size( varargin{1}, 2 );
		
		for i = 1:cellLen
			myargs{i} = varargin{1}{i};
		end	
		
		for i = 2:size( varargin, 2 )
			myargs{ cellLen + i - 1 } = varargin{ i };
		end
		
	else
		myargs = varargin;
	end

  % no matter what else is in the VARARGIN, the first one MUST
  % be a waveform, so we can extract the time variable, as well as
  % the first array to print.
  t        = myargs{1}(1,:);
  dat(1,:) = myargs{1}(2,:);

  oArg     = {};
  oInd     = 1;

  % walk through the rest of the list
  for i = 2 : size( myargs, 2 );

    if size( myargs{i}, 1 ) > 1
      % if it has more than 1 dimension, assume it's a waveform
      dat(i,:) = myargs{i}(2,:);
    else
      % if it obly hase one dim, it's a parameter
      oArg{oInd} = myargs{i};
      oInd = oInd + 1;      
    end
    
  end

  plot( t, dat, oArg{:} );

endfunction



%*****************************************************************************
%*** asLoadWav
%*** ...
%*****************************************************************************
function [ signal, sampleRate ] = asLoadWav( fileName )
  
  [ wdat, srate ] = wavread( fileName );
  
  sampleRate = srate;

  % Octave has the array sorted reverse
  wdat = wdat';
 
  if size( wdat, 1 ) > 1
    disp("NOT A MONO FILE");
    exit;
  end

  t = 0:size( wdat, 2 ) - 1;
  t = t / sampleRate;

  signal = [ t; wdat ];
  
endfunction



%*****************************************************************************
%*** asFilterLowPass
%*** Applies a low pass filter to the signal.
%*****************************************************************************
function sigFilt = asFilterLowPass( sigDat, lpFreq, lpOrder )
  
  wavRate = 1 / sigDat(1,2);
 
  [ b, a ] = butter( lpOrder, lpFreq / wavRate );
  sigFilt = [ sigDat(1,:) ; filter( b, a, sigDat(2,:)) ];
  
endfunction



%*****************************************************************************
%*** asListPeaks
%*** Returns an array of peaks from a 2 dimensional input array [ time; value ],
%*** of size(2,n) that exceed the level specified by "trigger".
%*** tPL = [ time; length; peakval; peaktime ] of size( 4, number_of_peaks )
%*****************************************************************************
function tPL = asListPeaks( samples, trigger )

  if size( samples, 1 ) ~= 2 then
    error("FindPeaks() requires an array of size(2,n)");
    tPL = [];
    return;
  end

  n = size( samples,2 );

  peakNr    = 0;
  peakFound = 0;
  minVal    = min( samples(2,:) ) - 1;
  peakVal   = minVal;
  minTime   = min( samples(1,:) ) - 1;
  peakTime  = minTime;


  for i = 1:n
    
    % check if the value exceeds the trigger level
    if peakFound == 0
      if samples( 2, i ) > trigger
        peakFound = 1;
        peakVal   = minVal;
        peakTime  = minTime;
        peakNr    = peakNr + 1;
        tPL( 1, peakNr ) = samples( 1, i ); % save start time
      end

    else
      % save new max value
      if samples( 2, i ) > peakVal
        peakVal  = samples( 2, i );
        peakTime = samples( 1, i );
      end

      % check if we're going down
      if samples( 2, i ) < trigger
        peakFound = 0;
        tPL( 2, peakNr ) = peakVal;
        tPL( 3, peakNr ) = samples( 1, i ) - tPL( 1, peakNr ); % save length
        tPL( 4, peakNr ) = peakTime;
      end
      
    end
    
  end %END for
  
  % UNTESTED UNTESTED UNTESTED
  % What the heck did I plan here?
%  if peakFound == 1 
%    if peakNr > 1 
%      tPL = resize_matrix( 4, peakNr -1 );
%    else
%      tPL = [];
%    end
%  end
%    
endfunction



%*****************************************************************************
%*** asListPeaksCell
%*** Repetively calls asListPeaks() with each signal from a signal cell
%*****************************************************************************
function cellPeaks = asListPeaksCell( sigCell, trigger )

  cellPeaks = {};

  for n = 1:size( sigCell, 2 );
    cellPeaks{n} = asListPeaks( sigCell{n}, trigger );
  end

endfunction



%*****************************************************************************
%*** asListDeltas
%*** ...
%*****************************************************************************
function listDeltas = asListDeltas( listPeaks )
  for i = 1:size( listPeaks, 2 ) - 1
    listDeltas(1,i) = listPeaks( 1, i );
    listDeltas(2,i) = listPeaks( 1, i+1 ) - listPeaks( 1, i );
  end
endfunction



%*****************************************************************************
%*** asListDeltasCell
%*** Repetively calls asListDeltas() with each signal from a signal cell
%*****************************************************************************
function cellDeltas = asListDeltasCell( listPeaks )

  cellDeltas = {};

  for n = 1:size( listPeaks, 2 );
    cellDeltas{n} = asListDeltas( listPeaks{n} );
  end

endfunction
          


%*****************************************************************************
%*** asSignalFollowMinMax
%*** Creates a new signal that tries to follow the minimum or maximum
%*** peaks of a signal, depending on the sign and value of <fallOff>
%*** TODO:
%***  - fallOff == zero
%***  - better starting procedure
%*****************************************************************************
function sFo = asSignalFollowMinMax( sig, fallOff, varargin )

  sFo = [];
  sFo(1,:) = sig(1,:);

  % set follow value to start of signal (for now)
  mmval = sig(2,1);

	% to increase the speed, even though this doubles the for loop...
  if fallOff < 0
    % --- follow min
	  for i=1:length( sig )
      if sig(2,i) < mmval
        mmval = sig(2,i);
      else
        mmval -= fallOff;
      end % END signal greater than follow value
      sFo(2,i) = mmval;
	  end % END for
	
  else
    % --- follow max
	  for i=1:length( sig )
      if sig(2,i) > mmval
        mmval = sig(2,i);
      else
        mmval -= fallOff;
      end % END signal greater than follow value
      sFo(2,i) = mmval;
	  end % END for

  end % END else fallOff
	
endfunction


%*****************************************************************************
%*** asSignalBlend
%*** Creates a new signal from a linear value interpolation of two others.
%*** The blendFac (0..1) decides which point to pick:
%***   0   - sigLow  100% 
%***   0.3 - sigLow   70%, sigHigh 30%
%***   1   - sigHigh 100%
%*****************************************************************************
function sBlend = asSignalBlend( sigLow, sigHigh, blendFac )

  % TODO: samity checks (size of signals, etc...)
  
  sBlend = [];
  sBlend(1,:) = sig1(1,:);

  % where's my code???

endfunction

