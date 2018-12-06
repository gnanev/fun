uses dos,ext,crt;

var p,p1:procedure;
    k:byte;
    end_program:boolean;
    key:byte;
    tick:boolean;
    bx,by:byte;
    takt:byte;
    stop_time:boolean;
    i,x,y:byte;
    enemy:word;
    s:string[15];
    alt:byte;
    player:record
            score:Longint;
            lives:byte;
            Amo:word;
            level:byte;
           end;
     map:array[1..80,1..22] of byte;
     n:byte;
     t:boolean;
     min,sec:byte;
     b:boolean;
     vzriv:boolean;

Procedure sw(x,y:byte);
 Begin
   mw(x+1,y,'³');
  mw(x,y+1,'ÃÛ´');
 end;
 procedure clrbuf;assembler;
 asm
 mov    ah,0ch;
 Int    21h;
 end;
Procedure control;
begin
  case k of
75:
     If i>1 then
     begin
      dec(i);
      {bart(i,24,i,24,79);
      bart(i+1,24,i+1,24,15);}
      sw(i,23);
      mw(i+2,23,' ');
      mw(i+3,24,' ');
     end;
77:
     If i<78 then
     begin
      inc(i);
      {bart(i,24,i,24,79);
      bart(i-1,24,i-1,24,15);}
      sw(i,23);
      mw(i-1,23,'  ');
      mw(i-1,24,' ');
     end;
 72,71,73:If player.amo>0 then
 begin
   sound(300);delay(2);nosound;dec(player.amo);
    case k of
 72:map[i+1,22]:=100;
 71:map[i,22]:=100;
 73:map[i+2,22]:=100;
    end;
    end;
 end;{------------ case ---------------}
 end;

{$F+}

 procedure press_key;Interrupt;
  Begin
   clrbuf;
   k:=port[$60];
   If k>83 then k:=0;

   asm pushf end;
   p;
  end;
  Procedure move_fire;
begin
    For y:=1 to 22 do
     for x:=1 to 80 do
   Begin
         If map[x,y]=100 then
      begin
            map[x,y]:=0;
          If y>1 then
          begin
           If map[x,y-1] in [1..9] then
            begin
            {------------ FX --------------}
                    for n:=1 to 5 do
               begin
           sound(100);delay(10);nosound;
            If b then
             bart(x,y-1,x,y-1,15) else bart(x,y-1,x,y-1,14);
             b:=not(b);
           end;
            {------------End FX -----------}
            Inc(player.score,map[x,y-1]);
            dec(enemy);
            map[x,y-1]:=0;
            mw(x,y-1,' ');

            end
           else begin
           map[x,y-1]:=100;
           bart(x,y-1,x,y-1,15);
           mw(x,y-1,'ú'); end;
          end;
        mw(x,y,' ');
       end;
      end;
end;


 Procedure timer;Interrupt;
 
  Begin
  If not stop_time then
     control;
    If (takt=18) and not stop_time then
     Begin
      takt:=0;
      tick:=true;
      If sec=0 then
      begin
       sec:=59;dec(min);
      end else dec(sec);
     end else If not stop_time then begin inc(takt); tick:=false end;
    asm pushf end;
    p1;
    end;
{$F-}

Procedure add_map;
var b,a:byte;
Begin
 randomize;
  If random(130-(player.level*10))=0 then
   begin
    b:=random(20)+1;
    a:=random(81)+1;
    If map[a,b]=0 then begin map[a,b]:=9; inc(enemy);end;
   end;
end;
Procedure Boom(x,y:byte);
var i,j:byte;
    b:boolean;
begin
clrBuf;
b:=true;
Repeat
delay(100);
 If b then bart(x,y,x,y,14) else bart(x,y,x,y,15);
 If b then begin
 bart(1,1,80,22,64);
 b:=false end else
 begin
  bart(1,1,80,22,0);
  b:=true;
 end;

 mw(x,y,'Û');
