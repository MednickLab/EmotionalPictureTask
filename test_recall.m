function test_recall(studyID,subjectID,visitID,testID,feedback,stem)%Take human input to decide which version to run and what session
%if 1 %to run not as a function
%Runs a testing session of pretrained words from the WPA tast for all studys.
%Test data is pulled from a participants file
%Words are displayed, and the user must input on screen using psychtoolbox
%@Params: studyID - Name of study (to load setting file)
%@Params: subjectID - Unique subject number
%@Params: testID - which test to run (first, second etc)
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 20/12/14
try
Screen('Preference', 'SkipSyncTests', 1)

%studyID='WPA_SF1'; subjectID=1; testID=1; visitID=1; feedback=1; stem=0;%to run not as a function

speedup = 1; % acceleration factor for debugging (default=1)

try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID));
    testBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'testBetweenStimDuration')});
    testStimDuration = str2double(settings{3,strcmp(settings(1,:),'testStimDuration')});
    testBlurb = settings{3:end,strcmp(settings(1,:),sprintf('test%iBlurb',testID))};
    if feedback
        testFeedbackDuration = str2double(settings{3,strcmp(settings(1,:),'testFeedbackDuration')});
    end
catch err
    questdlg('The settings file for this study is not found or has been corrupted','ERROR','QUIT','Quit');
    fclose('all');
    rethrow(err)
end

parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
stimTest = parData.(sprintf('stimTest%i',testID));   
%arrays to save
responseArray = cell(length(stimTest),1);
rtThinkArray = cell(length(stimTest),1);
rtTypingArray = cell(length(stimTest),1);

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
Screen('GetFlipInterval', w, 100, 0.00005, 3);

Screen(w, 'TextFont', 'Courier New');
Screen( w, 'TextSize', 25);

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
        break;
    end
end

Screen('Flip',w); %Changes to next screen

Screen( w, 'TextSize', 72);

% recall words
for trial=1:length(stimTest)
    FlushEvents('keyDown');

    wordUser = ''; %reset response word
    wordDisp = stimTest{trial,1};
    wordRecall = stimTest{trial,2};

    %wait a bit between words
    Screen('Flip',w);
    WaitSecs(testBetweenStimDuration/speedup);
 
    if stem
        %draw stem if nessary
        DrawFormattedText(w,stimTest{trial,3}, 'center',cy-120, textColor);
    else
        %draw prompt word
        DrawFormattedText(w,wordDisp,'center','center', textColor);
        Screen('Flip',w);
        %Wait and then draw astrix
        WaitSecs(testStimDuration/speedup);
    end
    
    DrawFormattedText(w,'*', 'center','center', textColor);
    timeAstrix = Screen('Flip',w);
    newWord = true;

    while(1) % wait for user input
        FlushEvents('keyDown');
        ch = GetChar;           
        if (ch == 8) %backspace
            if ~isempty(wordUser)
                wordUser = wordUser(1:(end-1));
                if ~isempty(wordUser)
                    if stem
                        DrawFormattedText(w,stimTest{trial,3}, 'center',cy-120, textColor);
                    end
                    DrawFormattedText(w,wordUser, 'center','center', textColor);
                    Screen('Flip',w); 
                else
                    if stem
                        DrawFormattedText(w,stimTest{trial,3}, 'center',cy-120, textColor);
                    end
                    Screen('Flip',w); 
                end
            end
        elseif (ch == 13 || ch == 10) %enter
            %check if they have typed enought
            if length(wordUser) < 3 %we consider 3 words or more to be 'trying'
                if ~isempty(wordUser)
                    if stem
                        DrawFormattedText(w,stimTest{trial,3}, 'center',cy-120, textColor);
                    end
                    DrawFormattedText(w,wordUser, 'center','center', textColor);
                end
                DrawFormattedText(w,'Please attempt an answer', 'center',cy+40, [255 0 0]);
                Screen('Flip',w); 
            else
                %save all the disp data in arrays
                timeComplete = Screen('Flip',w);
                if ~newWord %stop error on simple enter press 
                    rtThinkArray{trial,1} = timeStartWord-timeAstrix;
                    rtTypingArray{trial,1} = timeComplete-timeStartWord;
                end
                responseArray{trial,1} = wordUser;  
                
% %                 if feedback %give the user the correct word if required
% %                     DrawFormattedText(w,wordRecall, 'center','center', [0 255 0]);
% %                     Screen('Flip',w);
% %                     WaitSecs(testFeedbackDuration/speedup);
% %                 end
                
                break; %break and do next test word
            end
        else
            %add char to word (if its a letter)
            if isletter(ch)
                if stem
                    DrawFormattedText(w,stimTest{trial,3}, 'center',cy-120, textColor);
                end
                wordUser = sprintf('%s%s',wordUser,ch);
                DrawFormattedText(w,wordUser, 'center','center', textColor);
                timeTyping = Screen('Flip',w);
                if newWord
                    timeStartWord = timeTyping;
                    newWord = false;
                end
            end
        end
    end
end
%clean up and go home
instructString = 'Thank you for participating. Please ring the bell.';
Screen( w, 'TextSize', 25);
DrawFormattedText(w, instructString,'center','center',textColor);
Screen('Flip',w);
WaitSecs(5);

%training finished sucessfully so save the responselist...
%form some variable names based on test session...
responseArrayName = sprintf('responseArray%i',testID);
rtThinkArrayName = sprintf('rtThinkArray%i',testID);
rtTypingArrayName = sprintf('rtTypingArray%i',testID);

%depending on the session id we will ither add the first training data or
%add more training data to exisiting data from test session 1
parData.(responseArrayName) = responseArray;
parData.(rtThinkArrayName) =  rtThinkArray;
parData.(rtTypingArrayName) =  rtTypingArray;

save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');
struct2csv(parData,sprintf('Data/Incomplete/%s_Sub%i_Visit%i_Test%iData.csv',studyID,subjectID,visitID,testID))

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
