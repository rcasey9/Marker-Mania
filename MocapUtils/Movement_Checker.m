function[clean] = Movement_Checker(markerSet,filename)
%% GET ALL C3D FILED IN DIR
clean = true;
clusterNames = fieldnames(markerSet);
c3dFile = [filename '.c3d'];
    if contains(c3dFile,'filled')
        
                    unlabelStruct = struct();
                    markerStruct = Vicon.ExtractMarkers(c3dFile);

                    for cc = 1:length(clusterNames)
                    
                    cluster = {};
                    
                    movement = [];
                    names = fieldnames(markerSet.(clusterNames{cc}));
                    for ff = 1:length(markerStruct.(names{1}).Header(1:end-5))
                    
                    for cl = 1:length(names)
                    cluster{cl} = names{cl};
                    unlabelStruct.(['m' num2str(cc)]).(['m' num2str(cl)]).(['m' num2str(ff)]) = 0;
                   
                    
                    
                                move1 = sqrt((markerStruct.(cluster{cl}).x(ff)-markerStruct.(cluster{cl}).x(ff+1)).^2 + (markerStruct.(cluster{cl}).y(ff)-markerStruct.(cluster{cl}).y(ff + 1)).^2 + (markerStruct.(cluster{cl}).z(ff)-markerStruct.(cluster{cl}).z(ff + 1)).^2);
                                move2 = sqrt((markerStruct.(cluster{cl}).x(ff+1)-markerStruct.(cluster{cl}).x(ff+2)).^2 + (markerStruct.(cluster{cl}).y(ff+1)-markerStruct.(cluster{cl}).y(ff + 2)).^2 + (markerStruct.(cluster{cl}).z(ff+1)-markerStruct.(cluster{cl}).z(ff + 2)).^2);
                                move3 = sqrt((markerStruct.(cluster{cl}).x(ff+2)-markerStruct.(cluster{cl}).x(ff+3)).^2 + (markerStruct.(cluster{cl}).y(ff+2)-markerStruct.(cluster{cl}).y(ff + 3)).^2 + (markerStruct.(cluster{cl}).z(ff+2)-markerStruct.(cluster{cl}).z(ff + 3)).^2);
                                move4 = sqrt((markerStruct.(cluster{cl}).x(ff+3)-markerStruct.(cluster{cl}).x(ff+4)).^2 + (markerStruct.(cluster{cl}).y(ff+3)-markerStruct.(cluster{cl}).y(ff + 4)).^2 + (markerStruct.(cluster{cl}).z(ff+3)-markerStruct.(cluster{cl}).z(ff + 4)).^2);
                                move5 = sqrt((markerStruct.(cluster{cl}).x(ff+4)-markerStruct.(cluster{cl}).x(ff+5)).^2 + (markerStruct.(cluster{cl}).y(ff+4)-markerStruct.(cluster{cl}).y(ff + 5)).^2 + (markerStruct.(cluster{cl}).z(ff+4)-markerStruct.(cluster{cl}).z(ff + 5)).^2);
                                movement(ff,cl) = mean([move1,move2,move3,move4,move5]);
    
                    end
                    [movementAvgs, bestInds] = mink(movement(ff,:),3);
                    movementTollerance = mean(movementAvgs); 
                    for cl = 1:length(fieldnames(markerSet.(clusterNames{cc})))
                        if movement(ff,cl) > 3.5 * movementTollerance & movement(ff,cl) > 5 & ~any(bestInds == cl)
                            %disp(['Unlabelling ' cluster{cl} ' at frame ' num2str(ff)])
                            unlabelStruct.(['m' num2str(cc)]).(['m' num2str(cl)]).(['m' num2str(ff)]) = 1;
                        end
                    end
                    end
                    
                    end
                    for cc = 1:length(clusterNames)
                  
                    cluster = {};
                    names = fieldnames(markerSet.(clusterNames{cc}));
                    for cl = 1:length(names)
                        cluster{cl} = names{cl};
                        filterChunk = round(length(markerStruct.(cluster{1}).Header)/20);
                    for ff = 1:length(markerStruct.(cluster{1}).Header(1:end-filterChunk))

                   if unlabelStruct.(['m' num2str(cc)]).(['m' num2str(cl)]).(['m' num2str(ff)]) == 1
                        clean = false;
                       
                        markerStruct.(cluster{cl}).x(ff:ff+filterChunk) = NaN;
                        markerStruct.(cluster{cl}).y(ff:ff+filterChunk) = NaN;
                        markerStruct.(cluster{cl}).z(ff:ff+filterChunk) = NaN;

                   end
                    end
                    
                   end

                   end

                            checkedC3D = ([c3dFile(1:length(c3dFile)-11),'.c3d']);
                            Vicon.markerstoC3D(markerStruct, c3dFile, checkedC3D);
                            delete(c3dFile);
                            pause(3)
                       
                        
                    end


end

