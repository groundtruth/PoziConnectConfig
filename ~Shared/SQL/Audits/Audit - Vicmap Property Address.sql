select
    property_pfi,
    '=hyperlink("https://vicmap.pozi.com/?propertypfi=' || property_pfi || '","https://vicmap.pozi.com/?propertypfi=' || property_pfi || '")' as pozi_map,
    propnum,
    multi_assessment,
    status,
    address_pfi,
    ezi_address,
    ifnull ( ( select edit_code from m1 where m1.propnum = vpa.propnum and vpa.propnum <> '' limit 1 ) , '' ) as m1_edit_code,
    ifnull ( ( select comments from m1 where m1.propnum = vpa.propnum and vpa.propnum <> '' limit 1 ) , '' ) as m1_comments,
    area ( geometry ) property_area,
    area ( envelope ( geometry ) ) property_mbr_area,
    area ( geometry ) / area ( envelope ( geometry ) ) cohesion,
    geometry as geometry
from pc_vicmap_property_address vpa
