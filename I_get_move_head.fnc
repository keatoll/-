create or replace function I_get_move_head(
  doc_id     in number, 
  goods_name in varchar2, 
  goods_id   in number        default 0  
)
return varchar2 is
  dh_name varchar2(30);
  dh_type varchar2(5);
  tmp number;
  dh_id number;
  dh_date date;

begin
tmp := doc_id;
loop
    begin
      select dh.name,  dh.dt_code, dh.id, dh.doc_date
      into   dh_name , dh_type, dh_id, dh_date
    from str_docs_heads dh, str_goods_tab gt,
         str_docs_heads dhc, str_goods_tab gtc,
         STR_GOODS_MOVES gr
    where
         dh.id = gt.id_doc
         and dhc.id = gtc.id_doc
         and gr.id_idt =gt.id and gr.id_odt= gtc.id
         and (
                gt.gds.NAME like goods_name
             or gt.id = goods_id
             )
         and dh.owner_data.NAME = 'ООО "Нобис"'
         and dhc.id in (tmp)
         and rownum =1;
     tmp := dh_id;
    exception when OTHERS then
     tmp := null;
    end;
Exit when tmp is null;
end loop; 
  return(dh_name||' ('||dh_id||') - '||dh_date||' - '||dh_type);
end I_get_move_head;
/
