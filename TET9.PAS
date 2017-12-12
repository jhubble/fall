PROGRAM FALL; (*  a tetris clone - Jeremy Hubble, Brandon Whittle - 4/14/92  *)

USES CRT,DOS;       (*  only dos used is 'gettime' to set clock speed...  *)





CONST

   NUMBER_OF_SHAPES=7;           (*  Number of different shapes  (excluding rotations)  *)

   BLOCK_ASC=176;                (*  constant ASCII code for blocks  *)
   BLOCK=CHR(BLOCK_ASC);         (*  character for block  *)
   DRAW=BLOCK;                   (*  I'm lazy!  *)

   ERASE_ASC=32;                 (*  constant to erase the block  *)
   ERASE=CHR(ERASE_ASC);         (*  character code to erase the block  *)

{   INIT_X = 40;                  (*  initial values for X and Y *)  }
   INIT_Y = 4;

   DB_INIT = 50;                 (*  increment value for drop bonus  *)
   LEFT_BORD = 34;                (*  constants for left and right borders  *)
   RIGHT_BORD = 45;
   BORDER_ASC = 212;
   BORDER_CHAR = CHR(BORDER_ASC);


(*  shape constants  *)
(*  constants assumed to be on grid:
      ABCm
      DEFn
      GHIo
      JKLp
    and are written ABCmDEFnGHIoJKLp due to pascals string constant line limit  *)

   SHAPE : ARRAY[1..NUMBER_OF_SHAPES] OF STRING = ('1000100010001000',    (*  ++++  *)


                                    '1000100011000000',    (*     +
                                                               +++  *)

                                    '1000100011000000',    (*   +
                                                                +++  *)

                                    '1100110000000000',    (*   ++
                                                                ++   *)

                                    '0100110001000000',    (*    +
                                                                +++  *)

                                    '1000110001000000',    (*    ++
                                                                ++   *)

                                    '0100110010000000');   (*   ++
                                                                 ++  *)



INIT_X = LO(TRUNC((RIGHT_BORD + LEFT_BORD)/2));

type
   STUFF = (TETRIS,ROW_CLEAR,LEVEL_UP);            (*  for sound procedure  *)

   SCORE_LIST = RECORD                             (*  record to score the high score list  *)
        H_NAME : STRING[25];
        H_SCORE : REAL;
        H_LEVEL : INTEGER;
        H_ROWS : INTEGER;
   END;



VAR
   INIT_SPEED : INTEGER;    (* The speed to start out at and to base all
                            (* level junk off *)
   INSTRUCT,JOHNNY:TEXT;  (*Text file which contains instructions for operating*)
   INSTRUCTIONS:STRING; (*Var to hold instruct*)
   BEGGER:TEXT;    (*Text file that contains a plea for money. *)
   BEG:STRING; (*Var to hold the begger *)
   X,Y : BYTE;
   BLOCK_CHAR,KEY : CHAR;
   LCV,SPEED,ROW,COL : INTEGER;          (*  loop control variable  *)
   MONSTER : ARRAY [1..25,1..80] OF BOOLEAN;    (*  array to keep track of where screen is  *)
   SCORE : REAL;                         (*  The points you've got  *)
   DROP_BONUS : INTEGER;                 (*  bonus for multiple drops  *)
   SHAPE_NUM : INTEGER;                  (*  number of shape to be dropped  *)
   SHAPE_ROTATE : INTEGER;               (*  rotation version of shape  *)
   SHAPE_BOTTOM : INTEGER;               (*  bottom of shape  *)
   SHAPES : ARRAY [1..NUMBER_OF_SHAPES,1..4] OF STRING; (*  rotated shapes  *)
   COUNT : INTEGER; (* Keeps count of # of rows dissappeared*)
   COMPTYPE : CHAR; (* Type of computer *)
   (*  NOTE:  Array is in the reverse order of the gotoxys  *)
   ANSWER : CHAR;   (* User response *)
   LEVEL:BYTE; (* The level user is currently on*)
   SUPRACOUNT:INTEGER; (* Total lines *)
   FUNKY_ROTATE : INTEGER;   (*  3 - funky, 4 - normal  *)
   HIGH_SCORES : ARRAY[1..10] OF SCORE_LIST;  (*  variable to hold high scores  *)
   DUDE:STRING;  


procedure display_high_scores;   (*  show the list of high scores  *)
  var
     lcv : integer;     (*  LCV to print high score list  *)
     holdme : char;

  begin

     clrscr;            (*  clear screen for neat display  *)
     writeln  ('  The top twenty venturers into the land of textris:  ');
     writeln;
     writeln  ('NAME':15,'SCORE':10,'LEVEL':10,'ROWS':10);


     for lcv := 1 to 20 do
      begin
        with high_scores[lcv] do        (* use the record  *)
          begin
            writeln (h_name:15,h_score:10,h_level:10,h_rows:10);
          end;   (* record use *)
      end;       (*  for loop  *)

      writeln;
      write ('Press any key to continue...');
      holdme := readkey;
      repeat until keypressed;               (*  wait for a keypress  *)
      holdme := readkey;
   end;  (*  display_high_scores procedure  *)





procedure init_high_scores;

var
  lcv : integer;        (*  loop control cariable  *)

begin   (*  add in the file read stuff  here  *)
  for lcv := 1 to 20 do
    with high_scores[lcv] do
      begin
        h_score := 0;
        h_name := '';
        h_level := 0;
        h_rows := 0;
      end;     (*  intitializing high scores  *)
  end;  (*  for loop  *)


procedure is_high_score;           (*  see if the score is the high score  *)

var
  lcv,lcv2 : integer;                (*  loop control variable - duh!!!!  *)
  get_your_name_or_die : string;     (*  enter your name string  *)

begin


  for lcv := 1 to 20 do        (* see if score is greater than other scores  *)
     begin
        (*  SPOT WHERE THE WITH HIGH_SCORES[LCV] DO was before I got mad  *)
        begin
          if (score > HIGH_SCORES[LCV].h_score) then
           begin
             if (lcv <> 20) then        (*  no need to move up everything if you got last place  *)
               begin
                 for lcv2 := 19 downto lcv do           (* start with the bottom, and start copying up to keep scores  *)
                    begin
                       high_scores[lcv2+1] := high_scores[lcv2];  (*  copy the high score to the next lowest location  *)
                    end;                  (*  for (lcv2)  *)
               end;                       (*  if  *)

             writeln ('Yo, dude!  You made a high score!');
             write('Enter your name: ');

             readln (get_your_name_or_die);           (*  read it into recrod  *)


{             GET_YOUR_NAME_OR_DIE := 'FRED';  }

             high_scores[lcv].h_name := get_your_name_or_die;
             high_scores[lcv].h_score := score;          (*  store other stats in record  *)
             high_scores[lcv].h_level := level;
             high_scores[lcv].h_rows := row;

           end;     (*  if (score > h_score  *)
        end;        (*  with record  *)
     end;           (*  for lcv  *)

   (*  add in a file save thing here!  *)
   display_high_scores;      (*  show all the high scores  *)
 end;                        (*  high_scores  *)







procedure make_noise ( make_noise : STUFF );


var
   lcv : integer;

begin

  if (make_noise = TETRIS) then
    begin
     for lcv := 1 to 100 do
      begin
         sound (RANDOM(2000));
         delay (3);
     end;
     end;

  if (make_noise = ROW_CLEAR) then
    begin
    for lcv := 1 to 20 do
    begin;
     sound(2000);
     delay (4);
     sound(random(1000));
     delay(4);
    end;
    end;

  if (make_noise = LEVEL_UP) then
    begin
     for lcv := 1 to 100 do
       begin
         sound(lcv*100);
         delay(3);
       end;
    end;



    nosound;

end;  (* noise procedure  *)

procedure set_clock_rate;   (*  use dos timer to get init_speed  *)

var
   min,sec,hour,hundreds, new_sec,hundreds2 : word;
   speed : integer;

begin
   gettime(hour,min,sec,hundreds);

   sec := sec + 1;
   if (sec = 60) then sec := 00;     (*  what the next second will be for time count loop  *)

   speed := 0;

   repeat                            (*  continually get time until a second has passed  *)
     gettime (hour,min,new_sec,hundreds2);
     speed := speed + 1;                  (*  add one to speed with each cycle (ie get processor speed)  *)
   until ((new_sec = sec) AND (hundreds2 >= hundreds));  (*  utill a second has passed  *)

   init_speed := speed;                  (*  used to control amount of drop time  *)

end;






PROCEDURE FIX_ROTATE;   (*  procedure to fix to center the shapes in the upper left hand corner  *)

  VAR
    ROW, COL, REDRAW_COUNTER, SHAPEO, ROTATE : INTEGER;  (*  loop control variables  *)
    EMPTY_THING, DONE : BOOLEAN;   (*  flag to show empty row or col  *)

  BEGIN

   FOR SHAPEO := 1 TO NUMBER_OF_SHAPES DO  (*  go through all rotations of all shapes  *)
     FOR ROTATE := 1 TO 4 DO
      BEGIN
        DONE := FALSE;  (*  not done  *)
        FOR ROW := 0 TO 3 DO    (*  go through the rows first  *)
         BEGIN
          EMPTY_THING := TRUE;  (*  set flag as true for each row  *)

          FOR COL := 1 TO 4 DO     (*  ROW ISN'T DOWN THERE, BECAUSE OF DELETE METHOD  *)
           IF SHAPES[SHAPEO,ROTATE,COL] = '1'  (*  entire row is not empty  *)
             THEN EMPTY_THING := FALSE;

          IF ( (EMPTY_THING = TRUE) and (DONE = FALSE))                (*  the whole row is empty  *)
             THEN BEGIN                         (*  get rid of empty rows  *)
                    DELETE (SHAPES[SHAPEO,ROTATE],1,4); (*  delete first ROW from the string  *)
                    shapes[shapeo,rotate] := concat(shapes[shapeo,rotate],'0000');  (*  add in entire zeros *)
                  end     (*  IF/  THEN  *)
             ELSE
               DONE := TRUE;            (*  stop 'cause your done  *)

          END;        (*  FOR (ROW)  *)




       FOR COL := 1 TO 4 DO         (*  loop to trash blanks from columns  *)
         BEGIN
          EMPTY_THING := TRUE;
          FOR ROW := 0 TO 3 DO      (*  check through each row  *)
           IF SHAPES[SHAPEO,ROTATE,ROW*4 + 1] = '1'   (* YOU'RE ONLY DOING FIRST COLUMN, SO NO COMPLETE JUNK  *)
             THEN EMPTY_THING := FALSE;

          IF (EMPTY_THING = TRUE) THEN   (*  stuff to delete the column  *)
            BEGIN
              FOR ROW := 0 TO 3 DO
               BEGIN
                delete (shapes[shapeo,rotate],row*4+1,1);   (*  take '0' out of column  *)
                insert ('0',shapes[shapeo,rotate],row*4+FUNKY_ROTATE);   (*  stick in last col  *)
               END;   (*  FOR (ROW)  *)
              END;  (*  IF/THEN  *)
            IF EMPTY_THING = FALSE THEN COL := 4;                 (*  pop out of the loop  *)
         END;  (*  FOR (COL)  *)
     END;   (*  FOR (ROTATE)  *)

     INIT_HIGH_SCORES;           (*  THIS LOOKS LIKE A GOOD PLACE TO INITIALIZE THE HIGH SCORES  *)
     DISPLAY_HIGH_SCORES;        (*  TRASH THIS AFTER IT WORKS  *)

   END;  (*  fix rotate  *)





PROCEDURE WHATKIND; (* FInds out what the initial speed should be according to the computer type *)

BEGIN
   set_clock_rate;   (*  get the init_speed by using the clock rate  *)

   CLRSCR;
   WRITELN;WRITELN;
   WRITELN ('                                TEXTRIS V. 1.1');
   WRITELN;WRITELN;

   WRITELN;
   WRITE ('Do you want funky rotations? [Y/N]');
   COMPTYPE := READKEY;                         (*  use the old variable  *)
   FUNKY_ROTATE := 4;                           (*  assume you want normals until told otherwise  *)
   CASE COMPTYPE of
     'y' : FUNKY_ROTATE := 3;
     'Y' : FUNKY_ROTATE := 3;
   END;    (*  CASE  *)
END;

PROCEDURE INSTRUCTION;

  BEGIN
  ASSIGN (INSTRUCT,'c:\TP6\instruct.txt');
  READLN (INSTRUCT,INSTRUCTIONS);
  WRITE (INSTRUCTIONS);
  READLn;
  CLOSE (INSTRUCT);
  READLN;
  END;

FUNCTION CHOOSE:INTEGER;    (*  function to have user choose level to start on*)
VAR
  INCREASE:INTEGER;  (*  # to increase speed *)
 BEGIN
   CLRSCR;
   WRITELN ('                        TEXTRIS V. 1.1');
   WRITELN;WRITELN;
   WRITE (' What level do you wish to start on? ( 0 - 42 ) : ');
   READ (INCREASE);
   LEVEL:=INCREASE;
   CHOOSE := INIT_SPEED - (INCREASE * 50 );
 END;

PROCEDURE LEVELS;            (* Procedure that automatically increases levels depending on score *)

 BEGIN

   IF COUNT = 3 THEN
    BEGIN

     LEVEL:=LEVEL+1;
     SPEED := SPEED - 100;
     make_noise (level_up);
     COUNT := 0; (* resets count to see if it should change level. *)
    END;
 END;

PROCEDURE MAKE_ROTATE;
  VAR
    ROTATIONS,SHAPE_NUMBER, ROW, COL : INTEGER;     (*  loop control variables  *)


  BEGIN
    FOR SHAPE_NUMBER := 1 TO NUMBER_OF_SHAPES DO                   (*  copy shape constants to array  *)
     BEGIN

      SHAPES[SHAPE_NUMBER,1] := SHAPE[SHAPE_NUMBER];

          FOR ROTATIONS := 2 TO 4 DO          (*  go through all 4 possible versions - first rotation is the initial const*)
           BEGIN
            SHAPES[SHAPE_NUMBER,ROTATIONS] := '';
             FOR COL := 4 DOWNTO 1 DO
              FOR ROW := 0 TO 3 DO
                BEGIN
                  SHAPES[SHAPE_NUMBER,ROTATIONS] :=         (*  inverse the shape from the previous shape  *)
                    CONCAT (SHAPES[SHAPE_NUMBER,ROTATIONS],SHAPES[SHAPE_NUMBER,(ROTATIONS-1),((ROW)*4 +COL)] );
                END;   (*  FOR (COL)  *)

           END;        (*  FOR (ROTATIONS)  *)
       END;            (*  FOR (SHAPE_NUMBER)  *)

   FIX_ROTATE;         (* center shapes on top column  *)

  END;                 (*  MAKE_ROTATE PROCEDURE  *)


PROCEDURE SHOW_SCORE_AND_LEVEL;               (*  prints score and current level *)
   BEGIN;
     SCORE := SCORE + 5;                (*  and token points everytime score is  updated  *)
     GOTOXY(60,5);                      (*  go to location to print score and print it  *)
     WRITE ('SCORE: ',SCORE:6:0);
     GOTOXY(60,6);
     WRITE ('LEVEL: ',LEVEL:6);
     GOTOXY(60,7);
     WRITE ('TOTAL: ',SUPRACOUNT:6);
   END;


PROCEDURE DRAW_BLOCK(X,Y : BYTE; BLOCK_CHAR : CHAR);   (*  prints or erases the block, using the BLOCK_CHAR variable  *)
  VAR
    ROW, COL  : INTEGER;                (*  loop control variables  *)
    DRAW_ME_FLAG : BOOLEAN;             (*  flag to use gotoxy  *)
  BEGIN

     FOR ROW := 0 TO 3 DO
      BEGIN
       DRAW_ME_FLAG := TRUE;            (*  must goto the firt row  *)

       FOR COL := 1 TO 4 DO
         BEGIN

           IF (SHAPES[SHAPE_NUM, SHAPE_ROTATE,ROW*4 + COL] = '1')      (*  only draw if there's something there  *)
             THEN BEGIN
                    IF DRAW_ME_FLAG THEN                (*  only move cursor if its not already there  *)
                       GOTOXY (X+COL-1, Y+ROW);          (*  goto position  *)
                    WRITE (BLOCK_CHAR);                 (*  draw the character  *)
                    SHAPE_BOTTOM := ROW;                (*  bottom of shape  *)
                    DRAW_ME_FLAG := FALSE;              (*  no need to move cursor now  *)
                  END    (*  IF/THEN  *)
             ELSE DRAW_ME_FLAG := TRUE;                 (*  now ya hafta move the cursor-dude  *)

         END;   (*  FOR  (COL)  *)

      END;      (*  for (row)  *)

  END;          (*  DRAW_BLOCK PROCEDURE  *)

PROCEDURE REDRAW_SCREEN(HIGHEST_LINE_USED : BYTE);  (*  only draw from the highest screen line  *)
  VAR
    ROW, COL : INTEGER;

  BEGIN
    FOR ROW := 1 TO HIGHEST_LINE_USED DO
     BEGIN
      GOTOXY(LEFT_BORD,ROW);                          (*  only goto location for new row  *)
      FOR COL := LEFT_BORD TO RIGHT_BORD DO
        BEGIN
          IF MONSTER [ROW,COL] = TRUE
              THEN WRITE (DRAW)
              ELSE WRITE (ERASE);

        END;   (*  FOR COL  *)
      END;  (* FOR ROW  *)
    END;   (*  REDRAW_SCREEN  *)


PROCEDURE CLEAR_ROW (VAR ROW : INTEGER);

  VAR
    ROW2, COL : INTEGER;              (*  columns and row - loop control variable  *)
    ROW_IS_FILLED : BOOLEAN;

  BEGIN
    ROW_IS_FILLED := TRUE;             (*  assume filled until proven otherwise  *)

    FOR COL := LEFT_BORD TO RIGHT_BORD DO  (*  check entire row to see if it's filled  *)
      IF MONSTER [ROW,COL] = FALSE         (*  if row isn't filled then mark it as not being filled  *)
         THEN ROW_IS_FILLED := FALSE;

    IF ROW_IS_FILLED                    (*  BOOLEAN 'TRUE' causes if to succeed, otherwise it fails  *)
       THEN BEGIN
              FOR ROW2 := ROW DOWNTO 2 DO             (*  Loop from row cleared to top row  *)
                FOR COL := LEFT_BORD TO RIGHT_BORD DO
                  MONSTER [ROW2,COL] := MONSTER[ (ROW2 - 1), COL];  (*  move down each row in array  *)
              SCORE := SCORE + 95;      (*  100 points for clearing a row  *)
              MAKE_noise (ROW_CLEAR);         (* sound for clearing row  *)
              REDRAW_SCREEN(ROW);            (*  redraw output screen  *)
              COUNT := COUNT + 1;     (*  raises count for next level raise *)
              SUPRACOUNT:=SUPRACOUNT+1; (* Total lines *)
              SHOW_SCORE_AND_LEVEL;               (*  print out the score and add five points  *)
              END;  (*  THEN  *)
  END;  (*  CLEAR_ROW  *)

FUNCTION CHECK_BLOCK(X,Y : BYTE) : BOOLEAN;
  VAR
    ROW, COL : INTEGER;              (*  loop control variable  *)

  BEGIN
    CHECK_BLOCK := TRUE;       (*  assume you can do it all  *)

    FOR ROW := 0 TO 3 DO
      FOR COL := 1 TO 4 DO
        IF (SHAPES [SHAPE_NUM,SHAPE_ROTATE, (ROW*4 + COL)] = '1')      (*  only check bottom - see DRAW_BLOCK *)
           THEN IF (MONSTER[Y+ROW,X+COL-1] = TRUE)     (*  check to see if screen below block is filled *)
             THEN CHECK_BLOCK := FALSE;                          (*  reached the bottom  *)

  END;   (*  CHECK_BLOCK FUNCTION  *)

PROCEDURE MARK_BLOCK (X,Y : BYTE);      (*  mark the block as being used  *)
  VAR
   ROW,COL : INTEGER;               (*  loop control variables  *)
   CHECK_ROW , TEMP_MARK : BOOLEAN;  (*  flag and temp. storage of marking  *)
   TET_CHECK : BYTE;                 (*  check to see if four rows are cleared  *)
   THINGY : INTEGER;

  BEGIN
    TET_CHECK := SUPRACOUNT;              (*  find rows cleared by looking at total rows  *)

    FOR ROW := 0 TO 3 DO             (*  4 rows and 4 columns in shape  *)
      BEGIN
        CHECK_ROW := FALSE;          (*  assume you don't have to clear row until proven otherwise  *)
        FOR COL := 1 TO 4 DO
          BEGIN
            (*  if position in SHAPE array is '1' then MARK playing field space as TRUE  *)
            TEMP_MARK := (SHAPES [SHAPE_NUM ,SHAPE_ROTATE, (ROW*4 + COL)] = '1');
            IF TEMP_MARK THEN                (*  only mark 'trues' in MONSTER  and clear row *)
               BEGIN
                 CHECK_ROW := TRUE;  (* clear the row  *)
                 MONSTER [Y+ROW,X+COL-1] := TEMP_MARK;            (*  assign to array COL is one greater than we need *)
               END;   (*  IF/THEN  *)
          END;  (*  FOR (COL)  *)

        IF (CHECK_ROW) THEN               (*  If something exists on row then check to clear it  *)
         BEGIN;
           THINGY := Y+ ROW;
           CLEAR_ROW(THINGY);
         END;

    END;   (*  FOR (ROW)  *)

    IF (SUPRACOUNT = (TET_CHECK + 4)) THEN             (*  stuff to do if you get a tetris - 4 rows have been cleared *)
       BEGIN
            SCORE := SCORE + 1000;      (*  add more stuff here to enhance tetris feature  *)
            MAKE_noise(TETRIS);         (*  make the tetris sound *)
       END;
   SHOW_SCORE_AND_LEVEL;                        (*  print score and add five points  *)

  END;                                    (*  MARK_BLOCK PROCEDURE  *)



FUNCTION DROP_CHECK(VAR X,Y : BYTE) : BOOLEAN;   (*  Drops block down one row, or ends  *)
   (*  returns TRUE (can't move down) or FALSE (can and did move) *)

   BEGIN

       IF (CHECK_BLOCK(X,Y+1))          (*  if there is something right below  *)
          THEN BEGIN
                 DRAW_BLOCK(X,Y,ERASE);  (*  erase the old block  *)
                 Y := Y + 1;             (*  move down a row  *)
                 DRAW_BLOCK(X,Y,DRAW);   (*  draw new block  *)
                 DROP_CHECK := FALSE;    (*  can keep on dropping *)
               END
          ELSE DROP_CHECK := TRUE;       (*  can't move down  *)

   END;                    (*  DROP_CHECK PROCEDURE  *)


PROCEDURE DROP_BLOCK (VAR X, Y : BYTE);           (*  speed drop command  *)
  VAR
    DB_END : BOOLEAN;

  BEGIN               (*  continue dropping until we've hit something  *)
    REPEAT
       DB_END := DROP_CHECK (X,Y);
    UNTIL (DB_END = TRUE);
    MARK_BLOCK(X,Y);
    SCORE := SCORE + DROP_BONUS;                (*  add bonus and print score  *)
    SHOW_SCORE_AND_LEVEL;
  END;




PROCEDURE MOVE_LEFT (VAR X,Y : BYTE);   (* procedure to allow person to move left  *)

  BEGIN

    IF (CHECK_BLOCK(X-1,Y))                           (*  if we can move left then do it  *)
       THEN BEGIN

              DRAW_BLOCK (X,Y,ERASE);                (*  erase block  *)
              X := X - 1;                            (*  move to the left  *)
              DRAW_BLOCK (X,Y,DRAW);                 (*  redraw block  *)
            END;             (*  THEN  *)

  END;      (*  MOVE_LEFT PROCEDURE  *)



PROCEDURE MOVE_RIGHT (VAR X,Y : BYTE);  (*  move right - very similar to move left  *)

  BEGIN


    IF (CHECK_BLOCK(X+1,Y))
       THEN BEGIN
               DRAW_BLOCK(X,Y,ERASE);   (*  erase *)
               X := X + 1;              (*  move cursor position  *)
               DRAW_BLOCK(X,Y,DRAW);    (*  draw  *)
            END;   (*  THEN  *)
  END;   (*  MOVE RIGHT  *)




PROCEDURE GAMEOVER;                     (*  do a lot of work here  *)
  BEGIN
    GOTOXY (30,12);
    WRITELN  ('HA!   YOU''RE  TOAST!');
    is_high_score;            (*  see if it's a high score  *)

    WRITELN;
    WRITE  ('Would you like to play again?');
    READLN (ANSWER);
  END;


PROCEDURE ROTATE;

  VAR
    CHECK_FLAG : BOOLEAN;

  BEGIN

    SHAPE_ROTATE := SHAPE_ROTATE + 1;   (*  increase rotation  *)
      IF SHAPE_ROTATE = 5              (*  if past the last, go back to first  *)
        THEN SHAPE_ROTATE := 1;

    CHECK_FLAG := CHECK_BLOCK(X,Y);

    SHAPE_ROTATE := SHAPE_ROTATE - 1;   (*  go to old rotation to erase or restore old or nonmove  *)
    IF SHAPE_ROTATE = 0 THEN SHAPE_ROTATE := 4;

    IF (CHECK_FLAG) THEN
     BEGIN
       DRAW_BLOCK (X,Y,ERASE);          (*  erase old block  *)

       SHAPE_ROTATE := SHAPE_ROTATE + 1;  (*  restore rotation  *)
       IF SHAPE_ROTATE = 5 THEN SHAPE_ROTATE :=1;
       DRAW_BLOCK (X,Y,DRAW);                (*  draw the block  *)
     END;


  END;   (*  ROTATE  *)    {  needs a lot more stuff  }


PROCEDURE DRAW_BORDER;
  VAR
    ROW, COL : INTEGER;

  BEGIN

 (*  Initialize the array  *)

 FOR ROW := 1 TO 24 DO           (*  loop to initialize array to contain nothing  *)
   FOR COL := 1 TO 80  DO
      MONSTER [ROW,COL] := FALSE;

 FOR COL := LEFT_BORD TO RIGHT_BORD DO
   BEGIN
     MONSTER [24,COL] := TRUE;   (*  bottom line is initialized as already containing blocks  *)
     GOTOXY (COL,25);
     WRITE (draw);         (*  constant character for border  *)

     MONSTER [25,COL] := TRUE;     (* define and print borders  *)
     GOTOXY (COL,24);
     WRITE (draw);

   END;

   FOR ROW := 1 TO 23 DO
    BEGIN
      MONSTER [ROW,LEFT_BORD] := TRUE;      (*  draw and print left border, using stored constants  *)
      GOTOXY (LEFT_BORD,ROW);
      WRITE (draw);

      MONSTER [ROW,RIGHT_BORD] := TRUE;      (*  draw and print right border, using stored constants  *)
      GOTOXY (RIGHT_BORD,ROW);
      WRITE (draw);
    END;

 END;    (*  DRAW_BORDER PROCEDURE  *)





BEGIN           (*  MAIN PROGRAM  *)

  (*  initialize with stored constants  *)
    randomize;    (*  make the shapes random  *)

    Y := INIT_Y;  (*  Initialize X and Y variables  *)

    X := INIT_X;
WHATKIND; (*initializes speed based on computer type*)
REPEAT
SUPRACOUNT := 0;
SPEED:=CHOOSE;    (* Initialize starting speed based on user decision *)
COUNT := 0; (* Initialize count for levels *)
  (*  Initialize the array  *)

WRITE ('Do you want instructions?  ');
READLN (ANSWER);
IF ANSWER='Y' THEN INSTRUCTION;

  CLRSCR;      (*  clear screen  *)

  DRAW_BORDER;            (*  procedure to draw borders and initialize array  *)
  MAKE_ROTATE;            (*  make the rotated SHAPES  *)

  SCORE := 0;             (*  INIT SCORE TO 0  *)

  SHOW_SCORE_AND_LEVEL;             (*  print the score with five points  *)

  (*  Main program loop  *)

  SHAPE_NUM := 4;          (*  initial shape is a square - shape 4  *)
  SHAPE_ROTATE := 1;       (*  initially shape is unrotated  *)

  WHILE NOT (DROP_CHECK (X,Y)) DO     (*  draw and check block; repeat until unable to move block  *)


   BEGIN  (*  main program loop (WHILE)  *)

    REPEAT

      DROP_BONUS := DB_INIT;                   (*  drop bonus starts at 50 *)
      LEVELS;
      FOR LCV := 1 TO SPEED DO
         BEGIN
           IF KEYPRESSED THEN                  (*  Only change block position if user presses a key  *)
             BEGIN
               KEY := READKEY;                 (*  get key from user  *)
                 CASE KEY OF
                  'J' : MOVE_LEFT(X,Y);            (*  go left  *)
                  'L' : MOVE_RIGHT(X,Y);           (*  go right  *)
                  'j' : MOVE_LEFT(X,Y);
                  'l' : MOVE_RIGHT(X,Y);
                  'K' : ROTATE;              (*  call rotation procedure  *)
                  'k' : ROTATE;
                  'r' : REDRAW_SCREEN(24);       {  ONLY FOR DEBUGGING - redraw screen }
                  ' ' : BEGIN                (*  drop all the way if you hit space  *)
                               DROP_BLOCK(X,Y);  (*  drop block to bottom of screen  *)
                               LCV  :=  SPEED;
                               DROP_BONUS := DROP_BONUS + DB_INIT     (*  increase drop bonus - use constant *)
                        END;   (*  case ' '  *)

                  's' : BEGIN                   (*  tetris-like drop (same as other now)  *)
                               DROP_BLOCK(X,Y);
                               LCV := SPEED;
                               DROP_BONUS := DROP_BONUS + DB_INIT
                        END;  (*  CASE 's'  *)

                  'd' : BEGIN                    (*  gameboy-like drop  *)
                         IF ( CHECK_BLOCK(X,Y+1) )
                           THEN BEGIN
                                 DRAW_BLOCK (X,Y,ERASE);
                                 Y := Y + 1;            (*  move down 1  *)
                                 DRAW_BLOCK (X,Y,DRAW);
                                END;        (*  IF  *)
                        END;    (*  CASE 'd'  *)
                 END;                          (*  CASE  *)

             END;   (*  IF KEYPRESSED  *)
          END;                                 (*  Fall delay loop (FOR)  *)

    UNTIL (DROP_CHECK(X,Y));                            (*  until you reach the bottom  *)


   IF DROP_BONUS = DB_INIT THEN         (*  if no drop bonus, then nothing dropped, and nothing's been marked, so mark  *)
     MARK_BLOCK(X,Y);                                     (*  mark the block as reaching the bottom  *)
   X:= INIT_X;    (*  re-init all values for location and new shape  *)
   Y:= INIT_Y;
   SHAPE_NUM := RANDOM (NUMBER_OF_SHAPES -1) + 1;         (*  get new random shape  *)
   SHAPE_ROTATE := RANDOM(3)+1;                    (*  unrotated shape  **)

   END;    (*  WHILE  *)

  GAMEOVER;           (*  PRINT GAMEOVER STUFF  *)
 UNTIL (ANSWER = 'N') OR (ANSWER = 'n');
END.