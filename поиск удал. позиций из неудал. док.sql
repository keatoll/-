select dc.*, dc.ROWID, df.FIELD_LABEL, KOMDEK.KAGENT.AUTHOR_NAME(dc.AUTHOR) as AUTHOR_NAME,
decode(dc.ID_DOC_TAB, NULL, 'Заголовок документа', 'Товары документа') as CHANGE_AREA,
decode('STR', 'FIN', (select NAME from KOMDEK.FIN_GOODS_TAB_VIEW where ID = dc.ID_DOC_TAB),
'STR', (select NAME from KOMDEK.STR_GOODS_TAB_VIEW where ID = dc.ID_DOC_TAB), NULL) as DOC_TAB_NAME,
 case when dc.FIELD_NAME='OPTIONS_STRING' then decode(substr(OLD_VAL, 3, 1), '1', 'док-т возвращен; ')||decode(substr(OLD_VAL, 4, 1), '1', 'товар отгружен') else OLD_VAL end as OLD_VAL_STR,
 case when dc.FIELD_NAME='OPTIONS_STRING' then decode(substr(NEW_VAL, 3, 1), '1', 'док-т возвращен; ')||decode(substr(NEW_VAL, 4, 1), '1', 'товар отгружен') else NEW_VAL end as NEW_VAL_STR

from KOMDEK.SYS_DOCS_CHANGES_FIX dc, KOMDEK.SYS_DOCS_FIELDS df, str_docs_heads dh
where dc.ID_DOC = dh.id and dc.TABLE_NAME in ('STR_DOCS_HEADS', 'STR_GOODS_TAB')
and df.TABLE_NAME = dc.TABLE_NAME and df.FIELD_NAME = dc.FIELD_NAME
and df.FIELD_LABEL = 'наименование товара'
and new_val like '%Аккумулятор SMF 31-930S Rocket%'
--and dh.id = 236810
and dh.doc_date >= to_date('01.03.2010','dd.mm.yyyy')
and dh.doc_date <= to_date('31.03.2010','dd.mm.yyyy')
 order by CH_DATE
--ID_DOC(INTEGER)=237128
