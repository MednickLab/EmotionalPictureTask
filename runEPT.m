%Runs the Psycostimversion of the EPT tast.
%User selects which session is required
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 25/12/14 (yes im coding on christmas...)
clear all;
clc;
studyID = 'EPT'; %Study ID goes here
stimlists = {'ImageList 1','ImageList 2','ImageList 3','ImageList 4'}; %Possible stim sets here (folders for images, header names for words)
sessionType = questdlg('Welcome to the EPT task, which version would you like to run?','Welcome','Training','Test1','Test2','Training');
if strcmp(sessionType,'Quit')
    fclose('all');
    return
end
answer = inputdlg({'Subject ID: ','Visit #'}, 'Study Inputs',1);
[subjectID,visitID] = deal(answer{:});
subjectID = str2double(subjectID);
visitID = str2double(visitID);

%Training subject by displaying stim one at a time.
%Parameters that can be set in the settings are:
% - Number of stim to train
% - Number of times to repeat stim
% - All timing parameters
% - 
if strcmp(sessionType,'Training')
    [imageListID,ok] = listdlg('PromptString','Select Wordlist:','SelectionMode','single','ListString',stimlists);
    okString = sprintf('You have chosen to run training for subject %i, visit %i with Image List %i. Is this correct?',subjectID,visitID,imageListID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')
        fclose('all');
        return
    end
    checkFiles(studyID,subjectID,visitID,0); %We check to see if data for a subject already exists
    makeStim_EPT(studyID,subjectID,visitID,imageListID); %Make stim sets
    train_singleImageWithResponse(studyID,subjectID,visitID);
    
elseif strcmp(sessionType,'Test1')
    okString = sprintf('You have chosen to run test 1 for subject %i, visit %i. Is this correct?',subjectID,visitID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')
        fclose('all');
        return
    end
    checkFiles(studyID,subjectID,visitID,1);
    test_recog(studyID,subjectID,visitID,1);
    runStats_EPT(studyID,subjectID,visitID,[1]);
elseif strcmp(sessionType,'Test2')
    okString = sprintf('You have chosen to run test 2 for subject %i, visit %i. Is this correct?',subjectID,visitID);
    buttonAns = questdlg(okString,'Check details!','Yes','No (Quit)','Yes');
    if strcmp(buttonAns,'No (Quit)')
        fclose('all');
        return
    end
    checkFiles(studyID,subjectID,visitID,2);
    test_recog(studyID,subjectID,visitID,2);
    runStats_EPT(studyID,subjectID,visitID,[1 2]);
end
  
ListenChar(1);
ShowCursor;
sca;
fclose('all');