select
    property.prop_pfi as property_pfi,
    property.prop_lga_code as lga_code,
    ifnull ( property.prop_propnum , '' ) as propnum,
    property.prop_multi_assessment as multi_assessment,
    property.prop_status as status,
    address.pfi as address_pfi,
    substr ( address.ezi_address , 1 , length ( address.ezi_address ) - 5 ) as ezi_address,
    address.source as source,
    ifnull ( address.source_verified , '' ) as src_verified,
    address.is_primary as is_primary,
    address.distance_related_flag as distance_related_flag,
    ifnull ( address.location_descriptor , '' ) as location_descriptor,
    ifnull ( address.blg_unit_type , '' ) as blg_unit_type,
    ifnull ( address.hsa_flag , '' ) as hsa_flag,
    ifnull ( address.hsa_unit_id , '' ) as hsa_unit_id,
    ifnull ( address.blg_unit_prefix_1 , '' ) as blg_unit_prefix_1,
    address.blg_unit_id_1 as blg_unit_id_1,
    ifnull ( address.blg_unit_suffix_1 , '' ) as blg_unit_suffix_1,
    ifnull ( address.blg_unit_prefix_2 , '' ) as blg_unit_prefix_2,
    address.blg_unit_id_2 as blg_unit_id_2,
    ifnull ( address.blg_unit_suffix_2 , '' ) as blg_unit_suffix_2,
    ifnull ( address.floor_type , '' ) as floor_type,
    ifnull ( address.floor_prefix_1 , '' ) as floor_prefix_1,
    address.floor_no_1 as floor_no_1,
    ifnull ( address.floor_suffix_1 , '' ) as floor_suffix_1,
    ifnull ( address.floor_prefix_2 , '' ) as floor_prefix_2,
    address.floor_no_2 as floor_no_2,
    ifnull ( address.floor_suffix_2 , '' ) as floor_suffix_2,
    ifnull ( address.building_name , '' ) as building_name,
    ifnull ( address.complex_name , '' ) as complex_name,
    ifnull ( address.house_prefix_1 , '' ) as house_prefix_1,
    address.house_number_1 as house_number_1,
    ifnull ( address.house_suffix_1 , '' ) as house_suffix_1,
    ifnull ( address.house_prefix_2 , '' ) as house_prefix_2,
    address.house_number_2 as house_number_2,
    ifnull ( address.house_suffix_2 , '' ) as house_suffix_2,
    ifnull ( address.road_name , '' ) as road_name,
    ifnull ( address.road_type , '' ) as road_type,
    ifnull ( address.road_suffix , '' ) as road_suffix,
    address.locality_name as locality_name,
    address.num_road_address as num_road_address,
    ifnull ( address.num_address , '' ) as num_address,
    address.address_class as address_class,
    address.add_access_type as access_type,
    address.outside_property as outside_property
from
    VMPROP_PROPERTY property,   
    VMADD_ADDRESS address
where
    property.prop_pfi = address.property_pfi and  
    property.prop_property_type = 'O' and 
    address.is_primary = 'Y'