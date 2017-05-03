function train_singleImageWithResponse(studyID,subjectID,visitID)
%if 1 %to run not as a function
%clear
%Runs the training words/images pairs of the WPA/PPT/EPT tasks for all studys.
%Images data are pulled from the corresponding folder to imageListID
%words are pulled from worlist csv file
%Stims are randomised and displayed on screen using psychtoolbox
%@Author: Ben Yetton
%@Property: Mednick Lab, UC Riverside
%@Date Created: 15/1/15
Screen('Preference', 'SkipSyncTests', 1);
path('StarkLabPToolboxFuncs',path);  % Add subdir w/toolbox funcs to path
try %try/catch for clean kill
%studyID='EPT_PSTIM1'; subjectID=1; stimListID=2;visitID=1;%to run not as a function

speedup = 1; % acceleration factor for debugging (default=1)
   
%load study settings
try 
    settings = csvimport(sprintf('Study_Settings_%s.csv',studyID),'outputAsChar',true);
    trainBetweenStimDuration = str2double(settings{3,strcmp(settings(1,:),'trainBetweenStimDuration')});
    trainStimDuration = str2double(settings{3,strcmp(settings(1,:),'trainStimDuration')});
    trainBlurb = settings(3,strcmp(settings(1,:),'trainBlurb'));
    encodingInstructionBlurb = settings(3:end,strcmp(settings(1,:),'encodingInstructionBlurb'));
    encodingInstructionBlurb = encodingInstructionBlurb(~cellfun('isempty',encodingInstructionBlurb)); %remove any empty cells (artifact of bad csv import)
    aceptableAns = settings(3:end,strcmp(settings(1,:),'encodingResponses'));
    aceptableAns = aceptableAns(~cellfun('isempty',aceptableAns)); %remove any empty cells (artifact of bad csv import)
    useImages = str2double(settings(3,strcmp(settings(1,:),'useImages')));
catch err
    menu('The settings file or images folder for this study is not found or has been corrupted','Quit');
    fclose('all');
    rethrow(err)
end

%load par data (or try anyways)
parData = load(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID));
 
%%We now have all out stim setup so can start psychtoolbox
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
w = Screen(0,'OpenWindow',backColor);%,ScreenRect,32);
slack = Screen('GetFlipInterval', w, 100, 0.00005, 3)/2;
Screen(w, 'TextFont', 'Arial');
Screen( w, 'TextSize', 18);   

imageSize = 300;

imageRect = [];
sideoffset=220;
imageCenterRect = [cx-imageSize/2,cy-imageSize/2,cx+imageSize/2,cy+imageSize/2];
imageLeftRect = [cx-imageSize/2-sideoffset,cy-imageSize/2,cx+imageSize/2-sideoffset,cy+imageSize/2];
imageRightRect = [cx-imageSize/2+sideoffset,cy-imageSize/2,cx+imageSize/2+sideoffset,cy+imageSize/2];

%now we display random images using psycotoolbox
% show instructions
Screen(w,'FillRect',backColor);
DrawFormattedText(w, trainBlurb{1},'center','center',textColor);

instructString = 'Please wait for the experimenter to continue...';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+200, textColor);
Screen('Flip',w);

while(1) % wait for s key
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == 's')
        break;
    elseif (temp == '=')
        speedup = 100;
        break;
    end
end
Screen('Flip',w); %Changes to next screen

%load image textures (out of main loop to save cpu power in main loop)
if useImages
    imageTextures = cell(size(parData.stimTraining));
    try 
        for i=1:length(parData.stimTraining)
            imageTextures{i} = Screen('MakeTexture',w,imread(parData.stimTraining{i}));
        end
    catch err
        disp('Error in loading images');
        fclose('all');
        rethrow(err)
    end
end

FlushEvents('keyDown');
Screen(w, 'TextSize', 18);
Screen(w,'FillRect',backColor);

trainResponseArray = cell(size(parData.stimTraining));
trainRtArray = zeros(length(parData.stimTraining),1);

% show words
for trial=1:length(parData.stimTraining) 
   
    %%get image and draw
    if useImages
        Screen('DrawTexture', w, imageTextures{trial,1},[], imageCenterRect);
    else %words
        Screen(w, 'TextSize', 36);
        DrawFormattedText(w,sprintf('%s',parData.stimTraining{trial}),'center','center',[0 0 0]);
        Screen(w, 'TextSize', 18);
    end 
    FlushEvents('keyDown'); %clear al keyboard hits
    imageTime = Screen('Flip',w);
    [keycode,rt] = KbWaitUntil(imageTime,trainStimDuration/speedup);  % Wait until keypress or timeout
    trainRtArray(trial) = rt;   
    if keycode
        keyPressed = KbName(keycode); 
        if (strcmp(keyPressed,'ESCAPE')) break; end % ESC hit
        trainResponseArray{trial} = keyPressed(1);
    else
        trainResponseArray{trial} = 'NR';
    end   
    if (trainRtArray(trial)) WaitUntil(imageTime + trainStimDuration/speedup); end % If response made, wait until end of trial.  (on timeout, already there)
       
    %Time between Images...
    blankTime = Screen(w,'Flip');  % Clear screen
    if ~trainRtArray(trial)
        [keycode,rt] = KbWaitUntil(blankTime,trainBetweenStimDuration/speedup);
        trainRtArray(trial) = trainStimDuration + rt;   
        if keycode
            keyPressed = KbName(keycode); 
            if (strcmp(keyPressed,'ESCAPE')) break; end % ESC hit
            trainResponseArray{trial} = keyPressed(1);
        else
            trainResponseArray{trial} = 'NR';
        end
        if (trainRtArray(trial)) WaitUntil(blankTime + trainBetweenStimDuration/speedup); end % If response made, wait until end of trial.  (on timeout, already there)
    else
        WaitUntil(blankTime + trainBetweenStimDuration/speedup)
    end
    %WaitSecs(trainStimDuration/speedup);
    
    %the are asked 3 encoding questions so loop through all
%     for ansIndex = 1:length(encodingInstructionBlurb)
%         %%draw instrcutions
%         DrawFormattedText(w,encodingInstructionBlurb{ansIndex},'center','center',[0 0 0]);
%         timeEncodeBlurb = Screen('Flip',w);
%         while(1) % wait for user input
%             FlushEvents('keyDown');
%             ch = GetChar;
%             if(ismember(ch,aceptableAns))
%                 trainResponseArray{trial,ansIndex} = ch;
%                 %wait a bit between images
%                 timeComplete = Screen('Flip',w);
%                 WaitSecs(trainBetweenStimDuration/speedup);
%                 trainRtArray{trial,ansIndex} = timeComplete-timeEncodeBlurb;
%                 break;
%             end
%         end
%     end
%     Screen('Flip',w);
%     WaitSecs(trainBetweenStimDuration/speedup);
%     ch = GetChar;
%     trainResponseArray{trial,1} = ch;
end

instructString = 'Thank you. You have now finished training';
boundRect = Screen('TextBounds', w, instructString);
Screen('drawtext',w,instructString, cx-boundRect(3)/2, cy-boundRect(4)/5+200, textColor);
Screen('Flip',w);
WaitSecs(2)

parData.('trainResponseArray') = trainResponseArray;
parData.('trainRtArray') = trainRtArray;

save(sprintf('Data/Incomplete/%s_Sub%i_Visit%i',studyID,subjectID,visitID),'-struct','parData');

%clean up and go home 
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
