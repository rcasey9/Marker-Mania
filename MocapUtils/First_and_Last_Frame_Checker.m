function First_and_Last_Frame_Checker(markerSet,filename,path)
staticFiles = dir(fullfile(path,'*Static*.c3d'));
staticFile = staticFiles(1);
staticFile = staticFile.name;
disp('Checking first and last frames for out of place markers')

staticFile = [path '\' staticFile];
staticStruct = Vicon.ExtractMarkers(staticFile);
clusterNames = fieldnames(markerSet);
for cc = 1:length(clusterNames)
    cluster = {};
    for cl = 1:length(fieldnames(markerSet.(clusterNames{cc})))
    cluster{cl} = markerSet.(clusterNames{cc}).(['m' num2str(cl)]).name;
    end
    for qq = 1:length(cluster)
        currentmarker= cluster{qq};
        staticCoords(cc,1:3,qq)= [staticStruct.(cluster{qq}).x(1),staticStruct.(cluster{qq}).y(1),staticStruct.(cluster{qq}).z(1)]';
    end
end
%%
c3dFile = [filename '.c3d'];
    if contains(c3dFile,'filled')
        c3dfiles(ii).name
        unlabelled = 0;

                    markerStruct = Vicon.ExtractMarkers(c3dFile);
                    for cc = 1:length(clusterNames)
                        clusterNames{cc};
                    cluster = {};
                    for cl = 1:length(fieldnames(markerSet.(clusterNames{cc})))
                    cluster{cl} = markerSet.(clusterNames{cc}).(['m' num2str(cl)]).name;
                    end
                    clusterSize = size(cluster);
                    absoluteMarkerErrors = [];
                    endInd = length(markerStruct.(cluster{1}).Header)
                    for qq = 1:clusterSize(2)
                            markerNames{qq} = cluster{qq};
                            clusterInds = 1:clusterSize(2);
                            clusterInds(qq) = [];
                            previoudsMarkerCoords = [];
                            markerCoords = [];
                            staticCoordsRef = [];
                            for ll = 1:length(clusterInds)
                                ind = clusterInds(ll);
                                
                                startMarkerCoords(1:3,ll) = [markerStruct.(cluster{ind}).x(1), markerStruct.(cluster{ind}).y(1), markerStruct.(cluster{ind}).z(1)];
                                endMarkerCoords(1:3,ll) = [markerStruct.(cluster{ind}).x(endInd), markerStruct.(cluster{ind}).y(endInd), markerStruct.(cluster{ind}).z(endInd)];
                                staticCoordsRef(1:3,ll) = staticCoords(cc,1:3,ind);
                                
                            

                            end
                            if ~ anynan(startMarkerCoords) & ~anynan(staticCoordsRef)
                            p = absor([staticCoordsRef],[startMarkerCoords]);
                            M = p.R * [staticCoords(cc,1,qq);staticCoords(cc,2,qq);staticCoords(cc,3,qq);] + p.t;
                            startMarkerErrors(qq) = sqrt((markerStruct.(cluster{qq}).x(ff)-M(1)).^2 + (markerStruct.(cluster{qq}).y(ff)-M(2)).^2 + (markerStruct.(cluster{qq}).z(ff)-M(3)).^2);
                            else
                            startMarkerErrors(qq) = 0;   
                            end
                            if ~ anynan(endMarkerCoords) & ~anynan(staticCoordsRef)
                                p = absor([staticCoordsRef],[endMarkerCoords]);
                            M = p.R * [staticCoords(cc,1,qq);staticCoords(cc,2,qq);staticCoords(cc,3,qq);] + p.t;
                            endMarkerErrors(qq) = sqrt((markerStruct.(cluster{qq}).x(ff)-M(1)).^2 + (markerStruct.(cluster{qq}).y(ff)-M(2)).^2 + (markerStruct.(cluster{qq}).z(ff)-M(3)).^2);
                            else
                            endMarkerErrors(qq) = 0;   
                            end
                    end

                    unlabelLocations = startMarkerErrors .* 0;

  
                            errorThreshold = markerSet.(clusterNames{cc}).(['m' num2str(maxInd)]).errorTollerence;
                            startMaxError = max(startMarkerErrors);
                            startMaxInd = find(frameErrors == startMaxError);
                            startMaxInd = startMaxInd(1);
                            
                            if startMaxError > errorThreshold
                                location = find(startMarkerErrors == startMaxError);
                                
                                
                                disp(['Unlabelling ' markerSet.(clusterNames{cc}).(['m' num2str(maxInd)]).name ' at  first frame'])
                                markerStruct.(cluster{location}).x(1) = NaN;
                            end
                            endMaxError = max(endMarkerErrors);
                            endMaxInd = find(frameErrors == endMaxError);
                            endMaxInd = endMaxInd(1);
                            
                            if endMaxError > errorThreshold
                                location = find(endMarkerErrors == endMaxError);
                                
                                
                                disp(['Unlabelling ' markerSet.(clusterNames{cc}).(['m' num2str(maxInd)]).name ' at  last frame'])
                                markerStruct.(cluster{location}).x(endInd) = NaN;
                            end


                            end
                        
                        
                       

                        
                        
                    

                  
                        disp('    Writing new C3D file...')
                            Vicon.markerstoC3D(markerStruct, c3dFile, c3dFile);

end



end