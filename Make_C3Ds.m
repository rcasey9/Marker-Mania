clc; clear; close all;
%% Specify path to your data

filePath1 = 'C:\Users\rcasey9\GaTech Dropbox\Ryan Casey\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections2\TI';
filePath2 = '\Biomechanics_data\DOE_TIA_';
filepath3 = '\New Session';

folderList = {'02','03','04','05','06','08','09','10','11',};


%% Specify your viconPath

tic
viconPath = [];
files = dir('C:\Program Files\Vicon');
for ii = length(files):-1:1
    folder = files(ii).name;
    if contains(folder,'Nexus2')
        viconPath = ['C:\Program Files\Vicon\' folder '\Nexus.exe'];
        break
    end
end

files = dir('C:\Program Files (x86)\Vicon');
for ii = length(files):-1:1
    folder = files(ii).name;
    if contains(folder,'Nexus2')
        viconPath = ['C:\Program Files (x86)\Vicon\' folder '\Nexus.exe'];
        break
    end
end

if isempty(viconPath)
    warning('Nexus.exe Object not found. Manually set viconPath variable to Nexus.exe fullpath');
end




%% Processing

for ii = 1:length(folderList)
sub = folderList{ii};
subNum = sub(1:2);
filePath = [filePath1 subNum filePath2 sub filepath3];

    C3D_Pass(filePath, viconPath);

end



toc
