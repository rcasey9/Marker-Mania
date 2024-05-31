function markerData = GapFill(markerData, modelFile, varargin)
% GapFill  Gap-fills marker data using osimModel to determine segments
% markerData = GapFill(markerData, osimModel, varargin)
%   In:
%       markerData - struct of marker data, such as one generated by
%         Vicon.ExtractMarkers
%       modelFile - a scaled .osim model of a .vsk file of the subject used
%                   to determine segments
%                   
%   Optional Inputs:
%       GapTable - Gap fill only the gaps in the table (use
%       Vicon.genGapTable to make the table).
%       Verbose - 0 (minimal, default), 1 (normal), 2 (debug mode)
%       EnableShort  - (true)/false , enable filling of short gaps
%       EnableLong   - (true)/false , enable filling of long gaps
%       ShortGap - (3) max lenght of what is considered a short gap

%   Out:
%       markerData - struct of filled marker data
%
%   See also: Vicon.GapMake, Vicon.IterativeGapFilling.


p = inputParser;
p.addOptional('GapTable',{},@istable);
p.addParameter('Verbose',0);
p.addParameter('EnableShort',true);
p.addParameter('EnableLong',true);
p.addParameter('ShortGap',5);
p.parse(varargin{:});

gapTable = p.Results.GapTable;

Verbose = p.Results.Verbose;
SHORTGAP=p.Results.ShortGap; % MAX length of a shortgap (Filled with splinefill)
EnableShort=p.Results.EnableShort;
EnableLong=p.Results.EnableLong;

markers = fieldnames(markerData);

noModelFill=false;
if endsWith(modelFile, '.osim')
    segments = Osim.model.getSegmentMarkers(modelFile);
elseif endsWith(modelFile, '.vsk')
    segments = Vicon.model.getSegmentMarkers(modelFile);
elseif strcmp(modelFile,'') % To attempt fill without using any model information
    noModelFill=true;
else
    error('Could not identify segment information from osim model.');
end

if ~noModelFill
    [~, valid_marker, ~] = intersect(fieldnames(markerData),fieldnames(segments));
    % remove markers in markerData which are not attached to a segment
    otherMarkers = rmfield(markerData,markers(valid_marker));
    markerData = rmfield(markerData, setdiff(markers, markers(valid_marker)));

    % remove references to markers with no data (medials) from segments struct
    markersWithNoData = setdiff(fieldnames(segments), fieldnames(markerData));
    for idx = 1:length(markersWithNoData)
        marker = markersWithNoData{idx};
        seg = segments.(marker);
        if ischar(seg)
            segments.(seg) = setdiff(segments.(seg), marker);
        end
    end
else
    otherMarkers=struct();
end

isGapTableArg=true;
if isempty(gapTable)
    gapTable=Vicon.genGapTable(markerData);
    isGapTableArg=false;
end

%%

if height(gapTable) == 0
    markerData=Topics.merge(markerData,otherMarkers);
    warning('No gaps in markerdata. Are you sure you need to run gapfill?')
else
    
    change = true;
    if height(gapTable) == 0
        change = false;
    end
    
    rbFills = 0;
    ptFills = 0;
    shortSpFills = 0;
    spFills = 0;
    %h = progress(0);
    idx = 1;

    if EnableShort
        % spline fill +really short gaps
        gapTableChanged=true;
        tempShortSpFills=0;
        while (true)
            idx=1;
            while (idx<=height(gapTable) && gapTable.Length(idx) <= SHORTGAP )
                marker=gapTable.Markers{idx};
                if ~isfield(markerData,marker)
                    idx=idx+1;
                    continue;
                end
                [markerData,err] = Vicon.SplineFill(markerData, gapTable.Markers{idx}, gapTable.Start(idx), gapTable.End(idx));
                if ~err
                    shortSpFills = shortSpFills + 1;
                end
                idx = idx + 1;            
                %progress(idx/sum(gapTable.Length == 1), h)                                                            
            end             
            gapTable=UpdateGapTable(markerData,gapTable,isGapTableArg);
            if (shortSpFills==tempShortSpFills)                
                break;
            end
            tempShortSpFills=shortSpFills;            
         end
    end
    
   gapTable=UpdateGapTable(markerData,gapTable,isGapTableArg);
    
    if EnableLong
        while change
            while change
                change = false;
                %h = progress(0);
                for i = 1:height(gapTable)
                    gap = [gapTable.Start(i) gapTable.End(i)];
                    markerName = gapTable.Markers{i};
                    donors = segments.(segments.(markerName));
                    donors = setdiff(donors, markerName); % remove the marker from the donor list
                    try
                        markerData = Vicon.RigidBodyFill(markerData, markerName, donors, gap(1), gap(2));
                        rbFills = rbFills + 1;
                        change = true;
                    catch E
                        if ~startsWith(E.identifier, 'GapFill:')
                            rethrow(E);
                        end
                        try
                            markerData = Vicon.PatternFill(markerData, markerName, donors, gap(1), gap(2));
                            ptFills = ptFills + 1;
                            change = true;
                        catch E
                            if ~startsWith(E.identifier, 'GapFill:')
                                rethrow(E);
                            end
                        end
                    end
                    %progress(i/height(gapTable), h);
                end
            gapTable=UpdateGapTable(markerData,gapTable,isGapTableArg);

    
            end

            if height(gapTable) == 0
                change = false;
            else
                if Verbose > 0
                    if gapTable.Length(1) > 10
                        warning('Spline-filling Large gap');
                    end
                end
                markerData = Vicon.SplineFill(markerData, gapTable.Markers{1}, gapTable.Start(1), gapTable.End(1),'MaxError',inf);
                spFills = spFills + 1;
                gapTable=UpdateGapTable(markerData,gapTable,isGapTableArg);

                change = true;
            end
        end
    end
        
    markerData=Topics.merge(markerData,otherMarkers);
    
    %delete(h);
    if Verbose > 0
        fprintf(['   %d gaps filled with rigid body fill.\n' ...
            '   %d gaps filled with pattern fill.\n' ...
            '   %d gaps filled with spline fill.\n' ...
            '   %d short gaps (len<%d) filled with spline fill.\n'], rbFills, ptFills, spFills, shortSpFills,SHORTGAP);
    else
        fprintf('   %d gaps filled\n', rbFills + ptFills + spFills + shortSpFills);
    end
end
end

function updatedGapTable=UpdateGapTable(markerData,originalGapTable,isGapTableArg)
    gapTable=originalGapTable;
    if isGapTableArg
                gapTable2 = Vicon.genGapTable(markerData);
                if ~isempty(gapTable2)
                    gapTable = intersect(gapTable,gapTable2);
                else
                    gapTable=gapTable2;
                end
            else
                gapTable = Vicon.genGapTable(markerData);
    end
    updatedGapTable=gapTable;
end