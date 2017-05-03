function shuffledArray = shuffle(arrayIn)
%randomly shuffles arrayIn (cell or num array) or cols of array in if
%matrix
    [rows,cols] = size(arrayIn);
        shuffleIndex = randperms(length(arrayIn),length(arrayIn));
    if rows > cols
        shuffledArray = arrayIn(shuffleIndex,:);
    else
        shuffledArray = arrayIn(:,shuffleIndex);
    end
end