function markerSet = Get_MarkerSet(filePath,viconPath)
fprintf('\n \n \n \n %%%%%% GETTING MARKERSET %%%%%% \n \n \n \n');

[~,status_result] = system('tasklist /FI "imagename eq nexus.exe" /fo table /nh');
%Check if Vicon is Running
if ~contains(status_result, 'Nexus.exe')
    %Open Vicon if it isn't running
    system([viconPath ' &'])
    pause(30)
end
vicon = ViconNexus();

files = dir(filePath);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && contains(files(k).name, '.c3d')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)
File = files(ii).name;
filename = File(1:length(File)-4);
if contains(filename,'static') | contains(filename,'Static') | contains(filename,'STATIC');

File = files(ii).name;
filename = [filePath '\' File(1:length(File)-4)];
workingFilename = [filePath '\Working\' File(1:length(File)-4)];
disp(['Preparing trial: ' File(1:length(File)-4)])
doing_vicon_operations = true;
while doing_vicon_operations
try   
vicon.OpenTrial(filename, 60);
vicon.RunPipeline('ExportC3D', '', 200);
vicon.SaveTrial(60);
[ names, ~, active ] = vicon.GetSubjectInfo();
subject = names{active};
segments = vicon.GetSegmentNames(subject);
for qq = 1:length(segments)
    segment = segments{qq};
    [ parent, ~, markers] = vicon.GetSegmentDetails(subject, segment);
    for jj = 1:length(markers)
        marker = markers{jj};
        markerSet.(segment).(marker) = struct('errorTollerence',120,'driftTollerence',30);
    end
    if length(markers) < 4
        diff = 4-length(markers);
        [~, ~, parentMarkers] = vicon.GetSegmentDetails(subject, parent);
        for jj = 1:diff
          marker = parentMarkers{jj};
          markerSet.(segment).(marker) = struct('errorTollerence',120,'driftTollerence',30);  
        end
        
    end
end
vicon.CloseTrial(60);
catch

    Create_Endnote_Filter(filePath,filename)
    warning('Problem communicating with Vicon... Attempting to reconnect')
    Check_Reopen_Vicon(viconPath);
    Vicon_Openned = false;
    while ~Vicon_Openned
    try
    vicon = ViconNexus();
    catch 
        pause(2)
        continue
    end
    Vicon_Openned = true;
    end
    continue

end
doing_vicon_operations = false;
end
end
end