function Clean_Pass(markerSet, filePath)
fprintf('\n \n \n \n %%%%%% STARTING CLEANUP PASS %%%%%% \n \n \n \n');

finishedDir = [filePath '\Finished'];
workingDir = [filePath '\Working'];
missingDir = [filePath '\MissingMarkers'];
files = dir(workingDir);
L = length(files);
index = false(1, L);
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
if ~contains(filename,'static') & ~contains(filename,'Static') & ~contains(filename,'STATIC')
if ~contains(filename,'checked') & ~contains(filename,'fjc') & ~contains(filename,'Fjc') & ~contains(filename,'FJC')
File = files(ii).name
filename = [filePath '\' File(1:length(File)-4)];
workingFilename = [filePath '\Working\' File(1:length(File)-4)];
finishedFilename = [filePath '\Finished\' File(1:length(File)-4)];
disp(['Preparing trial: ' File(1:length(File)-4)])


%try
    Gap_Fill(markerSet,workingFilename,filePath)
    pause(1)
    movefile([workingFilename '_filled.c3d'],[finishedFilename '.c3d'])

% catch 
%     warning(['Problem with trial' files(ii).name])
%     copyfile([filename '.c3d'], missingDir)
%     continue
% end
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