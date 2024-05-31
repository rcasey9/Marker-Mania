function Move_Markerset_Files(filePath)
finishedDir = [filePath '\Finished'];
workingDir = [filePath '\Working'];
files = dir(filePath);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-3:M), '.c3d') && (contains(files(k).name, 'Static') || contains(files(k).name, 'static') || contains(files(k).name, 'STATIC'))
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
copyfile ([filePath '\' File], [finishedDir '\' File],'f')
copyfile ([filePath '\' File], [workingDir '\' File],'f')
end

files = dir(filePath);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-2:M), '.mp')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
copyfile ([filePath '\' File], [finishedDir '\' File],'f')
copyfile ([filePath '\' File], [workingDir '\' File],'f')
end


files = dir(filePath);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-3:M), '.vsk')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
copyfile ([filePath '\' File], [finishedDir '\' File],'f')
copyfile ([filePath '\' File], [workingDir '\' File],'f')
end


end
