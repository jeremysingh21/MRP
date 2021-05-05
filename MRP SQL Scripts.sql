##ADD NEW GEOM COLUMN AND REPROJECT
alter table public.gta_malls  
add column geom_proj geometry;
Update public.gta_malls set geom_proj = st_transform(geom,26917)

alter table public.census_data  
add column geom_proj geometry;
Update public.census_data set geom_proj = st_transform(geom,26917)

### Get trade areas and find intersecting Census tracts
SELECT ta.*, c.*, ST_AREA(c.geom_26917) as area_norm
INTO ta_buffers
FROM (
SELECT *, CASE 
when floor_spac BETWEEN 40000 AND 150000
	then st_buffer(geom_proj, 3000)
when floor_spac BETWEEN 150000 AND 250000
	then st_buffer(geom_proj, 5000)
When floor_spac BETWEEN 250000 AND 500000
	then st_buffer(geom_proj, 7000)
when floor_spac BETWEEN 500000 AND 1000000
	then st_buffer(geom_proj, 10000)
else st_buffer(geom_proj, 15000)
	END as buffer
from gta_malls
	) AS ta, public.census_data as c
WHERE ST_intersects(ta.buffer, c.geom_26917) 
	ORDER BY shopping_c

########Get the number of centers within the trade area of each mall
SELECT ta_buffers.shopping_c, count(gta_malls.geom) AS competition
INTO competition
FROM ta_buffers INNER JOIN gta_malls 
ON st_contains(gta_malls.geom, ta_buffers.geom)
GROUP BY ta_buffers.shopping_C

##Get Averages and Normalize demographic variables by area size
select shopping_c, shopping_1, shopping_2, shopping_3, shopping_4, 
		total_est_, parking_sp, floor_spac, mall_hiera, levels, 
		total_stor,lon, lat, geom_proj,
avg(total_hh/area_norm) as avg_hh_area,
avg(total_chil/area_norm) as avg_children_area,
avg(total_pop/area_norm) as avg_pop_area,
avg(total_expe/area_norm) as avg_exp_cloth_area,
avg(total_ex_1/area_norm) as avg_tot_expfood_area,
avg(total_ex_2/area_norm) as avg_exp_food_rest_area,
avg(vm_2019/area_norm) as avg_vm2019_area,
avg(vm_black/area_norm) as avg_vm_black_area,
avg(vm_chinese/area_norm) as avg_vm_chinese_area,
avg(vm_filipin/area_norm) as avg_vm_filipino_area,
avg(vm_latinam/area_norm) as avg_vm_latinAmerican_area,
avg(vm_south_a/area_norm) as avg_vm_southAsian_area,
avg(vm_se_asia/area_norm) as avg_SE_Asian_area,
avg(vm_west_as/area_norm) as avg_vm_WestAsian_area,
avg(vm_japanes/area_norm) as avg_vm_Japanese_area,
avg(vm_multipl/area_norm) as avg_vm_MultipleVM_area,
avg(not_vm/area_norm) as avg_not_vm_area,
avg(vm_allothe/area_norm) as avg_vm_allOthers_area,
avg(prj_vm_ara/area_norm) as avg_prj_arab_area,
avg(prj_vm_bla/area_norm) as avg_prj_black_area,
avg(prj_vm_chi/area_norm) as avg_prj_chinese_area,
avg(prj_vm_fil/area_norm) as avg_prj_filipino_area,
avg(prj_vm_kor/area_norm) as avg_prj_koren_area_area,
avg(prj_vm_lat/area_norm) as avg_prj_latinAmerican_area,
avg(prj_vm_sou/area_norm) as avg_prj_SouthEastAsian_area,
avg(prj_vm_wes/area_norm) as avg_prj_WestAsian_area,
avg(prj_vm_mul/area_norm) as avg_prj_multipleVm_area,
avg(prj_vm_all/area_norm) as avg_prj_allvm_area,
avg(avg_hh_inc) as avg_income,
avg(total_labourforce/area_norm) as avg_labour_area,
avg(uni_degree/area_norm) as avg_degree_area,
avg(total_spend/area_norm) as avg_spend_area,
avg(prj_vm_all/area_norm) as avg_prj_allother_area 
INTO ta_with_demo
FROM ta_buffers
group by shopping_c, shopping_1, shopping_2, shopping_3, shopping_4, 
		total_est_, parking_sp, floor_spac, mall_hiera, levels, 
		total_stor,lon, lat, geom_proj

