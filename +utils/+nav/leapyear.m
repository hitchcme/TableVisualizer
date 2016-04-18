function ly = leapyear(year)

    ly = ~(rem(year,4) ~= 0);