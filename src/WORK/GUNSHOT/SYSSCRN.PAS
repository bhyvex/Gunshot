{$I DEFINES.INC}
UNIT SysScrn;


INTERFACE


PROCEDURE show_last_Callers;
PROCEDURE Show_User_Specific;
PROCEDURE ShowLastComment;
PROCEDURE do_news;
PROCEDURE do_welcome;
PROCEDURE do_once_only;
PROCEDURE do_user_access;
PROCEDURE do_date_specific;
PROCEDURE do_birthday;


IMPLEMENTATION


USES Screens,BsLog,KeyInput,SBuffer,Globals,ANSIMisc,
     Time,Dates,BsString,BsFile,BsTime;


PROCEDURE do_welcome;
VAR
     loop       : word;
     do_welcome_temp : string;
BEGIN
     FOR loop := 0 to 9 DO
     BEGIN
          STR(loop,do_welcome_temp);
          IF loop=0 THEN do_welcome_temp := '';
          IF DisplayGraphicsFile('WELCOME'+do_welcome_temp,true,false,True,False,False) THEN
          BEGIN
               bsWriteLog('Reading welcome screen #'+_String(Loop),False);
               Get_Enter;
          END;
     END;
END;


PROCEDURE Show_User_Specific;
VAR  Temp : String;
BEGIN
     Temp := _String(UserRecord.User_Number);
     IF DisplayGraphicsFile('USR'+temp,true,false,True,False,False) THEN
     BEGIN
          bsWriteLog('Reading user specific screen',False);
          Get_Enter;
     END;
END;


PROCEDURE do_once_only;
VAR  loop       : word;
     temp       : string;
     FilesDate  : Longint;
     Working    : Longint;
BEGIN
     FOR loop := 0 to 9 DO
     BEGIN
       STR(loop,temp);
       IF loop=0 THEN temp := '';
       IF ((IsRip) AND (_FileExists(ANSIDirectory+'\ONCE'+temp+'.RIP'))) THEN
       BEGIN
         FilesDate := _FileDate(ANSIDirectory+'\ONCE'+temp+'.RIP');
         IF FilesDate<>0 THEN
         BEGIN
           IF FilesDate>RealLastCall THEN
           BEGIN
             IF DisplayGraphicsFile('ONCE'+temp,true,false,True,False,False) THEN
             BEGIN
               bsWriteLog('Reading once-only screen #'+_String(Loop),False);
               Get_Enter;
             END;
           END;
         END;
       END
       ELSE
       BEGIN
          IF _FileExists(ANSIDirectory+'\ONCE'+temp+'.ANS') THEN
          BEGIN
            FilesDate := _FileDate(ANSIDirectory+'\ONCE'+temp+'.ANS');
            IF FilesDate<>0 THEN
            BEGIN
              IF FilesDate>RealLastCall THEN
              BEGIN
                IF DisplayGraphicsFile('ONCE'+temp,true,false,True,False,False) THEN
                BEGIN
                  bsWriteLog('Reading once-only screen #'+_String(Loop),False);
                  Get_Enter;
                END;
              END;
            END;
          END;
       END;
     END;
END;


PROCEDURE show_last_callers;
VAR  loop : Word;
     temp : string;
BEGIN
     IF _FileExists(DATA_Directory+'\LASTCALL.DAT') THEN
     BEGIN
          bsWriteLog('Viewing the last callers to the system',False);
          ASSIGN(FCallers,DATA_Directory+'\LASTCALL.DAT');
          RESET(FCallers);
          FOR loop := 1 TO 10 DO READ(FCallers,Callers[loop]);
          CLOSE(FCallers);
          ClearBuffer;
          FOR Loop := 1 TO 10 DO
          BEGIN
               Temp := _String(Loop);
               IF Length(Temp)=1 THEN Temp := '0'+Temp;
               CASE Names.LastCall OF
               0:   AddToBuffer('@USERSNAME'+Temp,callers[Loop].Name);
               1:   IF callers[Loop].Alias=''
                       THEN AddToBuffer('@USERSNAME'+Temp,callers[Loop].Name)
                       ELSE AddToBuffer('@USERSNAME'+Temp,callers[Loop].Alias);
               END;
               AddToBuffer('@USERSLOCATION'+Temp,callers[Loop].City);
               IF Callers[Loop].Baud='0'
                  THEN AddToBuffer('@B'+Temp,'LOCAL')
                  ELSE AddToBuffer('@B'+Temp,callers[Loop].Baud);
          END;
          AddToBuffer('@TCALLS',_String(totals.total_calls));
          AddToBuffer('@CALLST',_String(totals.today_calls));
          IF DisplayGraphicsFile('LASTCALL',True,True,True,True,False) THEN Get_Enter;
     END;
END;


