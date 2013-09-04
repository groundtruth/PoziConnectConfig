select
    *,
    case
        when plan_prefix in ( 'CP' , 'PC' ) then plan_number
        else lot_number || '\' || plan_number
    end as spi,
    case
        when plan_prefix in ( 'CP' , 'PC' ) then plan_numeral
        else lot_number || '\' || plan_numeral
    end as simple_spi
from (

select
    A.key1 as propnum,
    '' as crefno,
    '' as status,
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
    ifnull ( L.parish_section , '' ) as section,
    '363' as lga_code
from
    PROCLAIM_nucLand L
    join PROCLAIM_nucAssociation A on L.land_no = A.key2 and L.status in ( 'C' , 'F')
    join PROCLAIM_nucProperty P on A.key1 = P.property_no
    left join PROCLAIM_nucAssociation T on A.key1 = T.key1 and A.key2 = t.key2 and
    T.association_type = 'TransPRLD' and A.date_ended is null
where
    A.association_type = 'PropLand' and
    A.date_ended is null and
    L.plan_desc in ( 'TP' , 'LP' , 'PS' , 'PC' , 'CP' , 'SP' , 'CS' , 'RP' , 'CG' )
    and t.key1 is null
)
