function [keycode RT] = KbWaitUntil(t0, timeout)
% returns keycode if response came in time.  Return is on response.
% If no response in time, returns 0
% RT is given relative to t0
KbClear();
%t0 = GetSecs();
RT = 0;
keycode = 0;
t1 = GetSecs();
while (t1 < (t0 + timeout))
    [ keypressed, check_time, keycode ] = KbCheck();
    if (keypressed)
        RT = check_time - t0;
        break;
    end
    t1 = check_time;
    WaitSecs(0.005); % Wait 5ms, nicely
end

if (RT == 0) keycode = 0;
else keycode = find(keycode);
end

KbClear();
