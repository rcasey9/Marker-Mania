function Fifth_Pass(markerSet, filePath,viconPath)
fprintf('\n \n \n \n %%%%%% STARTING FIFTH PASS %%%%%% \n \n \n \n');
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
finishedDir = [filePath '\Finished'];
workingDir = [filePath '\Working'];
missingDir = [filePath '\MissingMarkers'];
if ~exist(finishedDir, 'dir'); mkdir(finishedDir); end
if ~exist(workingDir, 'dir'); mkdir(workingDir); end
if ~exist(missingDir, 'dir'); mkdir(missingDir); end
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-3:M), '.c3d')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
filename = File(1:length(File)-4);
if ~contains(filename,'filled') & ~contains(filename,'static') & ~contains(filename,'Static') & ~contains(filename,'STATIC')
if ~contains(filename,'checked') & ~contains(filename,'fjc') & ~contains(filename,'Fjc') & ~contains(filename,'FJC') 
File = files(ii).name;
filename = [filePath '\' File(1:length(File)-4)];
workingFilename = [filePath '\Working\' File(1:length(File)-4)];
disp(['Preparing trial: ' File(1:length(File)-4)])
doing_vicon_operations = true;
while doing_vicon_operations
try   
vicon.OpenTrial(filename, 60);
vicon.RunPipeline('Reconstruct and Label Less Filtered', '', 1000);
vicon.RunPipeline('ExportC3D', '', 100);
vicon.SaveTrial(60);
vicon.CloseTrial(60);
catch
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


try
    copyfile([filename '.c3d'], workingDir)
    pause(5)
    Gap_Fill(markerSet,workingFilename,filePath)
    pause(1)
    clean = false;
    counter = 1;
    while clean == false & counter < 20
    clean = Movement_Checker(markerSet,[workingFilename '_filled']);
    pause(1)
    Gap_Fill(markerSet,workingFilename,filePath)
    pause(1)
    counter = counter + 1;
    end
    if clean
    disp([files(ii).name(1:length(files(ii).name)-4) ' has no abnormal movements'])
    Marker_Checker(markerSet,[workingFilename '_filled'],filePath,true)
    pause(1)
    end
catch 
    warning(['Problem with trial' files(ii).name])
    copyfile([filename '.c3d'], missingDir)
    continue
end
end
end
end
files = dir(workingDir);
for k = 1:length(files)
    M = length(files(k).name);
    if M > 4 && ~contains(files(k).name, 'filled')
        pause(2)
        delete([filePath '\Working\' files(k).name]);
    end
end
end