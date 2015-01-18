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
%  - forgot
%
%
% TODO:
%  - Doxygen documentation (in/out of functions below)
%  - check if signal split function can use an additional length
%  -
%
%
% PLOTTING 
%
%   asPlot( signal, [signal/option], ... )
%   asLineHoriz( signal, level, [color], [linewidth] )
%   asLinePoly( signal, [color], [linewidth] )
%   asLinePoly( xs, ys, [color], [linewidth] )
%
%
% WAV FILES
%
%   asLoadWav( fileName )
%
%
% SIGNAL MATH
%
%   asFilterLowPass( signal, frequency, order )
%   asListPeaks( signal, triggerLevel  )
%   asListDeltas( peakList )
%   asListPackets( deltaList, timeNoPeak )
%   asFindBitTime( deltaList, tolerancePercent, [ownBitLength] )
%   asFindSamplesByTime( signal, sTim, [varargin] )
%   asSignalSplit( signal, sampleStartEnd )
%   asSignalUnify( sigCell )
%   asSignalShiftUnder( signal1, signal2 )
%   asSignalStack( sigCell )
%
% OTHER
%
%   asTest( fileName )
% 
%


%*****************************************************************************
%*** asTest
%*****************************************************************************
function asTest( wavName )

  % load the signal from disk
  [ sigOrg, sigRate ] = asLoadWav( wavName );

  % create base line via heavy low pass fitlering
  sigBase = asFilterLowPass( sigOrg, 50, 2 );

  % create a nicer, low pass filtered signal
  sigFilt = asFilterLowPass( sigOrg, 2000, 2 );

  % plot all three signals
  asPlot( sigOrg, sigBase, sigFilt, 'linewidth', 2 );

  % create a list of peaks (absolute trigger level)
  listPeaks = asListPeaks( sigFilt, 0.2 );
  
  % create a list of times between the peaks
  listDeltas = asListDeltas( listPeaks );
  
  % try to estimate the bit time
  [ bitTime, bitDev ] = asFindBitTime( listDeltas, 0.3 );
  
  % isolate multiple packets by time (two peaks > 0.025s)
  [ listPack, listDeltasShort ] = asListPackets( listDeltas, 0.025 );

  % plot a line for the peaks
  asLinePoly( listPeaks(1:2,:), 'green' );  
  
  % plot a line for the times
  asLinePoly( listDeltasShort, 'black' );

  % create a new waveform "plotDS" from 1st arg and shift it under "sigOrg"
  [ plotOffs, plotDS ] = asSignalShiftUnder( listDeltasShort, sigOrg );
  asLinePoly( plotDS );
  
  % create indices of the packet start and end samples from the time list
  listPackSams = asFindSamplesByTime( sigFilt, listPack, 44100 );

endfunction



%*****************************************************************************
%*** asSignalStack( cellSignal )
%*** Creates a new signal cell with each of the signals
%*** shifted under the previous one.
%*** Useful for comparing waveforms in a plot.
%*****************************************************************************
function newCell = asSignalStack( cellSignal )

	newCell = cellSignal;
	
	n = size( cellSignal, 2 );
	
	if n > 1
		for i = 1:n-1
			[ dummy, newCell{i+1} ] = asSignalShiftUnder( newCell{i+1}, newCell{i} );
		end
	end

endfunction



%*****************************************************************************
%*** asSignalUnify( signal, splitList )
%*** Fed with a cell array of signals, all of them will be extended to the
%*** size of the largest one.
%*****************************************************************************
function sigCellNew = asSignalUnify( sigCell )
  
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
%*** Extracts a part of signal.
%*** sampleStartEnd is an ( n , 2 ) array
%*** (n,1) sampleStart, (n,2) sampleEnd
%*** WARNING: This returns a cell array!
%*****************************************************************************
function sigCell = asSignalSplit( signal, splitList )

  sigCell = {};

  for i = 1 : size( splitList, 1 )
  
    sampleStart = splitList(i,1);
    sampleEnd   = splitList(i,2);
    
    if sampleStart > 0 && sampleStart < sampleEnd && sampleEnd <= size(signal(1,:),2)
      sigCell{i} = signal(:, sampleStart:sampleEnd );
    else
      sigCell{i} = [];
    end
  
  end

endfunction



%*****************************************************************************
%*** asLinePoly( signal, [color], [linewidth] )
%*** asLinePoly( xs, ys, [color], [linewidth] )
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
%*** If bitRate is given, nothing is looked up but directly calculated.
%*** This also allows sTim being a complete packet list from
%*** asListPackets()
%*****************************************************************************
function sNum = asFindSamplesByTime( signal, sTim, varargin )

  sNum = 0;

  if length( varargin ) > 0
    % CALCULATE TIME

    if varargin{1} > 1
      sNum = 1 + sTim * varargin{1};
      if sNum > size( signal(1,:), 2 )
        sNum = 0;
      end
    end
  
  else
    % SEARCH FOR TIME
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
%*** asListPackets
%*** Assuming that several packets have a long time between them,
%*** this function returns a list of "active areas", which are separated
%*** by a time longer than <timeNoPeak>.
%*** Returns: - (j,2) j number of packets, (j,1) start times (j,2) end times
%***          - a shortened deltaListShort with all long times removed
%*****************************************************************************
function [ actList, deltaListShort ] = asListPackets( deltaList, timeNoPeak )
	
  actList        = [];
  
  deltaListShort = deltaList;
  snipped        = 0;
  
  n  = size( deltaList( 1 , : ), 2 );
  
  pNr   = 1;   % number of current packet
  
  % Save the start time of the first packet.
  % deltaList was derived from a peakList, so this is always true.
  actList( pNr, 1 ) = deltaList( 1, 1 );

  lastOne = 0;

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
%*** asSignalShiftUnder
%*** Creates a new waveform of "data1" that plots under "data2"
%*****************************************************************************
function [ offset, data ] = asSignalShiftUnder( data1, data2 )
  offset = max( data1(2,:) ) - min( data2(2,:) );
  data(1,:) = data1(1,:);
  data(2,:) = data1(2,:) - offset;
endfunction




%*****************************************************************************
%*** asFindBitTime
%*****************************************************************************
function [ bitTime, bitDev, minTimeMatches ] = asFindBitTime ( listDeltas, tol, varargin )
  
  % TODO: A little bit strange indeed...
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
%*** asListDeltas
%*****************************************************************************
function listDeltas = asListDeltas ( listPeaks )
  for i = 1:size( listPeaks, 2 ) - 1
    listDeltas(1,i) = listPeaks( 1, i );
    listDeltas(2,i) = listPeaks( 1, i+1 ) - listPeaks( 1, i );
  end
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
function tPL = asListPeaks( samples, trigger  )

  % from the old file, which used precent
  % tmpTrigger = mean(sBas) + ( trigLevel * ( max(sSig(2,:)) - mean(sBas) ) )

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
%  if peakFound == 1 
%    if peakNr > 1 
%      tPL = resize_matrix( 4, peakNr -1 );
%    else
%      tPL = [];
%    end
%  end
%    
endfunction


