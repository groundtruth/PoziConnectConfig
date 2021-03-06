select
    *,
    ltrim ( num_road_address ||
        rtrim ( ' ' || locality_name ) ) as ezi_address
from (

select
    *,
    ltrim ( road_name_combined ||
        rtrim ( ' ' || locality_name ) ) as road_locality,
    ltrim ( num_address ||
        rtrim ( ' ' || road_name_combined ) ) as num_road_address
from (

select
    *,
    blg_unit_prefix_1 || blg_unit_id_1 || blg_unit_suffix_1 ||
        case when ( blg_unit_id_2 <> '' or blg_unit_suffix_2 <> '' ) then '-' else '' end ||
        blg_unit_prefix_2 || blg_unit_id_2 || blg_unit_suffix_2 ||
        case when ( blg_unit_id_1 <> '' or blg_unit_suffix_1 <> '' ) then '/' else '' end ||
        case when hsa_flag = 'Y' then hsa_unit_id || '/' else '' end ||
        house_prefix_1 || house_number_1 || house_suffix_1 ||
        case when ( house_number_2 <> '' or house_suffix_2 <> '' ) then '-' else '' end ||
        house_prefix_2 || house_number_2 || house_suffix_2 as num_address,
    ltrim ( road_name ||
        rtrim ( ' ' || road_type ) ||
        rtrim ( ' ' || road_suffix ) ) as road_name_combined
from (

select
    cast ( P.property_no as varchar ) as propnum,
    case P.status
        when 'F' then 'P'
        else ''
    end as status,
    ifnull (
        (
        select
            cast ( npx1.property_no as varchar )
        from
            techone_nucproperty npx
            inner join techone_nucassociation nax on npx.property_no = nax.key2
            inner join techone_nucproperty npx1 on nax.key1 = npx1.property_no
        where
            npx.property_no = P.property_no and
            nax.date_ended is null and
            nax.association_type = 'ChildProp' and
            npx1.status in ('C','F')
        limit 1
        ) , ''
    ) as base_propnum,
    '' as is_primary,
    '' as distance_related_flag,
    '' as hsa_flag,
    '' as hsa_unit_id,
    case
        when upper ( A.unit_desc ) in ( 'FRONT' , 'REAR' ) then upper ( A.unit_desc )
        else ''
    end as location_descriptor,
    case
        when upper ( A.unit_desc ) in ( 'ATM' , 'APT' , 'FLAT' , 'LOT' , 'ROOM' , 'SHOP' , 'SITE' , 'UNIT' ) then upper ( A.unit_desc )
        when upper ( A.unit_desc ) = 'CAR LOT' then 'CARS'
        when upper ( A.unit_desc ) = 'FACTORY' then 'FCTY'
        when upper ( A.unit_desc ) = 'GARAGE' then 'GRGE'
        when upper ( A.unit_desc ) = 'KIOSK' then 'KSK'
        when upper ( A.unit_desc ) = 'OFFICE' then 'OFFC'
        when upper ( A.unit_desc ) = 'SHOPS' then 'SHOP'
        when upper ( A.unit_desc ) = 'STALL' then 'STLL'
        when upper ( A.unit_desc ) = 'SUITE' then 'SE'
        else ''
    end as blg_unit_type,
    case
        when length ( A.unit_desc ) <= 2 then upper ( A.unit_desc )
        else ''
    end as blg_unit_prefix_1,
    case
        when A.unit_no = '0' then replace ( A.unit_no , '0' , '' )
        else ifnull ( A.unit_no , '' )
    end as blg_unit_id_1,
    case
        when A.unit_no_suffix = '&' then ''
        else upper ( ifnull ( A.unit_no_suffix , '' ) )
    end as blg_unit_suffix_1,
    '' as blg_unit_prefix_2,
    case
        when A.unit_no_to = '0' then replace ( A.unit_no_to , '0' , '' )
        else ifnull ( A.unit_no_to , '' )
    end as blg_unit_id_2,
    upper ( ifnull ( A.unit_no_to_suffix , '' ) ) as blg_unit_suffix_2,
    case upper ( A.floor_desc )
        when 'FLOOR' then 'FL'
        when 'GROUND' then 'G'
        when 'LEVEL' then 'L'
        when 'MEZANINE' then 'M'
        when 'ROOF' then 'RT'
        else ''
    end as floor_type,
    '' as floor_prefix_1,
    case
        when A.floor_no = '0' then replace ( A.floor_no , '0' , '' )
        else ifnull ( A.floor_no , '' )
    end as floor_no_1,
    upper ( ifnull ( A.floor_suffix , '' ) ) as floor_suffix_1,
    '' as floor_prefix_2,
    case
        when A.floor_no_to = '0' then replace ( A.floor_no_to , '0' , '' )
        else ifnull ( A.floor_no_to , '' )
    end as floor_no_2,
    upper ( ifnull ( A.floor_suffix_to , '' ) ) as floor_suffix_2,
    '' as building_name,
    case
        when upper ( S.street_name ) in ( 'CHADSTONE SHOPPING CENTRE' ) then upper ( S.street_name )
        else ''
    end as complex_name,
    '' as house_prefix_1,
    case
        when upper ( S.street_name ) = 'CHADSTONE SHOPPING CENTRE' then '1341'
        when A.house_no = '0' then replace ( A.house_no , '0' , '' )
        else ifnull ( A.house_no , '' )
    end as house_number_1,
    upper ( ifnull ( A.house_no_suffix , '' ) ) as house_suffix_1,
    '' as house_prefix_2,
    case
        when A.house_no_to = '0' then replace ( A.house_no_to , '0' , '' )
        else ifnull ( A.house_no_to , '' )
    end as house_number_2,
    upper ( ifnull ( A.house_no_to_suffix , '' ) ) as house_suffix_2,
    case
        when upper ( S.street_name ) like 'A''BECKETT%' then 'ABECKETT'
        when upper ( S.street_name ) = 'CHADSTONE SHOPPING CENTRE' then 'DANDENONG'
        when S.street_name like 'MOUNT PLEASANT%' then 'MT PLEASANT'
        when S.street_name like 'THE AVENUE' then 'THE AVENUE'
        when S.street_name like 'THE GRANGE' then 'THE GRANGE'
        when S.street_name like 'THE BOULEVARD' then 'THE BOULEVARD'
        when upper ( S.street_name ) = 'THE RIALTO' then 'THE RIALTO'
        when upper ( S.street_name ) = 'THE RIALTO WEST' then 'THE RIALTO WEST'
        when upper ( substr ( S.street_name , -4 ) ) in ( ' END' , ' ROW' , ' RUN', ' KEY', ' WAY' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 4 ) )
        when upper ( substr ( S.street_name , -5 ) ) in ( ' BEND', ' BRAE', ' COVE' , ' EDGE' , ' LANE', ' LINK', ' MEWS', ' NOOK' , ' QUAY', ' RISE', ' ROAD', ' VIEW', ' WALK', ' WYND', ' RIALTO WEST' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 5 ) )
        when upper ( substr ( S.street_name , -6 ) ) in ( ' CLOSE' , ' COURT' , ' CREST' , ' DRIVE', ' GLADE', ' GROVE', ' HEATH', ' PLACE', ' PLAZA', ' POINT', ' RIDGE', ' ROUND', ' SLOPE' , ' STRIP', ' TRACK', ' VISTA' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 6 ) )
        when upper ( substr ( S.street_name , -7 ) ) in ( ' ACCESS', ' ARCADE', ' AVENUE', ' CIRCLE', ' DIVIDE', ' GRANGE', ' PARADE', ' SQUARE', ' STREET', ' WATERS' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 7 ) )
        when upper ( substr ( S.street_name , -8 ) ) in ( ' CIRCUIT', ' CUTTING', ' FREEWAY', ' GARDENS', ' HIGHWAY', ' RETREAT', ' TERRACE' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 8 ) )
        when upper ( substr ( S.street_name , -9 ) ) in ( ' CRESCENT', ' QUADRANT' , ' WATERWAY' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 9 ) )
        when upper ( substr ( S.street_name , -10 ) ) in ( ' BOULEVARD', ' ESPLANADE' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 10 ) )
        when upper ( substr ( S.street_name , -11 ) ) in ( ' BOULEVARDE' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 11 ) )
        when upper ( substr ( S.street_name , -10 ) ) in ( ' ROAD EAST', ' ROAD WEST', ' WAY NORTH' , ' WAY SOUTH' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 10 ) )
        when upper ( substr ( S.street_name , -11 ) ) in ( ' GROVE EAST' , ' GROVE WEST', ' LANE NORTH' , ' LANE SOUTH' , ' ROAD NORTH' , ' ROAD SOUTH' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 11 ) )
        when upper ( substr ( S.street_name , -12 ) ) in ( ' CLOSE NORTH' , ' CLOSE SOUTH' , ' COURT NORTH' , ' COURT SOUTH' , ' STREET EAST' , ' STREET WEST' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 12 ) )
        when upper ( substr ( S.street_name , -13 ) ) in ( ' AVENUE NORTH' , ' AVENUE SOUTH' , ' STREET NORTH' , ' STREET SOUTH' , ' PARADE NORTH' , ' PARADE SOUTH' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 13 ) )
        when upper ( substr ( S.street_name , -14 ) ) in ( ' HIGHWAY NORTH' , ' HIGHWAY SOUTH' ) then upper ( substr ( S.street_name , 1 , length ( S.street_name ) - 14 ) )
        else upper ( S.street_name )
    end as road_name,
    case
        when upper ( S.street_name ) = 'CHADSTONE SHOPPING CENTRE' then 'ROAD'
        when S.street_name like 'THE AVENUE' then ''
        when S.street_name like 'THE GRANGE' then ''
        when S.street_name like 'THE BOULEVARD' then ''
        when S.street_name like '% ROAD%' then 'ROAD'
        when S.street_name like '% ACCESS%' then 'ACCESS'
        when S.street_name like '% ARCADE%' then 'ARCADE'
        when S.street_name like '% AVENUE%' then 'AVENUE'
        when S.street_name like '% BEND%' then 'BEND'
        when S.street_name like '% BOULEVARDE%' then 'BOULEVARDE'
        when S.street_name like '% BOULEVARD%' then 'BOULEVARD'
        when S.street_name like '% BRAE%' then 'BRAE'
        when S.street_name like '% CIRCLE%' then 'CIRCLE'
        when S.street_name like '% CIRCUIT%' then 'CIRCUIT'
        when S.street_name like '% CLOSE%' then 'CLOSE'
        when S.street_name like '% COURT%' then 'COURT'
        when S.street_name like '% COVE%' then 'COVE'
        when S.street_name like '% CRESCENT%' then 'CRESCENT'
        when S.street_name like '% CREST%' then 'CREST'
        when S.street_name like '% CUTTING%' then 'CUTTING'
        when S.street_name like '% DIVIDE%' then 'DIVIDE'
        when S.street_name like '% DRIVE%' then 'DRIVE'
        when S.street_name like '% EDGE%' then 'EDGE'
        when S.street_name like '% END%' then 'END'
        when S.street_name like '% ESPLANADE%' then 'ESPLANADE'
        when S.street_name like '% FREEWAY%' then 'FREEWAY'
        when S.street_name like '% GARDENS%' then 'GARDENS'
        when S.street_name like '% GLADES' then ''
        when S.street_name like '% GLADE%' then 'GLADE'
        when S.street_name like '% GRANGE%' then 'GRANGE'
        when S.street_name like '% GROVE%' then 'GROVE'
        when S.street_name like '% HEATH%' then 'HEATH'
        when S.street_name like '% HIGHWAY%' then 'HIGHWAY'
        when S.street_name like '% LANE%' then 'LANE'
        when S.street_name like '% LINK%' then 'LINK'
        when S.street_name like '% MEWS%' then 'MEWS'
        when S.street_name like '% NOOK%' then 'NOOK'
        when S.street_name like '% PARADE%' then 'PARADE'
        when S.street_name like '% PLACE%' then 'PLACE'
        when S.street_name like '% PLAZA%' then 'PLAZA'
        when S.street_name like '% POINT%' then 'POINT'
        when S.street_name like '% QUADRANT%' then 'QUADRANT'
        when S.street_name like '% QUAY%' then 'QUAY'
        when S.street_name like '% RETREAT%' then 'RETREAT'
        when S.street_name like '% RIDGE%' then 'RIDGE'
        when S.street_name like '% RISE%' then 'RISE'
        when S.street_name like '% ROUND%' then 'ROUND'
        when S.street_name like '% ROW%' then 'ROW'
        when S.street_name like '% RUN%' then 'RUN'
        when S.street_name like '% SQUARE%' then 'SQUARE'
        when S.street_name like '% SLOPE%' then 'SLOPE'
        when S.street_name like '% STREET%' then 'STREET'
        when S.street_name like '% STRIP%' then 'STRIP'
        when S.street_name like '% TERRACE%' then 'TERRACE'
        when S.street_name like '% TRACK%' then 'TRACK'
        when S.street_name like '% VIEW%' then 'VIEW'
        when S.street_name like '% VISTA%' then 'VISTA'
        when S.street_name like '% WALK%' then 'WALK'
        when S.street_name like '% WATERS%' then 'WATERS'
        when S.street_name like '% WATERWAY%' then 'WATERWAY'
        when S.street_name like '% WAY%' then 'WAY'
        when S.street_name like '% WYND%' then 'WYND'
        else ''
    end as road_type,
    case
        when upper ( S.street_name )  = 'THE RIALTO WEST' then ''
        when S.street_name like '% NORTH' then 'N'
        when S.street_name like '% SOUTH' then 'S'
        when S.street_name like '% EAST' then 'E'
        when S.street_name like '% WEST' then 'W'
        else ''
    end as road_suffix,
    L.locality_name as locality_name,
    L.postcode as postcode,
    '' as access_type,
    '' as easting,
    '' as northing,
    '' as datum_proj,
    '' as outside_property,
    '363' as lga_code,
    '' as crefno,
    '' as summary
from
    techone_nucproperty P
    join techone_nucaddress A on A.property_no = P.property_no
    join techone_nucstreet S on S.street_no = A.street_no
    join techone_nuclocality L on L.locality_ctr = S.locality_ctr
where
    P.status in ( 'C' , 'F' )
)
)
)
