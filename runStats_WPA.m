function runStats_WPA(studyID,subjectID,visitID,testIDs)%Take human input to decide which version to run and what session
%if 1 %to run not as a function
%Creates stats a participant on the EPT task.
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 8/2/15

%studyID='WPA_ACH0'; subjectID=8; visitID=0; testIDs=[1];%to run not as a function

try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    intactAns = settings(3:end,strcmp(settings(1,:),'intactAns'));
    intactAns = intactAns(~cellfun('isempty',intactAns)); %remove any empty cells (artifact of bad csv import)
    rearangedAns = settings(3:end,strcmp(settings(1,:),'rearangedAns'));
    rearangedAns = rearangedAns(~cellfun('isempty',rearangedAns)); %remove any empty cells (artifact of bad csv import)
    novelAns = settings(3:end,strcmp(settings(1,:),'novelAns'));
    novelAns = novelAns(~cellfun('isempty',novelAns)); %remove any empty cells (artifact of bad csv import)
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
    responseTimeArray = parData.(sprintf('responseTimeArray%i',testIDs(i)));
 
    wasIntact = strcmp('Intact',stimTest(:,3));
    wasRearr = strcmp('Rearr',stimTest(:,3));
    wasNovel = strcmp('Novel',stimTest(:,3));
    ansIntact = cellfun(@(x) ismember(x,intactAns),responseArray);
    ansRearr = cellfun(@(x) ismember(x,rearangedAns),responseArray);
    ansNovel = cellfun(@(x) ismember(x,novelAns),responseArray);
    hitsIntact = ansIntact & wasIntact;
    missesIntact = ~ansIntact & wasIntact;
    falseAlarmsIntact = ansIntact & ~wasIntact;
    corRejIntact = ~ansIntact & ~wasIntact;
    dPrimeIntact = dprime(sum(hitsIntact)/length(hitsIntact),sum(falseAlarmsIntact)/length(falseAlarmsIntact));
    hitsRearr = ansRearr & wasRearr;
    missesRearr = ~ansRearr & wasRearr;
    falseAlarmsRearr = ansRearr & ~wasRearr;
    corRejRearr = ~ansRearr & ~wasRearr;
    dPrimeRearr = dprime(sum(hitsRearr)/length(hitsRearr),sum(falseAlarmsRearr)/length(falseAlarmsRearr));
    hitsNovel = ansNovel & wasNovel;
    missesNovel = ~ansNovel & wasNovel;
    falseAlarmsNovel = ansNovel & ~wasNovel;
    corRejNovel = ~ansNovel & ~wasNovel;
    dPrimeNovel = dprime(sum(hitsNovel)/length(hitsNovel),sum(falseAlarmsNovel)/length(falseAlarmsNovel));
    overallCorrect = hitsIntact | hitsRearr | hitsNovel;
    accuracy = sum(overallCorrect)/length(overallCorrect);
    
    %save arrays
    statsData.(sprintf('stimTest%i',testIDs(i))) = stimTest(:,1:2);
    statsData.(sprintf('responseArray%i',testIDs(i))) = responseArray;
    statsData.(sprintf('responseTimeArray%i',testIDs(i))) = responseTimeArray;
    statsData.(sprintf('rtArray%i',testIDs(i))) = rtArray;
    statsData.(sprintf('ansIntact%i',testIDs(i))) = ansIntact;
    statsData.(sprintf('ansRearr%i',testIDs(i))) = ansRearr;
    statsData.(sprintf('ansNovel%i',testIDs(i))) = ansNovel;
    statsData.(sprintf('wasIntact%i',testIDs(i))) = wasIntact;
    statsData.(sprintf('wasRearr%i',testIDs(i))) = wasRearr;
    statsData.(sprintf('wasNovel%i',testIDs(i))) = wasNovel;
    
    statsData.(sprintf('hitsIntact%i',testIDs(i))) = hitsIntact;
    statsData.(sprintf('missesIntact%i',testIDs(i))) = missesIntact;
    statsData.(sprintf('falseAlarmsIntact%i',testIDs(i))) = falseAlarmsIntact;
    statsData.(sprintf('corRejIntact%i',testIDs(i))) = corRejIntact;
    statsData.(sprintf('dPrimeIntact%i',i)) = dPrimeIntact;
    statsData.(sprintf('hitsRearr%i',testIDs(i))) = hitsRearr;
    statsData.(sprintf('missesRearr%i',testIDs(i))) = missesRearr;
    statsData.(sprintf('falseAlarmsRearr%i',testIDs(i))) = falseAlarmsRearr;
    statsData.(sprintf('corRejRearr%i',testIDs(i))) = corRejRearr;
    statsData.(sprintf('dPrimeRearr%i',i)) = dPrimeRearr;
    statsData.(sprintf('hitsNovel%i',testIDs(i))) = hitsNovel;
    statsData.(sprintf('missesNovel%i',testIDs(i))) = missesNovel;
    statsData.(sprintf('falseAlarmsNovel%i',testIDs(i))) = falseAlarmsNovel;
    statsData.(sprintf('corRejNovel%i',testIDs(i))) = corRejNovel;
    statsData.(sprintf('dPrimeNovel%i',i)) = dPrimeNovel;
    statsData.(sprintf('overallCorrect%i',i)) = overallCorrect;
    statsData.(sprintf('accuracy%i',i)) = accuracy;
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