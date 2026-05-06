clc; clear all; close all;

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

folderList = {'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Pilots\Graham_Exo_HILO\archive\Exo_Pilot_08_Apr_2026\Biomech_data\DOE_Exo_8_Apr_2026\New Session',...
    };

for ii = 1:length(folderList)

    filePath = folderList{ii};
    
   markerSet = Get_MarkerSet(filePath, viconPath);
    
   Clean_Pass(markerSet, filePath);
    
   Endnote_Pass(filePath);
    
    T10_relocate(markerSet, filePath);
    
end

toc
