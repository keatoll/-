create or replace function I_AccountBalanceAverage
(
   idAccount      Account.Classified%type,      -- Classified счета
   dtBegDate      date,                         -- Дата начала периода
   dtEndDate      date,                         -- Дата конца периода
   nBalType       dt.Status default 1,  -- Тип остатка
   nOperType      dt.Status default 1,          -- Тип операции 
                                                -- 1 - accountturnde
                                                -- 2 - accountturncr
                                                -- 3 -accrestin
   nWorkDaysOnly  dt.Status default 0         -- Учитывать только рабочие дни
) return Balance.Amount%type
/******************************************************************************************************
Описание: Функция вычисления среднехронологического баланса по лицевому счету за заданный
          период.
Параметры:
   idAccount      - Classified счета
   dtBegDate      - Дата начала периода
   dtEndDate      - Дата конца периода
   nBalType       - Тип остатка (1 - номинал, 5 - эквивалент)
   nWorkDaysOnly  - Признак учета только рабочих дней
Возвращаемое значение: среднехронологический остаток по счету (NUMBER)
Версия от: 16/02/01 (07/06/00,22/12/99)
   Автор: Михаил Мочалов
******************************************************************************************************/
as
   nBalance    Balance.Amount%type; -- Накопитель сумм
   nCurBalance Balance.Amount%type; -- Текущий остаток
   dtStart     date;                -- Усеченная дата начала периода
   dtEnd       date;                -- Дата конца периода + 1
   dtCurrent   date;                -- Анализируемая дата
   nDays       dt.Counter;          -- Число дней в периоде
   nGoodDate   dt.Status;           -- Делать ли расчет за данную дату
   dt1         date;
   dt2         date;
begin
   -- Проверка на корректность введенного периода
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
   -- Установить требуемые границы интервала
   dtStart  := trunc(dtBegDate, 'DD');
 --dtEnd    := trunc(dtEndDate, 'DD') + 1;    -- 16/02/01
   dtEnd    := trunc(dtEndDate, 'DD');
   -- Определить количество дней в интервале
   if nWorkDaysOnly = 1 then
      -- Если границы интервала приходятся на нерабочие дни - раздвинуть границы интервала
      while IsHoliday(dtStart) = 1 loop
         dtStart := dtStart - 1;
      end loop;
      while IsHoliday(dtEnd) = 1 loop
         dtEnd := dtEnd + 1;
      end loop;
      nDays := DPGeneral.GetIntervalValue(dtStart, dtEnd, 2);
      -- если интервал целиком попадает на выходные
      if nDays = 0 then
         return null;
      end if;
   else
      nDays := DPGeneral.GetIntervalValue(dtStart, dtEnd, 1);
   end if;
   -- Инициализация_
   dtCurrent   := dtStart;
   nBalance    := 0;
   nCurBalance := 0;
   -- Анализ дат
   while dtCurrent <= dtEnd loop
      dt1 := to_date(to_char(dtCurrent,'dd.mm.yyyy')||'.00.00.00','dd.mm.yyyy.HH24.MI.SS' );
      dt2 := to_date(to_char(dtCurrent,'dd.mm.yyyy')||'.23.59.59','dd.mm.yyyy.HH24.MI.SS' );
      -- Надо ли вычислять остаток за данный день?
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
         -- Если границы интервала - брать половинный остаток
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
