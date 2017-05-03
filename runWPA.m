%Runs the Psycostimversion of the EPT tast.
%User selects which session is required
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 25/12/14 (yes im coding on christmas...)
clear all;
clc;
%%
studyID = 'WPA';
sessionType = questdlg('Welcome to the WPA task, which version would you like to run?','Welcome','Encoding','Test1','Test2','Orientation');

Screen('Preference', 'SkipSyncTests', 1); %For some issues

if strcmp(sessionType,'Encoding')
    answer = inputdlg({'Subject ID: ','Visit #'}, 'Study Inputs',1);
    [subjectID,visitID] = deal(answer{:});
    subjectID = str2double(subjectID);
    visitID = str2double(visitID); 

    okString = sprintf('You have chosen to run encoding for subject %i, visit %i. Is this correct?',subjectID,visitID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')  
        fclose('all');
        return
    end
    %run train
    checkFiles(studyID,subjectID,visitID,0);
    makeStim_WPA(studyID,subjectID,visitID);
    train_pairsSequential(studyID,subjectID,visitID);
  
 elseif strcmp(sessionType,'Test1') 
    answer = inputdlg({'Subject ID: ','Visit #'}, 'Study Inputs',1);
    [subjectID,visitID] = deal(answer{:});
    subjectID = str2double(subjectID);
    visitID = str2double(visitID);
    
    okString = sprintf('You have chosen to run test 1 for subject %i, visit %i. Is this correct?',subjectID,visitID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')
        fclose('all');
        return
    end
    checkFiles(studyID,subjectID,visitID,1);
    test_recogSequential(studyID,subjectID,visitID,1)
    runStats_WPA(studyID,subjectID,visitID,[1]);
    
elseif strcmp(sessionType,'Test2') 
    answer = inputdlg({'Subject ID: ','Visit #'}, 'Study Inputs',1);
    [subjectID,visitID] = deal(answer{:});
    subjectID = str2double(subjectID);
    visitID = str2double(visitID);
    
    okString = sprintf('You have chosen to run test 2 for subject %i, visit %i. Is this correct?',subjectID,visitID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')
        fclose('all');
        return
    end
    checkFiles(studyID,subjectID,visitID,2);
    test_recogSequential(studyID,subjectID,visitID,2)
    runStats_WPA(studyID,subjectID,visitID,[1 2]);
end
  
ListenChar(0);
ShowCursor;
sca;
fclose('all');