function KbClear()
% Could also do FlushEvents
while KbCheck; end % Wait until all keys are released.