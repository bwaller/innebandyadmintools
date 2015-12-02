1. Gå in i IBIS och leta upp lagets matcher, välj utskriftsvänligt format och kopiera texten
2. Klipp in texten i ett dokument, se tidigare års textfiler för namnförslag. Obs! Om lag i olika serier har fått samma suffix (t.ex. Ekerö IK (B)) kan det vara läge att ändra namnen nu så att det går att skilja på vilken serie en viss match hör till.
3. Kör './parse.rb <textdokument>' och verifiera att det har bildats motsvarande .xls-fil.
4. Öppna .xls.filen med 'soffice --calc <filnamn>.xls' och spara om den med samma namn genom att gå till "Save as..". Acceptera frågorna om format som dyker upp.
   Kolla också om några adresser till spelhallar blev "UNDEFINED". I så fall leta upp adresserna och lägg till i 'parse.rb'. Börja om från 3. ovan.
5. Öppna sportnik och gå till kalender. Välj "Importera händelser" (eller vad menyn heter...)
6. Klicka Ok och verifiera att kalendern har blivit korrekt uppdaterad med de nya matcherna.