PROCEDURE ShowLastComment;
BEGIN
     IF _FileExists(INTR_Directory+'\COMMENT.MSG') THEN
     BEGIN
          bsWriteLog('Viewing a comment from the last caller',False);
          ASSIGN(FCommentToNext,INTR_Directory+'\COMMENT.MSG');
          RESET(FCommentToNext);
          READ(FCommentToNext,CommentToNext);
          CLOSE(FCommentToNext);
          ERASE(FCommentToNext);
          ClearBuffer;
          CASE Names.LastComm OF
          0:   AddToBuffer('@USERSNAME',CommentToNext.UserName);
          1:   IF CommentToNext.UserAlias=''
                  THEN AddToBuffer('@USERSNAME',CommentToNext.UserName)
                  ELSE AddToBuffer('@USERSNAME',CommentToNext.UserAlias);
          END;
          AddToBuffer('@COMMENTFROMLASTCALLER',CommentToNext.Line);
          IF DisplayGraphicsFile('LASTCOMM',True,True,True,True,False) THEN
          BEGIN
               SendCrLf(1);
               Get_Enter;
               SendCrLf(2);
          END;
     END;
END;


PROCEDURE do_news;
VAR  loop         : word;
     loop2        : word;
     loop3        : word;
     news_file    : text;
     do_news_temp : string[12];
     Temp         : String;
     TheDate      : String[20];
BEGIN
     FOR loop := 1 to 9 DO
     BEGIN
          STR(loop,do_news_temp);
          IF _FileExists(NEWS_Directory+'\NEWS'+do_news_temp+'.TXT') THEN
          BEGIN
               bsWriteLog('Reading news screen #'+_String(Loop),False);
               loop2 := 0;
               ClearBuffer;
               TheDate := TranslateDate1(_UnpackedDate(_FileDate(News_Directory+'\NEWS'+do_news_temp+'.TXT')));
               AddToBuffer('@DATE',TheDate);
               ASSIGN(news_file,News_Directory+'\NEWS'+do_news_temp+'.TXT');
               RESET(news_file);
               READLN(news_file,Temp);
               AddToBuffer('@NEWSTITLE',Temp);
               REPEAT
                     INC(loop2);
                     READLN(news_file,Temp);
                     Do_News_Temp := _String(Loop2);
                     IF Length(Do_News_Temp)=1 THEN Do_News_Temp := '0'+Do_News_Temp;
                     AddToBuffer('@LINE'+Do_News_Temp,Temp);
               UNTIL EOF(news_file);
               CLOSE(news_file);
               IF DisplayGraphicsFile('NEWS',True,True,True,True,False) THEN get_enter;
          END;
     END;
END;


PROCEDURE do_user_access;
VAR  TheirAccess : String;
BEGIN
     TheirAccess := _String(UserRecord.Security);
     IF DisplayGraphicsFile('UA'+TheirAccess,true,false,True,False,False) THEN
     BEGIN
          bsWriteLog('Reading user access screen #'+TheirAccess,False);
          Get_Enter;
     END;
END;


PROCEDURE do_date_specific;
VAR  Temp     : String;
     TheDate  : String;
     TheYear  : String[2];
     TheMonth : String[2];
     TheDay   : String[2];
     Loop     : Word;
BEGIN
     TheDate  := _MMDDYYYY;
     TheYear  := _Mid(TheDate,9,10);
     TheMonth := _Mid(TheDate,1,2);
     TheDay   := _Mid(TheDate,4,5);
     FOR Loop := 1 TO 8 DO
     BEGIN
          CASE Loop OF
          1:   Temp := TheMonth+TheDay+TheYear;
          2:   Temp := '00'+TheDay+TheYear;
          3:   Temp := TheMonth+'00'+TheYear;
          4:   Temp := TheMonth+TheDay+'00';
          5:   Temp := '00'+TheDay+'00';
          6:   Temp := '00'+'00'+TheYear;
          7:   Temp := TheMonth+'00'+'00';
          8:   Temp := '000000';
          END;
          IF DisplayGraphicsFile(Temp,true,false,True,False,False) THEN
          BEGIN
               bsWriteLog('Reading date specific screen :'+Temp,False);
               Get_Enter;
          END;
     END;
END;


PROCEDURE do_birthday;
VAR  Temp     : String;
     TheDate  : String;
     TheMonth : String[2];
     TheDay   : String[2];
BEGIN
     TheDate  := _MMDDYYYY;
     TheMonth := _Mid(TheDate,1,2);
     TheDay   := _Mid(TheDate,4,5);
     IF _Mid(UserRecord.birth,1,2)=TheMonth THEN
     BEGIN
          IF _Mid(UserRecord.birth,3,4)=TheDay THEN
          BEGIN
               IF DisplayGraphicsFile('BIRTHDAY',true,false,True,False,False) THEN
               BEGIN
                    bsWriteLog('Reading happy birthday screen!!',False);
                    Get_Enter;
               END;
          END;
     END;
END;


END.
