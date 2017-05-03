function runStats_EPT(studyID,subjectID,visitID,testIDs)%Take human input to decide which version to run and what session
%if 1 %to run not as a function
%Creates stats a participant on the EPT task.
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 8/2/15

%studyID='EPT_PSTIM1'; subjectID=1; visitID=1; testIDs=[1 2];%to run not as a function

try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    familAns = settings(3:end,strcmp(settings(1,:),'familAns'));
    familAns = familAns(~cellfun('isempty',familAns)); %remove any empty cells (artifact of bad csv import)
    foilAns = settings(3:end,strcmp(settings(1,:),'foilAns'));
    foilAns = foilAns(~cellfun('isempty',foilAns)); %remove any empty cells (artifact of bad csv import)
catch err
    menu('ERROR: The settings file for this study is not found or has been corrupted','Quit');
    rethrow(err)
end

parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
delete(sprintf('Data/%s_STATS_Sub%i_Visit%i.csv',studyID,subjectID,visitID))
for i=1:length(testIDs)
    %create arrays
    stimTest = parData.(sprintf('stimTest%i',testIDs(i)));
    responseArray = parData.(sprintf('responseArray%i',testIDs(i)));
    rtArray = parData.(sprintf('rtArray%i',testIDs(i)));
 
    valenceNeg = cellfun(@(x) ismember(x,parData.stimNeg),stimTest);
    valenceNeu = cellfun(@(x) ismember(x,parData.stimNeu),stimTest);
    wasFamil = cellfun(@(x) ismember(x,parData.stimFamil),stimTest);
    wasFoil = cellfun(@(x) ismember(x,parData.stimFoil),stimTest);
    ansFamil = cellfun(@(x) ismember(x,familAns),responseArray);
    ansFoil = cellfun(@(x) ismember(x,foilAns),responseArray);
    hits = ansFamil & wasFamil;
    misses = ansFoil & wasFamil;
    falseAlarms = ansFamil & wasFoil;
    correctRejection = ansFoil & wasFoil;
    dPrime = dprime(sum(hits)/length(hits),sum(falseAlarms)/length(falseAlarms));
    
    %save arrays
    statsData.(sprintf('stimTest%i',testIDs(i))) = stimTest;
    statsData.(sprintf('responseArray%i',testIDs(i))) = responseArray;
    statsData.(sprintf('rtArray%i',testIDs(i))) = rtArray;
    statsData.(sprintf('valenceNeg%i',testIDs(i))) = valenceNeg;
    statsData.(sprintf('valenceNeu%i',testIDs(i))) = valenceNeu;
    statsData.(sprintf('hits%i',testIDs(i))) = hits;
    statsData.(sprintf('misses%i',testIDs(i))) = misses;
    statsData.(sprintf('falseAlarms%i',testIDs(i))) = falseAlarms;
    statsData.(sprintf('correctRejection%i',testIDs(i))) = correctRejection;
    statsData.(sprintf('dPrime%i',i)) = dPrime;
end

%clean up and make csv's
struct2csv(statsData,sprintf('Data/%s_STATS_Sub%i_Visit%i.csv',studyID,subjectID,visitID))
struct2csv(parData,sprintf('Data/%s_RAW_DATA_Sub%i_Visit%i.csv',studyID,subjectID,visitID))
%delete temp data
%delete(sprintf('Data/Incomplete/%s_Sub%i_Visit%i.mat',studyID,subjectID,visitID))
delete(sprintf('Data/Incomplete/%s_Sub%i_Visit%i_TrainingData.csv',studyID,subjectID,visitID))
for i=1:length(testIDs)
    delete(sprintf('Data/Incomplete/%s_Sub%i_Visit%i_Test%iData.csv',studyID,subjectID,visitID,testIDs(i)))
end
end