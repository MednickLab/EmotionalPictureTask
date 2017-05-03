function threshold = test_recall2Threshold(studyID,subjectID,visitID,testID,feedback,stem)%Take human input to decide which version to run and what session
%if 1 %to run not as a function
%Runs a testing session of pretrained words from the WPA task for all studys.
%Test data is pulled from a participants file
%Words are displayed, and the user must input on screen using psychtoolbox
%@Params: studyID - Name of study (to load setting file)
%@Params: subjectID - Unique subject number
%@Params: testID - which test to run (first, second etc)
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 20/12/14

%Edited by Lizzie McDevitt 1/23/17 for ACH study

try
Screen('Preference', 'SkipSyncTests', 1)

%studyID='WPA_ACH'; subjectID=1; testID=0; visitID=1; feedback=1; stem=0;%to run not as a function

speedup = 1; % acceleration factor for debugging (default=1)

try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID));
    testBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'testBetweenStimDuration')});
    testStimDuration = str2double(settings{3,strcmp(settings(1,:),'testStimDuration')});
    testBlurb = settings{3:end,strcmp(settings(1,:),sprintf('test%iBlurb',1))};
    correctReq = str2double(settings{3,strcmp(settings(1,:),'correctReq')});
    requiredThreshold = str2double(settings{3,strcmp(settings(1,:),'requiredThreshold')});
    if feedback
        testFeedbackDuration = str2double(settings{3,strcmp(settings(1,:),'testFeedbackDuration')});
    end
catch err
    questdlg('The settings file for this study is not found or has been corrupted','ERROR','QUIT','Quit');
    fclose('all');
    rethrow(err)
end

parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
stimTest = parData.stimEncode;   
%arrays to save
responseArray = cell(length(stimTest),1);
rtThinkArray = nan(length(stimTest),1);
rtTypingArray = nan(length(stimTest),1);
numCorrect= zeros(length(stimTest),1);
correctArray = nan(length(stimTest),1);
numCorrectAtResponse = nan(length(stimTest),1);
stimOnTime = nan(length(stimTest),1);
pesentationFullList = cell(length(stimTest)*correctReq,2);
responseFullList = cell(length(stimTest)*correctReq,1);

%now we display random words using psycotoolbox
%% boilerplate display settings
ListenChar(2);
HideCursor;
KbName('UnifyKeyNames');
GetSecs;
FlushEvents('keyDown');

%% screen info
[xResolution, yResolution] = Screen('WindowSize',0);
cx = xResolution/2;
cy = yResolution/2;
backColor = 255;
textColor=0;
w = Screen(0,'OpenWindow',backColor);


Screen(w, 'TextFont', 'Arial');
Screen( w, 'TextSize', 24);

% show instructions
Screen(w,'FillRect',backColor);
DrawFormattedText(w, testBlurb,'center','center',textColor);

instructString = 'Please wait for the experimenter to continue...';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+220, textColor);
Screen('Flip',w);

while(1) % wait for s key
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == 's')
        cheatWord = false;
        break;
    elseif (temp == '=')
        cheatWord = true;
        speedup=100;
        break;
    end
end

initTime = Screen('Flip',w); %Changes to next screen

Screen(w, 'TextSize', 72);

% recall words
threshold = 0;
encodeIdx = 0;
stimTicker = 0;
while threshold < requiredThreshold
    encodeIdx = encodeIdx + 1;
    [stimTest,shuffleIndexs] = shuffle(stimTest);
    
    for t=1:length(stimTest)
        wRow = strcmp(stimTest{t,1},parData.stimEncode(:,1));
        if numCorrect(wRow) >= correctReq %dont show if we have reached 2 correct for this pair
            continue;
        end
        stimTicker = stimTicker+1;
        FlushEvents('keyDown');

        wordUser = ''; %reset response word
        wordDisp = stimTest{t,1};
        wordRecall = stimTest{t,2};
         
        %wait a bit between words
        Screen('Flip',w);
        WaitSecs(testBetweenStimDuration/speedup);

        if stem
            %draw stem if nessary
            DrawFormattedText(w,stimTest{t,3}, 'center',cy-120, textColor);
        else
            %draw prompt word
            DrawFormattedText(w,wordDisp,'center','center', textColor);
            timeCueWord = Screen('Flip',w);
            %Wait and then draw astrix
            FlushEvents('keyDown');
            [timeStartWord,key] = KbWait([],0,GetSecs()+testStimDuration/speedup);
            wordUser = KbName(key);
        end
        
        if isempty(wordUser)
            DrawFormattedText(w,'*', 'center','center', textColor);
            Screen('Flip',w);
            [timeStartWord,key] = KbWait;
            wordUser = KbName(key);
        end
        if strcmp(wordUser,'Return')
            wordUser = '';
        end
        DrawFormattedText(w,wordUser, 'center','center', textColor);
        Screen('Flip',w);
        newWord = false;           
        
        while(1) % wait for user input
            FlushEvents('keyDown');
