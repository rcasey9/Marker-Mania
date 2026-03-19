function Gap_Fill_LC(markerSet,filename,path)
staticFiles = dir(fullfile(path,'*Static*.c3d'));
staticFile = staticFiles(1);
staticFile = staticFile.name;


staticFile = [path '\' staticFile];
staticStruct = Vicon.ExtractMarkers(staticFile);

clusterNames = fieldnames(markerSet);
%extract list of all markers
markerNum = 1;
markerList = {};
clusters = {};
for cl = 1:length(clusterNames)
    markers = fieldnames(markerSet.(clusterNames{cl}));
    clusterMarkers = {};
    for mm = 1:length(markers)
        
        if ~ismember(markers{mm},markerList)
            
            
            markerList{markerNum} = markers{mm};
            markerNum = markerNum +1;
            
        end
        clusterMarkers{mm} =  markers{mm};
    end
    clusters{cl} = clusterMarkers;
end

if ~contains(filename,'static') & ~contains(filename,'Static') & ~contains(filename,'STATIC')
if ~contains(filename,'fjc') & ~contains(filename,'Fjc') & ~contains(filename,'FJC')
  % check for missing markers first and last frame  
  c3dFile = [filename '.c3d'];

                    markerStruct = Vicon.ExtractMarkers(c3dFile);

                    % Loop through all markers
                    markerStruct = checkForAbsentMarkers(markerList,markerSet,markerStruct,staticStruct);              

                    markerStruct = Find_Missing_First_And_Last_Frames(markerList, markerStruct);

                    % Rigid body fill
                    markerStruct = Rigid_Body_Fill_All_Gaps(markerList, markerStruct, clusters,true);
                   
                    % Fill missing first/last and final rigid body fill
                    
                    markerStruct = Rigid_Body_Fill_All_Gaps(markerList, markerStruct, clusters,true);
                    markerStruct = Rigid_Body_Fill_All_Gaps(markerList, markerStruct, clusters,true);
                    markerStruct = Rigid_Body_Fill_All_Gaps(markerList, markerStruct, clusters,true);

                    % Check for jumping markers
                    checkForJumpingMarkers(markerList,markerStruct,30)

                    % Check for missing markers (should all be filled)
                    checkForMissingMarkers(markerStruct, markerList)
                    
                    
                    % Save data
                   
                        %disp('    Writing new C3D file...')
                        filledC3D = ([filename,'_filled.c3d']);
                        Vicon.markerstoC3D(markerStruct, c3dFile, filledC3D);
                        pause(5)
                  

end
end
end

%% FUNCTIONS

function markerStruct = Rigid_Body_Fill_All_Gaps(allMarkerNames, markerStruct, clusters, allowNonRigidFill, varargin)
%RIGID BODY FILL ALL GAPS
%   This uses Jonathan's toolbox to do the rigid body gap filling for
%   markers.  The only additional functionality that this function adds is
%   it iterates through all markers in a data set and fills everything that
%   it is able to.  This relies on a cell containing each rigid body
%   segment.  The markers defined in this cluster will be used to fill the
%   other gaps in the segment markers.

lengthVarargin = length(varargin);
if lengthVarargin == 1
    if contains(varargin{1},'plot')
        plotResults = 1;
    else
        error('Did not enter correct varargin')
    end
else
    plotResults = 0;
end


% FILL GAPS

missingFrames = Vicon.findGaps(markerStruct); % find all missing frames in data
for mm = 1:length(allMarkerNames) % loop through all markers
    currentMarker = allMarkerNames{mm}; % define current marker
    if isempty(missingFrames.(currentMarker)) == 0 % if there are missing markers
        
        %Find other markers to drive the fix
        for ii = 1:length(clusters) % look at all of the defined clusters
            if any(strcmp(clusters{ii},currentMarker)) % if the cluster contains the marker that we're currently looking at
                currentCluster = clusters{ii}; % keep that cluster
                idx = strcmp(currentCluster,currentMarker); % find where current marker is in cluster
                currentCluster(idx) = []; % delete current marker from cluster
                
                % May need to add functionality if there aren't enough
                % markers in the cluster
            end
        end
        
        [a,~] = size(missingFrames.(currentMarker)); % define the number of gaps
        
        for ii = 1:a
            startFrame = missingFrames.(currentMarker)(ii,1); % start frame of gap
            endFrame = missingFrames.(currentMarker)(ii,2); % end frame of gap
            try
                markerStruct = Vicon.RigidBodyFill(markerStruct, currentMarker, currentCluster, startFrame, endFrame);
                % fill the gap
            catch
                if allowNonRigidFill
            %warning(['Not enough donors to rigid body fill for ' currentMarker ' at frames ' num2str(startFrame) ' through ' num2str(endFrame) '. Spline filling Instead.' ])
            try
            markerStruct = Vicon.SplineFill(markerStruct, currentMarker, currentCluster, startFrame, endFrame);
            
            catch
                try
            %warning(['Not enough donors to spline fill for ' currentMarker ' at frames ' num2str(startFrame) ' through ' num2str(endFrame) '. Pattern filling Instead.' ])
            markerStruct = Vicon.PatternFill(markerStruct, currentMarker, currentCluster, startFrame, endFrame);
            
                catch
            markerStruct = nanFill(markerStruct, currentMarker, startFrame, endFrame);          

                end


           
            end
                else
                    continue
                end
            end
        end
        
        if plotResults == 1
            plot(markerStruct.(currentMarker).Header, markerStruct.(currentMarker).x, 'k-')
            title(currentMarker)
            xlabel('Windows')
            ylabel('Position (m)')
            legend('original points', 'filled')
        end
     end
end
end


function checkForJumpingMarkers(markerSet,markerStruct,jumpThreshold)

for mm = 1:length(markerSet) % loop through marker set
    currentMarker = markerSet{mm};
    data = [markerStruct.(currentMarker).x, markerStruct.(currentMarker).y, markerStruct.(currentMarker).z];
    dataNext = data(2:end,:);
    data = data(1:end-1,:);
    markerIncrements = (sum((dataNext-data).^2,2)).^0.5; % distance between marker frames
    if sum(markerIncrements>jumpThreshold)>0 % if there is a marker jump
        loc = find(markerIncrements>jumpThreshold);
        %disp(['    MARKER JUMP: ',currentMarker,' starting at frame: ', num2str(loc')])
    end
end

end

% -------------------------------------------------------------------------

function markerStruct = Find_Missing_First_And_Last_Frames(allMarkerNames, markerStruct, varargin)
% FILL THE FIRST AND LAST FRAMES IN A C3D FILE
%   C3D files may contain marker trajectories that have the first and last
%   data points missing due to the inability of Vicon to deal with missing
%   edge trajectories.  This function uses absolute orientation (Horn's
%   method) to estimate the marker position in the first and last frames
%   based on donor data, consisting of marker data from markers on the same
%   rigid body.  This will only fill the first and last frames so that
%   other gap filling tools can be used.

% INPUTS:

% varargin: If you want to fill both starting and ending frames, do not
% enter anything.  To fill just the first frame, enter 'first'.  To fill
% just the last frame, enter 'last'.


numberVarargins = length(varargin);
if numberVarargins == 0
    fillBoth = 1;
else
    fillBoth = 0;
end

if numberVarargins == 1
    if contains(varargin{1},'first')
        fillFirst = 1;
        fillLast = 0;
    elseif contains(varargin{1},'last')
        fillFirst = 0;
        fillLast = 1;
    else
        error('Did not enter correct varargin')
    end
end

% FILL FIRST FRAME
if fillBoth == 1 || fillFirst == 1
    for mm = 1:length(allMarkerNames)
        currentMarker = allMarkerNames{mm}; % checking the frames for this marker
        
        firstFrame = 0; % resetting variable
        startLooking = 1; % start looking for first good frame at this point (!!!!!!!!!!)
        
        if isnan(markerStruct.(currentMarker).x(1)) % if first frame is missing (!!!!!!!!!)
            % Find first full frame of data
            while isnan(markerStruct.(currentMarker).x(startLooking)) % look until data is not NaN
                startLooking = startLooking + 1;
            end
            firstFrame = startLooking; % this is the first frame where there is data
            if firstFrame ~= 1
                markerStruct.(currentMarker).x(1:firstFrame) = markerStruct.(currentMarker).x(firstFrame);
                markerStruct.(currentMarker).y(1:firstFrame) = markerStruct.(currentMarker).y(firstFrame);
                markerStruct.(currentMarker).z(1:firstFrame) = markerStruct.(currentMarker).z(firstFrame);
            end% this is the last frame where there is data
            %Find other markers to drive the fix
           

            end
            
           
        end
    end


% FILL LAST FRAME

if fillBoth == 1 || fillLast == 1
    for mm = 1:length(allMarkerNames)
        currentMarker = allMarkerNames{mm}; % checking the frames for this marker
        
        lastFrame = 0; % resetting variable
        lengthData = length(markerStruct.(currentMarker).x);
        startLooking = lengthData; % start looking for last good frame at this point (end of data vector)
        
        if isnan(markerStruct.(currentMarker).x(startLooking)) % if last frame is missing
            % Find first full frame of data
            while isnan(markerStruct.(currentMarker).x(startLooking)) % look until data is not NaN
                startLooking = startLooking - 1;
            end
            lastFrame = startLooking;
            if lastFrame ~= lengthData
                markerStruct.(currentMarker).x(lastFrame+1:lengthData) = markerStruct.(currentMarker).x(lastFrame);
                markerStruct.(currentMarker).y(lastFrame+1:lengthData) = markerStruct.(currentMarker).y(lastFrame);
                markerStruct.(currentMarker).z(lastFrame+1:lengthData) = markerStruct.(currentMarker).z(lastFrame);
            end% this is the last frame where there is data
            
           
    end
end

end
end

% -------------------------------------------------------------------------

function checkForMissingMarkers(markerStruct, markerSet)
missingFrames = Vicon.findGaps(markerStruct); % find missing frames
for mm = 1:length(markerSet)
    currentMarker = markerSet{mm};
    if isempty(missingFrames.(currentMarker))==0 && contains(currentMarker,'C_')==0
        disp(['    MISSING:',currentMarker])
    end
end
end
% ----------------------------------------------------------------------------
function markerStruct = checkForAbsentMarkers(markerList,markerSet,markerStruct,staticStruct)
    clusternames = fieldnames(markerSet);
    fields = fieldnames(markerStruct);
    frames = length(markerStruct.(fields{1}).x);
    for mm = 1:length(clusternames)
        markernames = fieldnames(markerSet.(clusternames{mm}));
        Names = {};
        for ll = 1:length(markernames)
            Names{ll} = markernames{ll};
        end
        for ll = 1:length(markernames)
            markerName = markernames{ll};
        coords = [];
        if ~any(strcmp(fields,markerName))
            idx = strcmp(Names,markerName);
            markerStruct.(markerName) = table;
            markerStruct.(markerName).Header(1:frames) = [1:frames]';
            markerStruct.(markerName).x(1:frames) = NaN;
            markerStruct.(markerName).y(1:frames) = NaN;
            markerStruct.(markerName).z(1:frames) = NaN;
            otherMarkers = Names;
            staticCoord =  [staticStruct.(markerName).x(1);staticStruct.(markerName).y(1);staticStruct.(markerName).z(1)];
            staticCoords = [];
            otherMarkers(idx) = [];
            rr = 0;
            for qq = 1:length(otherMarkers)
                otherMarkerName = otherMarkers{qq};
                if isfield(markerStruct, otherMarkerName)
                    rr = rr+1;
                coords(1,rr,1:frames) = markerStruct.(otherMarkerName).x;
                coords(2,rr,1:frames) = markerStruct.(otherMarkerName).y;
                coords(3,rr,1:frames) = markerStruct.(otherMarkerName).z;
                staticCoords(1,rr) = staticStruct.(otherMarkerName).x(1);
                staticCoords(2,rr) = staticStruct.(otherMarkerName).y(1);
                staticCoords(3,rr) = staticStruct.(otherMarkerName).z(1);
                end
            end
            disp(['Injecting Marker: ' markerName])
           
            for ff = 1:frames

                    if ~any(isnan([coords(:,:,ff)]))
                    p = absor([staticCoords],[coords(:,:,ff)]);
                    M = p.R * staticCoord + p.t;
                    markerStruct.(markerName).x(ff) = M(1);
                    markerStruct.(markerName).y(ff) = M(2);
                    markerStruct.(markerName).z(ff) = M(3);
                    end


            end
            
            fields = fieldnames(markerStruct);
        end
        end
    end


end


function markerStruct = nanFill(markerStruct, currentMarker, firstFrame, lastFrame)

% firstFrame 
% lastFrame
% markerStruct.(currentMarker).y(firstFrame:lastFrame)
                markerStruct.(currentMarker).x(firstFrame:lastFrame) = linspace(markerStruct.(currentMarker).x(firstFrame),markerStruct.(currentMarker).x(lastFrame),lastFrame-firstFrame+1);
                markerStruct.(currentMarker).y(firstFrame:lastFrame) = linspace(markerStruct.(currentMarker).y(firstFrame),markerStruct.(currentMarker).y(lastFrame),lastFrame-firstFrame+1);
                markerStruct.(currentMarker).z(firstFrame:lastFrame) = linspace(markerStruct.(currentMarker).z(firstFrame),markerStruct.(currentMarker).z(lastFrame),lastFrame-firstFrame+1);

 %  markerStruct.(currentMarker).y(firstFrame:lastFrame)          


end