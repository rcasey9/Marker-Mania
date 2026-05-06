clc; clear; close all;
%% Specify path to your data


folderList = {'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Pilots\Exo_Pilot_11_Apr_2026\Biomech_data\DOE_Exo_11_Apr_2026\New Session',...
    'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Pilots\Exo_Pilot_08_Apr_2026\Biomech_data\DOE_Exo_8_Apr_2026\New Session',...
    };

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

filePath = folderList{ii};


    markerSet = Get_MarkerSet(filePath, viconPath);
    First_Pass(markerSet, filePath, viconPath);
    Final_Pass(markerSet, filePath, viconPath);
    %LC_Pass(markerSet, filePath, viconPath);
    Move_Markerset_Files(filePath)
    Endnote_Pass(filePath)
end



toc