### Create averages with RAW data
select shopping_c, shopping_1, shopping_2, shopping_3, shopping_4, 
		total_est_, parking_sp, floor_spac, mall_hiera, levels, 
		total_stor,lon, lat, SUM(area_norm) as area_norm, geom_proj,
avg(total_hh) as avg_hh,
avg(total_chil) as avg_children,
avg(total_pop) as avg_pop,
avg(total_expe) as avg_exp_cloth,
avg(total_ex_1) as avg_tot_expfood,
avg(total_ex_2) as avg_exp_food_rest,
avg(vm_2019) as avg_vm2019,
avg(vm_black) as avg_vm_black,
avg(vm_chinese) as avg_vm_chinese,
avg(vm_filipin) as avg_vm_filipino,
avg(vm_latinam) as avg_vm_latinAmerican,
avg(vm_south_a) as avg_vm_southAsian,
avg(vm_se_asia) as avg_SE_Asian,
avg(vm_west_as) as avg_vm_WestAsian,
avg(vm_japanes) as avg_vm_Japanese,
avg(vm_multipl) as avg_vm_MultipleVM,
avg(not_vm) as avg_not_vm,
avg(vm_allothe) as avg_vm_allOthers,
avg(prj_vm_ara) as avg_prj_arab,
avg(prj_vm_bla) as avg_prj_black,
avg(prj_vm_chi) as avg_prj_chinese,
avg(prj_vm_fil) as avg_prj_filipino,
avg(prj_vm_kor) as avg_prj_koren,
avg(prj_vm_lat) as avg_prj_latinAmerican,
avg(prj_vm_sou) as avg_prj_SouthEastAsian,
avg(prj_vm_wes) as avg_prj_WestAsian,
avg(prj_vm_mul) as avg_prj_multipleVm,
avg(prj_vm_all) as avg_prj_allvm,
avg(avg_hh_inc) as avg_income,
avg(total_labourforce) as avg_labour,
avg(uni_degree) as avg_degree,
avg(total_spend) as avg_spend,
avg(prj_vm_all) as avg_prj_allother 
INTO ta_rawavg_demo
FROM ta_buffers
group by shopping_c, shopping_1, shopping_2, shopping_3, shopping_4, 
		total_est_, parking_sp, floor_spac, mall_hiera, levels, 
		total_stor,lon, lat,geom_proj

##Get Averages with changed demographic variables by area size


SELECT shopping_c, shopping_1, shopping_2, shopping_3, shopping_4, 
total_est_, parking_sp, floor_spac, total_stor, lon, lat, 
area_norm, 
avg_hh/area_norm as avg_hh_area, 
avg_children/area_norm as avg_children_area, 
avg_pop/area_norm as avg_pop_area, 
avg_tot_expfood/area_norm as avg_tot_expfood_area, 
avg_vm2019/area_norm as avg_vm2019_area, 
avg_not_vm/area_norm as avg_not_vm_area,
avg_income/area_norm as avg_income, 
avg_labour/area_norm as avg_labour_area, 
avg_degree/area_norm as avg_degree_area,
avg_spend/area_norm as avg_spend_area
INTO ta_casestudy
FROM public.ta_rawavg_demo;

############Get Percentage##########
select shopping_c,floor_spac,total_stor,lon, lat, geom_proj,
sum(total_hh) as total_hh,
sum(total_chil)/sum(total_pop) as chil_percent,
avg(avg_hh_inc) as avg_income,
sum(total_ex_2) as total_exp_food,
sum(vm_2019)/sum(total_pop) as vm_percent,
sum(not_vm)/sum(total_pop) as notvm_percent,
sum(total_labourforce)/sum(total_pop) as lbforce_percent,
sum(uni_degree)/sum(total_pop) as degree_percent,
sum(total_spend) as totalexp
INTO ta_with_demo
FROM ta_buffers
group by shopping_c,floor_spac,total_stor,lon, lat, geom_proj

######Join competitor information#########
alter table public.ta_with_demo  
add column competition bigint;

UPDATE ta_with_demo
SET competition = competition.competition
FROM competition
WHERE ta_with_demo.shopping_c = competition.shopping_c;
