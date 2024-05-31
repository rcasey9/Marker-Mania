function Check_Reopen_Vicon(viconPath)
%Return status of Vicon executable
[~,status_result] = system('tasklist /FI "imagename eq nexus.exe" /fo table /nh');
%Check if Vicon is Running
if ~contains(status_result, 'Nexus.exe')
    %Open Vicon if it isn't running
    system([viconPath ' &'])
    pause(30)
    %Wait for Vicon to Reopen
else
    system('TASKKILL -f -im "Nexus.exe"');
    pause(30)
    system([viconPath ' &'])
    %Wait for Vicon to Reopen
end

end