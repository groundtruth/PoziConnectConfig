select
    *,
    case
        when plan_number <> '' and lot_number = '' then plan_number
        when plan_number <> '' and sec <> '' then lot_number || '~' || sec || '\' || plan_number
        when plan_number <> '' and block <> '' then lot_number || '~' || block || '\' || plan_number
        when plan_number <> '' then lot_number || '\' || plan_number
        when ( parish_code <> '' or township_code <> '' ) then
            allotment || portion ||
            case when sec <> '' then '~' || sec else '' end ||
            '\PP' ||
            case when township_code <> '' then township_code else parish_code end
        else ''
    end as spi,
    case
        when plan_numeral <> '' and lot_number = '' then plan_numeral
        when plan_number <> '' and sec <> '' then lot_number || '~' || sec || '\' || plan_numeral
        when plan_number <> '' and block <> '' then lot_number || '~' || block || '\' || plan_numeral
        when plan_numeral <> '' then lot_number || '\' || plan_numeral
        when ( parish_code <> '' or township_code <> '' ) then
            allotment || portion ||
            case when sec <> '' then '~' || sec else '' end ||
            '\' ||
            case when township_code <> '' then township_code else parish_code end
        else ''
    end as simple_spi
from
(
select
    cast ( A.key1 as varchar ) as propnum,
    '' as crefno,
    '' as summary,
    case P.status
        when 'F' then 'P'
        else ''
    end as status,
    ifnull ( upper ( part_lot ) , '' ) as part,
    case
        when substr ( trim ( ifnull ( L.plan_no , '' ) ) , -1 ) in ( '1','2','3','4','5','6','7','8','9','0' ) then trim ( ifnull ( L.plan_desc , '' ) ) || ifnull ( L.plan_no , '' )
        else trim ( ifnull ( L.plan_desc , '' ) ) || substr ( trim ( ifnull ( L.plan_no , '' ) ) , 1 , length ( trim ( ifnull ( L.plan_no , '' ) ) ) - 1 )
    end as plan_number,
    ifnull ( L.plan_desc , '' ) as plan_prefix,
    case
        when substr ( trim ( L.plan_no ) , -1 ) in ( '1','2','3','4','5','6','7','8','9','0' ) then L.plan_no
        else ifnull (substr ( trim ( L.plan_no ) , 1 , length ( trim ( L.plan_no ) ) - 1 ) , '' )
    end as plan_numeral,
    ifnull ( L.lot , '' ) as lot_number,
    ifnull ( L.text3 , '' ) as allotment,
    ifnull ( L.parish_section , '' ) as sec,
    '' as block,
    '' as portion,
    '' as subdivision,
    '' as parish_code,
    '' as township_code,
    '363' as lga_code
from
    techone_nucland L
    join techone_nucassociation A on L.land_no = A.key2 and L.status in ( 'C' , 'F')
    join techone_nucproperty P on A.key1 = P.property_no
    left join techone_nucassociation T on A.key1 = T.key1 and A.key2 = t.key2 and
    T.association_type is null and A.date_ended is null
where
    A.association_type = 'PropLand' and
    A.date_ended is null and
    L.plan_desc in ( 'TP' , 'LP' , 'PS' , 'PC' , 'CP' , 'SP' , 'CS' , 'RP' , 'CG' )
    and t.key1 is null and  
    P.status in ( 'C' , 'F' , 'c' , 'f' )
)
