{$I DEFINES.INC}
UNIT WhatLine;


INTERFACE


FUNCTION is_quote(in_string: string): boolean;
FUNCTION is_tear(in_string: string): boolean;


IMPLEMENTATION


FUNCTION is_quote(in_string: string): boolean;
VAR  Work : word;
BEGIN
     Work := Pos('>',In_String);
     IF Pos('<',In_String)<>0 THEN
     BEGIN
          IF Pos('<',In_String)<Work THEN Work := 0;
     END;
     IF ((Work<>0) AND (Work<9)) THEN is_quote := True
                                 ELSE is_quote := False;
END;


FUNCTION is_tear(in_string: string): boolean;
VAR  is_tear_loop        : word;
BEGIN
     is_tear_loop := Pos('--- ',In_String);
     IF Is_Tear_Loop=1 THEN
     BEGIN
          Is_Tear := True;
          Exit;
     END;
     is_tear_loop := Pos(' * Origin: ',In_String);
     IF Is_Tear_Loop=1 THEN
     BEGIN
          Is_Tear := True;
          Exit;
     END;
     IF In_String='---' THEN
     BEGIN
          Is_Tear := True;
          Exit;
     END;
     IF In_String[1]=#1 THEN
     BEGIN
          Is_Tear := True;
          Exit;
     END;
     is_tear_loop := Pos('SEEN-BY: ',In_String);
     IF Is_Tear_Loop=1 THEN
     BEGIN
          Is_Tear := True;
          Exit;
     END;
     Is_Tear := False;
END;


END.