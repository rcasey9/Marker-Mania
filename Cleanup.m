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

folderList = {'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_08\Biomech_data\DOE_HILO_08\New Session',...
'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_09\Biomech_data\DOE_HILO_09\New Session',...
'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_10\Biomech_data\DOE_HILO_10\New Session',...
'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_12\Biomech_data\DOE_HILO_12\New Session',...
'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_13\Biomech_data\DOE_HILO_13\New Session',...
'C:\Users\rcasey9\GaTech Dropbox\ME-DboxMgmt-Young_DOETeam\Data\Experiments\Biomech\HILO_N10_2026\HILO_14\Biomech_data\DOE_HILO_14\New Session',...
};

for ii = 1:length(folderList)

    filePath = folderList{ii};
    
   markerSet = Get_MarkerSet(filePath, viconPath);
    
   Clean_Pass(markerSet, filePath);
    
   Endnote_Pass(filePath);
    
    T10_relocate(markerSet, filePath);
    
end

toc
