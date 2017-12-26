create or replace function I_AccountBalanceAverage
(
   idAccount      Account.Classified%type,      -- Classified �����
   dtBegDate      date,                         -- ���� ������ �������
   dtEndDate      date,                         -- ���� ����� �������
   nBalType       dt.Status default 1,  -- ��� �������
   nOperType      dt.Status default 1,          -- ��� �������� 
                                                -- 1 - accountturnde
                                                -- 2 - accountturncr
                                                -- 3 -accrestin
   nWorkDaysOnly  dt.Status default 0         -- ��������� ������ ������� ���
) return Balance.Amount%type
/******************************************************************************************************
��������: ������� ���������� ���������������������� ������� �� �������� ����� �� ��������
          ������.
���������:
   idAccount      - Classified �����
   dtBegDate      - ���� ������ �������
   dtEndDate      - ���� ����� �������
   nBalType       - ��� ������� (1 - �������, 5 - ����������)
   nWorkDaysOnly  - ������� ����� ������ ������� ����
������������ ��������: ��������������������� ������� �� ����� (NUMBER)
������ ��: 16/02/01 (07/06/00,22/12/99)
   �����: ������ �������
******************************************************************************************************/
as
   nBalance    Balance.Amount%type; -- ���������� ����
   nCurBalance Balance.Amount%type; -- ������� �������
   dtStart     date;                -- ��������� ���� ������ �������
   dtEnd       date;                -- ���� ����� ������� + 1
   dtCurrent   date;                -- ������������� ����
   nDays       dt.Counter;          -- ����� ���� � �������
   nGoodDate   dt.Status;           -- ������ �� ������ �� ������ ����
   dt1         date;
   dt2         date;
begin
   -- �������� �� ������������ ���������� �������
   if dtBegDate > dtEndDate then
      return null;
   elsif dtBegDate = dtEndDate then
      if nWorkDaysOnly = 1 and IsHoliday(dtBegDate) = 1 then
         return null;
      else
         --return AccRestIn(idAccount, dtBegDate, nBalType, 0);
        dt1 := to_date(to_char(dtBegDate,'dd.mm.yyyy')||'.00.00.00','dd.mm.yyyy.HH24.MI.SS' );
        dt2 := to_date(to_char(dtBegDate,'dd.mm.yyyy')||'.23.59.59','dd.mm.yyyy.HH24.MI.SS' );
        if nOperType =3 then
          return  nvl(AccRestIn(idAccount, dtBegDate, nBalType, 0),0);
        elsif nOperType =1 then
          return  nvl(accountturnde(idAccount, dt1, dt2, nBalType),0);
        elsif nOperType =2 then
          return  nvl(accountturncr(idAccount, dt1, dt2, nBalType),0);
        end if;         
         
      end if;
   end if;
   -- ���������� ��������� ������� ���������
   dtStart  := trunc(dtBegDate, 'DD');
 --dtEnd    := trunc(dtEndDate, 'DD') + 1;    -- 16/02/01
   dtEnd    := trunc(dtEndDate, 'DD');
   -- ���������� ���������� ���� � ���������
   if nWorkDaysOnly = 1 then
      -- ���� ������� ��������� ���������� �� ��������� ��� - ���������� ������� ���������
      while IsHoliday(dtStart) = 1 loop
         dtStart := dtStart - 1;
      end loop;
      while IsHoliday(dtEnd) = 1 loop
         dtEnd := dtEnd + 1;
      end loop;
      nDays := DPGeneral.GetIntervalValue(dtStart, dtEnd, 2);
      -- ���� �������� ������� �������� �� ��������
      if nDays = 0 then
         return null;
      end if;
   else
      nDays := DPGeneral.GetIntervalValue(dtStart, dtEnd, 1);
   end if;
   -- �������������_
   dtCurrent   := dtStart;
   nBalance    := 0;
   nCurBalance := 0;
   -- ������ ���
   while dtCurrent <= dtEnd loop
      dt1 := to_date(to_char(dtCurrent,'dd.mm.yyyy')||'.00.00.00','dd.mm.yyyy.HH24.MI.SS' );
      dt2 := to_date(to_char(dtCurrent,'dd.mm.yyyy')||'.23.59.59','dd.mm.yyyy.HH24.MI.SS' );
      -- ���� �� ��������� ������� �� ������ ����?
      if nWorkDaysOnly = 1 then
         nGoodDate := abs(sign(IsHoliday(dtCurrent) - 1));
      else
         nGoodDate := 1;
      end if;
      if nGoodDate = 1 then
         if nOperType =3 then
           nCurBalance := nvl(AccRestIn(idAccount, dtCurrent, nBalType, 0),0);
         elsif nOperType =1 then
           nCurBalance := nvl(accountturnde(idAccount, dt1, dt2, nBalType),0);
         elsif nOperType =2 then
           nCurBalance := nvl(accountturncr(idAccount, dt1, dt2, nBalType),0);
         end if;         
         -- ���� ������� ��������� - ����� ���������� �������
         if dtCurrent in (dtStart, dtEnd) then
            nCurBalance := nCurBalance/2;
         end if;
         nBalance := nBalance + nCurBalance;
      end if;
      dtCurrent := dtCurrent + 1;
   end loop;
   nBalance := nBalance/nDays;
   return(nBalance);
end I_AccountBalanceAverage;
/
