function T10_Fill(markerSet,filename,path)

clusterNames = fieldnames(markerSet);
%extract list of all markers
markerNum = 1;
markerList = {};
clusters = {};
for cl = 1:length(clusterNames)
    markers = fieldnames(markerSet.(clusterNames{cl}));
    clusterMarkers = {};
    for mm = 1:length(markers)
        
        if ~ismember(markerSet.(clusterNames{cl}).(markers{mm}).name,markerList)
            
            
            markerList{markerNum} = markerSet.(clusterNames{cl}).(markers{mm}).name;
            markerNum = markerNum +1;
            
        end
        clusterMarkers{mm} =  markerSet.(clusterNames{cl}).(markers{mm}).name;
    end
    clusters{cl} = clusterMarkers;
end


if ~contains(filename,'fjc') & ~contains(filename,'Fjc') & ~contains(filename,'FJC')
  % check for missing markers first and last frame  
  c3dFile = [filename '.c3d'];
  finishedName = erase(c3dFile,[path '\Finished\']);         
      
                    markerStruct = Vicon.ExtractMarkers(c3dFile);

                    % Loop through all markers
                    markerStruct = T10(markerStruct);                         
                        
                        pause(3)
                        finishedC3D = ([path '\Finished\' finishedName]);
                        %if ~isfile(finishedC3D)
                        
                        Vicon.markerstoC3D(markerStruct, c3dFile, finishedC3D);
                        %end
                  

end
end


function markerStruct = T10(markerStruct)
  fields = fieldnames(markerStruct); 
  if ~isfield(markerStruct,'MID_PSI')
    markerStruct.MID_PSI = table;
            markerStruct.MID_PSI.Header(1:length(markerStruct.(fields{1}).Header)) = [markerStruct.(fields{1}).Header]';
            markerStruct.MID_PSI.x(1:length(markerStruct.(fields{1}).Header)) = NaN;
            markerStruct.MID_PSI.y(1:length(markerStruct.(fields{1}).Header)) = NaN;
            markerStruct.MID_PSI.z(1:length(markerStruct.(fields{1}).Header)) = NaN;
  end

            for ff = 1:length(markerStruct.(fields{1}).Header)

                   
                    markerStruct.MID_PSI.x(ff) = (markerStruct.LPSI.x(ff) + markerStruct.RPSI.x(ff))/2;
                    markerStruct.MID_PSI.y(ff) = (markerStruct.LPSI.y(ff) + markerStruct.RPSI.y(ff))/2;
                    markerStruct.MID_PSI.z(ff) = (markerStruct.LPSI.z(ff) + markerStruct.RPSI.z(ff))/2;



            end  
  if ~isfield(markerStruct,'T10')
    markerStruct.T10 = table;
            markerStruct.T10.Header(1:length(markerStruct.(fields{1}).Header)) = [markerStruct.(fields{1}).Header]';
            markerStruct.T10.x(1:length(markerStruct.(fields{1}).Header)) = NaN;
            markerStruct.T10.y(1:length(markerStruct.(fields{1}).Header)) = NaN;
            markerStruct.T10.z(1:length(markerStruct.(fields{1}).Header)) = NaN;
  end
  
            for ff = 1:length(markerStruct.(fields{1}).Header)

                   
                    markerStruct.T10.x(ff) = (3*markerStruct.MID_PSI.x(ff) + markerStruct.C7.x(ff))/4;
                    markerStruct.T10.y(ff) = markerStruct.T10_OFFSET.y(ff);
                    markerStruct.T10.z(ff) = (3*markerStruct.MID_PSI.z(ff) + markerStruct.C7.z(ff))/4;



            end
    
   


end

