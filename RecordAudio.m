
%Record needed records.

% Create an audio recorder object with specified parameters
recObj = audiorecorder(44100, 24, 1);  % Record at Fs = 44.1 kHz, 24 bits per sample

for i = 1:10

% Prompt the user to start speaking and record for 2 seconds
fprintf('Start speaking for audio recording...\n')
recordblocking(recObj, 2);  
fprintf('Audio recording completed.\n')

% Retrieve the recorded audio data
y = getaudiodata(recObj);

% Ensure zero mean for the audio data
y = y - mean(y);

% Define the file name and save the recorded audio as a WAV file
file_name = sprintf('DSP_Assignment/Train/Female/no%d.wav',i);
audiowrite(file_name, y, recObj.SampleRate);

end


for i = 1:10

% Prompt the user to start speaking and record for 2 seconds
fprintf('Start speaking for audio recording...\n')
recordblocking(recObj, 2);  
fprintf('Audio recording completed.\n')

% Retrieve the recorded audio data
y = getaudiodata(recObj);

% Ensure zero mean for the audio data
y = y - mean(y);

% Define the file name and save the recorded audio as a WAV file
file_name = sprintf('DSP_Assignment/Train/Male/no%d.wav',i);
audiowrite(file_name, y, recObj.SampleRate);

end


for i = 1:10

% Prompt the user to start speaking and record for 2 seconds
fprintf('Start speaking for audio recording...\n')
recordblocking(recObj, 2);  
fprintf('Audio recording completed.\n')

% Retrieve the recorded audio data
y = getaudiodata(recObj);

% Ensure zero mean for the audio data
y = y - mean(y);

% Define the file name and save the recorded audio as a WAV file
file_name = sprintf('DSP_Assignment/Test/Female/no%d.wav',i);
audiowrite(file_name, y, recObj.SampleRate);

end


for i = 1:10

% Prompt the user to start speaking and record for 2 seconds
fprintf('Start speaking for audio recording...\n')
recordblocking(recObj, 2);  
fprintf('Audio recording completed.\n')

% Retrieve the recorded audio data
y = getaudiodata(recObj);

% Ensure zero mean for the audio data
y = y - mean(y);

% Define the file name and save the recorded audio as a WAV file
file_name = sprintf('DSP_Assignment/Test/Male/no%d.wav',i);
audiowrite(file_name, y, recObj.SampleRate);

end
