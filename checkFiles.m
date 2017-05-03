function checkFiles(studyID,subjectID,visitID,testID)
%if 1 %to run not as a function
%Tests if all files are ok
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15
%studyID='EPT_PSTIM1'; subjectID=1; stimListID=1 ;visitID=1; testID=0;%to run not as a function 
%load study settings
try 
    csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
catch err
    menu('The settings file or images folder for this study is not found or has been corrupted','Quit');
    fclose('all');
    rethrow(err)
end

try
    csvimport(sprintf('Data/%s_Sub%i_Visit%i.csv',studyID,subjectID,visitID));
    choice=menu('This participant already has completed this session, are you sure you want to run again? previous data will be overwirtten','Quit','Overwrite');
    if choice==1
        fclose('all');
        return
    elseif choice==2
        disp('Overwriting...')    
    end
catch err
    disp('Training') %This is not an error, there should not be par data, so expect to get here...
end

if testID
    %deal with condition where training data already exists and will be overwirtten by this session...
    try 
        parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));       
        parData.(sprintf('stimTest%i',testID));
    catch err
        menu('Stimulus data for this session does not exsist!','Quit');
        rethrow(err)
    end
    try       
        parData.(sprintf('responseArray%i',testID));
        choice = menu('Training data for this session already exsists, Are you sure you want to overwrite?','Quit','Overwrite');
        if choice==1;
            fclose('all');
            return
        else
            disp('Warning: Overwriting')
            fields = fieldnames(parData); %delete previous testing datas
            testingFields = fields(strcmp(fields,sprintf('Array%i',testID)));
            for i = 1:length(testingFields)
                parData = rmfield(parData.(testingFields{i}));
            end
            save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');
        end
    catch err
        disp('Testing')
    end
else
    %load par data (or try anyways)
    try
        load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
        choice=menu('This participant already has training data, are you sure you want to run training again? previous data will be overwirtten','Quit','Overwrite');
        if choice==1
            fclose('all');
            return
        elseif choice==2
            disp('Overwriting...')      
        end
    catch err
        disp('Training')
    end
end

end