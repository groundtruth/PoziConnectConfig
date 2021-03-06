select
    lga_code as lga_code,
    '' as new_sub,
    '' as property_pfi,
    parcel_pfi as parcel_pfi,
    '' as address_pfi,
    spi as spi,
    plan_number as plan_number,
    lot_number as lot_number,
    '' as base_propnum,
    '' as propnum,
    crefno as crefno,
    '' as hsa_flag,
    '' as hsa_unit_id,
    '' as blg_unit_type,
    '' as blg_unit_prefix_1,
    '' as blg_unit_id_1,
    '' as blg_unit_suffix_1,
    '' as blg_unit_prefix_2,
    '' as blg_unit_id_2,
    '' as blg_unit_suffix_2,
    '' as floor_type,
    '' as floor_prefix_1,
    '' as floor_no_1,
    '' as floor_suffix_1,
    '' as floor_prefix_2,
    '' as floor_no_2,
    '' as floor_suffix_2,
    '' as building_name,
    '' as complex_name,
    '' as location_descriptor,
    '' as house_prefix_1,
    '' as house_number_1,
    '' as house_suffix_1,
    '' as house_prefix_2,
    '' as house_number_2,
    '' as house_suffix_2,
    '' as access_type,
    '' as new_road,
    '' as road_name,
    '' as road_type,
    '' as road_suffix,
    '' as locality_name,
    '' as distance_related_flag,
    '' as is_primary,
    '' as easting,
    '' as northing,
    '' as datum_proj,
    '' as outside_property,
    'C' as edit_code,
    comments as comments,
    geometry as geometry
from (

select
    vp.lga_code as lga_code,
    case
        when vp.plan_number = '' then vp.parcel_pfi
        when vp.spi in ( select spi from ( select vpx.spi, count(*) num_parcels from ( select distinct spi, parcel_pfi from pc_vicmap_parcel ) vpx group by vpx.spi ) where num_parcels > 1 ) then vp.parcel_pfi
        else ''
    end as parcel_pfi,
    vp.spi as spi,
    vp.plan_number as plan_number,
    vp.lot_number as lot_number,
    cp.crefno as crefno,
    'parcel ' || vp.spi ||
        case vp.status
            when 'P' then ' (proposed): '
            else ': '
        end ||
        'replacing crefno ' ||
        case vp.crefno
            when '' then '(blank)'
            else vp.crefno ||
                case
                    when vp.crefno not in ( select crefno from pc_council_parcel ) then ' (invalid)'
                    when ( select count(*) from pc_vicmap_parcel vpx where vpx.crefno = vp.crefno and vpx.spi <> vp.spi group by vpx.crefno ) > 0 then ' (duplicate)'
                    else ''
                end
        end ||
        ' with ' || cp.crefno ||
        case cp.status
            when 'P' then ' (proposed)'
            else ''
        end ||
        ' (propnum ' || cp.propnum ||
        ifnull ( ', ' || ( select cpa.ezi_address from pc_council_property_address cpa where cpa.propnum = cp.propnum limit 1 ) , '' ) || ')' as comments,
    centroid ( vp.geometry ) as geometry
from
    pc_vicmap_parcel vp,
    pc_council_parcel cp
where
    vp.spi <> '' and
    vp.spi = cp.spi and
    vp.crefno <> cp.crefno and
    cp.crefno <> '' and
    ( vp.crefno = '' or
      vp.crefno not in ( select cpx.crefno from pc_council_parcel cpx where cpx.simple_spi = vp.simple_spi ) ) and
    ( vp.plan_number <> '' or
      vp.propnum = cp.propnum )
group by vp.spi
)
