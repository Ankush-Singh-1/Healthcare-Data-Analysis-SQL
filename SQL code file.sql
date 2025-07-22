----------------------------------------------------Data Exploration------------------------------------------------------
-- check entire data
select * from patient_data;

-- check unique category 
select distinct gender as gender_category
from patient_data
select distinct "blood type" as blood_type_category
from patient_data

-- Summary stats
select max(age) from patient_data as Max_age
select min(age) from patient_data as Min
select avg("billing amount") from patient_data

-----------------------------------------------------Data cleaning---------------------------------------------------------
select * from patient_data
where "name" IS NULL OR age IS NULL OR gender IS NULL OR "blood type" IS NULL OR 
      "medical condition" IS NULL OR "date of admission" IS NULL OR doctor IS NULL OR 
      hospital IS NULL OR "insurance provider" IS NULL OR "billing amount" IS NULL OR 
      "room number" IS NULL OR "admission type" IS NULL OR "discharge date" IS NULL OR 
      medication IS NULL OR "test results" IS NULL;

--- delete null value(No null value was there)

--- check for duplicates
select "name", age,"blood type",gender,"insurance provider","discharge date","date of admission"
       ,"billing amount",count(*) as record_count 
from patient_data
group by name,age,"blood type",gender,"insurance provider","discharge date","billing amount","date of admission"
Having count(*)>1;

--- Remove Duplicates
With Dupli As(
     select ctid,
	 Row_number() over (partition by "name",age 
	 order by "name",age) as rn
     from patient_data
)
delete from patient_data
where ctid in (select ctid from Dupli where rn>1)

--- standardize text column
UPDATE patient_data
SET name = LOWER(name);

---Extract year from date of admission
select Extract(year from "date of admission")
from patient_data

---Extract month from date of admission
select Extract(month from "date of admission")
from patient_data


-----------------------------------------------Data Analysis---------------------------------------------------

--- 1. What medical condition has highest average billing amount?

select "medical condition", count(*) as no_of_patient,avg("billing amount") as avg_billing_amount
from patient_data
group by "medical condition"
order by "avg_billing_amount" Desc

--- 2. what is the average length of stay per admission type?

with stay_data as(
select
     "admission type",age("discharge date","date of admission") as length_of_stay
from patient_data)

select "admission type",Round(avg(EXTRACT(day FROM length_of_stay)),1) as avg_length_stay
from stay_data
group by "admission type";
--- 3. Which insurance providers cover the highest cost cases?

select
"insurance provider" , Round(sum("billing amount")::numeric,2) as total_billing
from patient_data
group by "insurance provider"
order by total_billing desc

--- 4. what are the most common medication used per diagnosis?

select "medical condition", medication , count(*) as usage_count
from patient_data
group by "medical condition",medication 
order by "medical condition" , usage_count desc

--- 5. what is the average time to discharge by hospital?
with time_data as (select hospital, age("discharge date", "date of admission") as discharge_time
from patient_data)
select hospital,avg(discharge_time) as avg_discharge_time
from time_data
group by hospital 
order by avg_discharge_time desc;