until keyPressed;
end;

 BEGIN
 takt:=0;
 min:=1;sec:=0;
 GetIntVec($9,@p);
 SetIntVec($9,@press_key);
 GetIntVec($1C,@p1);
 SetIntVec($1C,@timer);
 end_program:=false;
 enemy:=0;
 win(1,1,80,25,15,0,false,true);
 i:=1;bart(1,1,1,1,79);
 cursor(0);
 bart(1,25,80,25,30);
 mw(3,25,'Score : ');
 mw(20,25,'Time : ');
 mw(35,25,'Amo : ');
 mw(50,25,'Lives : ');
 mw(65,25,'Level : ');
 player.lives:=3;
 player.score:=0;
 player.amo:=1000;
 player.level:=1;
 for y:=1 to 22 do
  for x:=1 to 80 do
   map[x,y]:=0;
   vzriv:=false;
   stop_time:=false;
   mw(73,25,'1');
   mw(58,25,'3');

 REPEAT

 add_map;
{ delay(5);}
{ control;   }
 str(sec,s);
 if length(s)=1  then s:='0'+s;
 s:=':'+s;
 mw(28,25,s);
 str(min,s);
  mw(27,25,s);
 str(player.amo,s);
 mw(40,25,s);
 for x:=length(s) to 6 do mw(40+x,25,' ');
 str(player.score,s);
 mw(10,25,s);

 move_fire;

 If (min=0) and (sec=0) then
  begin
   stop_time:=true;
    win(10,9,70,12,79,2,true,true);
    str(player.level,s);
    mw(15,11,'Level '+s+' complete ! Get ready for next level !');
    for y:=1 to 22 do
     for x:=1 to 80 do
      map[x,y]:=0;
     Inc(player.level);
     str(player.level,s);
     mw(73,25,s);
     Inc(player.amo,100);
     min:=1;sec:=00;
     delay(3000);
     textattr:=0;window(1,1,80,22);clrscr;
     stop_time:=false;
    end;
 If tick and (enemy>0) then
 begin
  tick:=false;
      for y:=1 to 22 do
      for x:=1 to 80 do
      begin
       If map[x,y]=1 then
       begin
               vzriv:=true;
        bx:=x;by:=y;
       end;
       If map[x,y]=0 then mw(x,y,' ');

       If map[x,y] in [1..9] then
      begin
       sound(1000);delay(2);nosound;
       bart(x,y,x,y,31);
       dec(map[x,y]);
       str(map[x,y],s);
       mw(x,y,s);

      end;end;
    end;

  If vzriv then begin
   stop_time:=true;
   dec(player.lives);
   str(player.lives,s);
   mw(58,25,s);
   boom(bx,by);
   textattr:=0;
   window(1,1,80,22);clrscr;
   for y:=1 to 22 do
    for x:=1 to 80 do
     map[x,y]:=0;
   vzriv:=false;
   stop_time:=false;
   end;
 Case k of
59:begin
    stop_time:=true;
    save_screen;
    win(10,10,60,20,79,2,true,true);
    mw(31,10,' HELP ');
    mw(20,12,#27+','+#26+' - Move space ship');
    mw(20,13,'HOME - Left fire');
    mw(20,14,'PgUp - Rignt fire');
    mw(20,15,#24+' - Direct fire');
    mw(20,16,'F1 - Call this help window');
    mw(20,17,'F2 - Call shop panel');
    mw(20,18,'ESCape - Quit game');
    repeat until keyPressed;
    load_screen;
    stop_time:=false;
    end;
1: begin
    save_screen;
     stop_time:=true;
     win(25,10,55,16,79,2,true,true);
     mw(27,12,'EXIT ? Are you sure ? (Y/N)');
     mw(35,14,' Yes  No ');
     alt:=1;
     bart(35,14,39,14,112);
     repeat
      Pk(key);
      case key of
    57,75,77,15:If alt=1 then alt:=2 else alt:=1;
    21:alt:=1;
    49,1:alt:=2;
       end;
      bart(35,14,43,14,79);
      If alt=1 then      bart(35,14,39,14,112) else
      bart(40,14,43,14,112);

     until key in[28,21,49,1];
     if alt=1 then end_program:=true else
      begin
      load_screen;stop_time:=false;
      end;
     end;
60:Begin
    stop_time:=true;
    save_screen;
    win(20,7,60,15,79,2,true,true);
    mw(30,7,' SHOP ');
    mw(23,8,' Press "A" or "L" key for buy.');
    mw(22,9,'Amo (1) - ');
    str(player.amo,s);
    mw(32,9,s);
    mw(22,11,'Lives (100) - ');
    str(player.lives,s);
    mw(36,11,s);
    str(player.score,s);
    mw(22,13,'Your score - ');
    mw(35,13,s+'      ');
   Repeat
  pk(key);
   case key of
 30: If player.score>0 then
      begin
       Inc(player.amo);
       dec(player.score);
       str(player.score,s);
       mw(35,13,s+'         ');
       str(player.amo,s);
       mw(32,9,s);
      end else
      Begin
        sound(800);
        delay(50);
        nosound;
       end;
 $26: If (player.score-100)>=0 then
      begin
       Inc(player.lives);
       dec(player.score,100);
       str(player.score,s);
       mw(35,13,s+'       ');
       str(player.lives,s);
       mw(36,11,s);
       mw(58,25,s);
      end else
      Begin
        sound(800);
        delay(50);
        nosound;
       end;
     end;
    Until key=1;
   load_screen;
   stop_time:=false;
  end;

   end;
   until End_program;
   window(1,1,80,25);textattr:=7;clrscr;cursor(1);
  end.