%             if strcmp(wordUser,'Return')
%                 wordUser = '';
%             end
            ch = GetChar;
            if (ch == 8) %backspace
                if ~isempty(wordUser)
                    wordUser = wordUser(1:(end-1));
                    if ~isempty(wordUser)
                        if stem
                            DrawFormattedText(w,stimTest{wRow,3}, 'center',cy-120, textColor);
                        end
                        DrawFormattedText(w,wordUser, 'center','center', textColor);
                        Screen('Flip',w); 
                    else
                        if stem
                            DrawFormattedText(w,stimTest{wRow,3}, 'center',cy-120, textColor);
                        end
                        Screen('Flip',w); 
                    end
                end
            elseif (ch == 13 || ch == 10) %enter
                %check if they have typed enought
                if length(wordUser) < 3 %we consider 3 words or more to be 'trying'
                    if ~isempty(wordUser)
                        if stem
                            DrawFormattedText(w,stimTest{wRow,3}, 'center',cy-120, textColor);
                        end
                        DrawFormattedText(w,wordUser, 'center','center', textColor);
                    end
                    DrawFormattedText(w,'Please attempt an answer', 'center',cy+40, [255 0 0]);
                    Screen('Flip',w); 
                else
                    %save all the disp data in arrays
                    timeComplete = Screen('Flip',w);
                    if ~newWord %stop error on simple enter press 
                        rtThinkArray(wRow,encodeIdx) = timeStartWord-timeCueWord;
                        rtTypingArray(wRow,encodeIdx) = timeComplete-timeStartWord;
                        stimOnTime(wRow,encodeIdx) = timeCueWord-initTime;                         
                    end
                    responseArray{wRow,encodeIdx} = wordUser;  
                    pesentationFullList(stimTicker,:) = stimTest(t,:); 
                    responseFullList{stimTicker} = wordUser; 
%                       responseArray{trial,1} = wordUser;

                    if feedback %give the user the correct word if required
                        %test for correctness here
                        if cheatWord
                            trialCorrect = strcmp(wordUser, 'ass');    
                        else
                            trialCorrect = strcmp(wordUser, wordRecall);
                        end
                        if trialCorrect
                            numCorrect(wRow) = numCorrect(wRow) + 1;
                            correctArray(wRow,encodeIdx) = 1;
                            numCorrectAtResponse(wRow,encodeIdx) = sum(numCorrect); %the number of words not finished
                            correctBlurb = 'Correct! The correct pairing is:\n';
                        else
                            correctArray(wRow,encodeIdx) = 0;
                            correctBlurb = 'Incorrect! The correct pairing is:\n';
                        end
                        DrawFormattedText(w,correctBlurb, 'center','center', textColor);
                        DrawFormattedText(w,wordDisp, 'center',cy+30, textColor);
                        DrawFormattedText(w,wordRecall, 'center',cy+90, textColor);
                        Screen('Flip',w);
                        WaitSecs(testFeedbackDuration/speedup);
                    end

                    break; %break and do next test word
                end
            else
                %add char to word (if its a letter)
                if isletter(ch)
                    if stem
                        DrawFormattedText(w,stimTest{wRow,3}, 'center',cy-120, textColor);
                    end
                    wordUser = sprintf('%s%s',wordUser,ch);
                    DrawFormattedText(w,wordUser, 'center','center', textColor);
                    timeTyping = Screen('Flip',w);
                    if newWord
                        newWord = false;
                    end
                end
            end
        end
    end
    threshold = round(100*sum(numCorrect>=correctReq)/length(numCorrect));
    if threshold < requiredThreshold
        DrawFormattedText(w,'Lets try that again.', 'center','center', textColor);
    else
        break;
    end
    
    correctArray = [correctArray nan(length(correctArray),1)];
    numCorrectAtResponse = [numCorrectAtResponse nan(length(correctArray),1)];
    responseArray = [responseArray cell(length(responseArray),1)];
    rtThinkArray = [rtThinkArray nan(length(correctArray),1)];
    rtTypingArray = [rtTypingArray nan(length(correctArray),1)];
    stimOnTime = [stimOnTime nan(length(stimOnTime),1)];
    
    Screen('Flip',w);
    WaitSecs(2/speedup);
end

%clean up and go home
Screen( w, 'TextSize', 24);
instructString = 'Thank you for participating';
DrawFormattedText(w, instructString,'center','center',textColor);
Screen('Flip',w);
WaitSecs(1);

%training finished sucessfully so save the responselist
%with some variable names based on test session.
%depending on the session id we will ither add the first training data or
%add more training data to exisiting data from test session 1
parData.(sprintf('responseArray%i',testID)) = responseArray;
parData.(sprintf('rtThinkArray%i',testID)) =  rtThinkArray;
parData.(sprintf('rtTypingArray%i',testID)) =  rtTypingArray;
parData.(sprintf('numCorrectAtResponse%i',testID)) =  numCorrectAtResponse;
parData.(sprintf('correctArray%i',testID)) =  correctArray;
parData.(sprintf('numCorrect%i',testID)) = numCorrect;
parData.(sprintf('stimOnTime%i',testID)) = stimOnTime;
parData.(sprintf('pesentationFullList%i',testID)) = pesentationFullList;
parData.(sprintf('responseFullList%i',testID)) = responseFullList;

save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');
writetable(recursiveNestedStruct2Table(parData),sprintf('Data/Incomplete/%s_Sub%i_Visit%i_Test%iData.csv',studyID,subjectID,visitID,testID))

ListenChar(1);
ShowCursor;
sca;
fclose('all');

catch err
    ListenChar(1);
    ShowCursor;
    sca;
    fclose('all');
    rethrow(err)
end
end
