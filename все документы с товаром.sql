/* выбрать все документы, в которых присутствует необходимый товар */
select sum(gt.gds.QUANTITY) ,   gp.name, dh.name

from str_goods_tab gt, str_docs_heads dh ,  goods_groups gp
where gt.id_doc = dh.id(+)
--and dh.id in (81645,82442)
and dh.id_owner_dept <> 21
and dh.locked = 1
--and dh.corr_data.NAME = 'BOST HOLDING'
--and dh.corr_data.NAME in ('ООО "ПА Старая"','ООО "ПауэрАзия_Н"','ООО "Амур Энергия"')
and dh.dt_code = '71a5'
and gp.id = gt.gds.ID_GPACK
and instr((select SYS_CONNECT_BY_PATH(NAME, ' >') from KOMDEK.GOODS_GROUPS_VIEW where ID = nvl(gp.ID_REL, gp.id) 
start with ID_REL is null connect by prior ID = ID_REL),'Максис')>1 
and gp.name not in ('Камера R16 LT','Камера R20 LT', 'Флипер R16 LT', 'Флипер R20 LT')
--and gp.name = 'MA-751 215/85 R16 115/112Q 10PR TL'
--and dh.id = 243171
group by gp.name, dh.name
order by 2
