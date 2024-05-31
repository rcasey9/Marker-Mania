function T10_relocate(markerSet, filePath)
fprintf('\n \n \n \n %%%%%% T10 RELOCATION %%%%%% \n \n \n \n');


finishedDir = [filePath '\Finished'];
workingDir = [filePath '\Working'];
files = dir(finishedDir);
L = length(files);
index = false(1, L);
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

if ~contains(filename,'checked') & ~contains(filename,'fjc') & ~contains(filename,'Fjc') & ~contains(filename,'FJC')
File = files(ii).name
finishedFilename = [filePath '\Finished\' File(1:length(File)-4)];
disp(['Preparing trial: ' File(1:length(File)-4)])

%try

    T10_Fill(markerSet,finishedFilename,filePath)
% catch
%     warning(['Problem with trial' files(ii).name])
%     continue
% end


    % M = length(files(k).name);
    % if M > 4 && ~contains(files(k).name, 'filled')
    %     pause(2)
    %     delete([filePath '\Working\' files(k).name]);
    % end
end

end
end