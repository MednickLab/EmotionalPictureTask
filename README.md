# Generic Memory Task
Generic MATLAB/Psychtoolbox code to run a variety of memory tasks. Can be used to create Word Pair Associates task, Emotional Picture Task, and many more. Handles images, words and word pairs as stimulus. Handles recognition and recall (words only) memory tests.
The general structure consists of:
- a "Train"/"Encoding" session, where stim are presented to a subject one at a time (or pairs)
- a "Test"/"Recognition" session/s, where previously preseted stim are shown again and subjects are asked to make a memory judgement

# Features:
 - pop up input dialogs to enter subject id, session id, or other parameters
 - a script to check if data already exists, and warn if anything will be overwritten
 - The ability to train to a threshold accuracy before ending the training settion
 - Crosshairs for subjects to focus on
 - Auto saving of files if some error occurs
 - Stats automatically calculated (accuracy, dprime, etc) and saved to CSV file
 - Modifiable word, image lists
 - For pairs of images/words, the ability to present side by side and sequentually
 - Modifiable stim timing settings
 - Stem completion for words
 - Recall and recognition based test sessions
 - Feedback during training or test
 - Automatically pull correct stimulus set for subject from a counterbalence file
 - pressing "s" key at instructions starts normal, pressing "=" key will speed through everything (useful for debug)
 
 # Pre-Packaged Examples
 ## Word Pair Associates
 - Encoding + two test sessions
 - Was designed for ERPs, so focus cross is pail and constant, and screen is black
 - Stim are word pairs, and they are tested at test as intact (same as in encoding), rearanged (old words, but new pairing), new (both words new)
 - Participants are allowed to take a break every x word pairs
 - Test sessions are recognition (old/new) and w. confidence
 - Word pairs are presented sequentually + a blink break between word pairs
 - Stats are calculated for each sub (dprime - although this is a little weird because there are 3 options - intact, rearranged, new)

## EPT
- 
 
