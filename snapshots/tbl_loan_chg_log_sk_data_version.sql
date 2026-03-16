{% snapshot tbl_loan_chg_log_sk_data_version %}

{{ config(
    unique_key   = ['loan_key','rec_type','chg_sq','sor_cd'],
    strategy     = "check",
    check_cols   = [
        'unq_key_txt','loan_nbr',
        'chg_type_flg_1','chg_type_flg_2','chg_type_flg_3',
        'chg_type_flg_4','chg_type_flg_5','chg_type_flg_6',
        'chg_type_flg_7','chg_type_flg_8','chg_type_flg_9',
        'chg_type_flg_10','chg_type_flg_11',
        'chg_dt_1','chg_dt_2','chg_dt_3','chg_dt_4','chg_dt_5',
        'chg_dt_6','chg_dt_7','chg_dt_8','chg_dt_9','chg_dt_10','chg_dt_11',
        'chg_amt_1','chg_amt_2','chg_amt_3','chg_amt_4','chg_amt_5',
        'chg_amt_6','chg_amt_7','chg_amt_8','chg_amt_9','chg_amt_10','chg_amt_11'
    ],
    post_hook = [
    "{{ mark_inactive_record(var('trunc_flag', 'N')) }}"
    ],

    dbt_valid_to_current       = "to_timestamp('9999-12-31 23:59:59.9999999')",
    snapshot_meta_column_names = {
        "dbt_valid_from" : "effective_start_date",
        "dbt_valid_to"   : "effective_end_date",
        "dbt_scd_id"     : "hash_val",
        "dbt_updated_at" : "audit_updated_datetime"
    }
) }}


with CTE_SRC_SS_SRVCHG as (
    select distinct
        cast(s.loan_nbr_num       as varchar(16))  as loan_nbr,
        cast(l.lsbrand            as varchar(16))  as brnd_nm,
        cast(s.record_type        as char(1))      as rec_type,
        cast(s.change_sequence    as numeric(3,0)) as chg_sq,
        cast(s.change_type_flag1  as char(1))      as chg_type_flg_1,
        cast(s.change_type_flag2  as char(1))      as chg_type_flg_2,
        cast(s.change_type_flag3  as char(1))      as chg_type_flg_3,
        cast(s.change_type_flag4  as char(1))      as chg_type_flg_4,
        cast(s.change_type_flag5  as char(1))      as chg_type_flg_5,
        cast(s.change_type_flag6  as char(1))      as chg_type_flg_6,
        cast(s.change_type_flag7  as char(1))      as chg_type_flg_7,
        cast(s.change_type_flag8  as char(1))      as chg_type_flg_8,
        cast(s.change_type_flag9  as char(1))      as chg_type_flg_9,
        cast(s.change_type_flag10 as char(1))      as chg_type_flg_10,
        cast(s.change_type_flag11 as char(1))      as chg_type_flg_11,
        cast(s.change_date1       as varchar(10))  as chg_dt_1,
        cast(s.change_date2       as varchar(10))  as chg_dt_2,
        cast(s.change_date3       as varchar(10))  as chg_dt_3,
        cast(s.change_date4       as varchar(10))  as chg_dt_4,
        cast(s.change_date5       as varchar(10))  as chg_dt_5,
        cast(s.change_date6       as varchar(10))  as chg_dt_6,
        cast(s.change_date7       as varchar(10))  as chg_dt_7,
        cast(s.change_date8       as varchar(10))  as chg_dt_8,
        cast(s.change_date9       as varchar(10))  as chg_dt_9,
        cast(s.change_date10      as varchar(10))  as chg_dt_10,
        cast(s.change_date11      as varchar(10))  as chg_dt_11,
        cast(s.change_amt1        as numeric(9,2)) as chg_amt_1,
        cast(s.change_amt2        as numeric(9,2)) as chg_amt_2,
        cast(s.change_amt3        as numeric(9,2)) as chg_amt_3,
        cast(s.change_amt4        as numeric(9,2)) as chg_amt_4,
        cast(s.change_amt5        as numeric(9,2)) as chg_amt_5,
        cast(s.change_amt6        as numeric(9,2)) as chg_amt_6,
        cast(s.change_amt7        as numeric(9,2)) as chg_amt_7,
        cast(s.change_amt8        as numeric(9,2)) as chg_amt_8,
        cast(s.change_amt9        as numeric(9,2)) as chg_amt_9,
        cast(s.change_amt10       as numeric(9,2)) as chg_amt_10,
        cast(s.change_amt11       as numeric(9,2)) as chg_amt_11
    from {{source('SNOWFLAKE_LEARNING_DB_sk','SRVCHG')}}   s  
    join {{source('SNOWFLAKE_LEARNING_DB_sk','LSLOAN0O')}} l   
        on s.loan_nbr_num = l.lsln_n        
),

CTE_SS_SRC_LOAN_NO_CROSS_REF as (
    select loan_key, loan_nbr, brnd_nm
    from {{source('SNOWFLAKE_LEARNING_DB_sk','TBL_LOAN_MASTER')}}
),

CTE_XFM_SRC as (
    select * from CTE_SRC_SS_SRVCHG
),

CTE_LKP_LOAN_KEY as (
    select
        src.*,
        ref.loan_key
    from CTE_XFM_SRC src
    left join CTE_SS_SRC_LOAN_NO_CROSS_REF ref
        on  ref.loan_nbr = src.loan_nbr
        and ref.brnd_nm  = src.brnd_nm
),

CTE_UPSERT as (
    select
        loan_nbr || '~' || 'LSM' || '~' || chg_sq || '~' || rec_type
                                            as unq_key_txt,
        brnd_nm,
        loan_nbr,
        rec_type,
        chg_sq,
        chg_type_flg_1,  chg_type_flg_2,  chg_type_flg_3,
        chg_type_flg_4,  chg_type_flg_5,  chg_type_flg_6,
        chg_type_flg_7,  chg_type_flg_8,  chg_type_flg_9,
        chg_type_flg_10, chg_type_flg_11,
        case when chg_dt_1  is null or chg_dt_1  = '0' then null
             else try_to_date(chg_dt_1::string,  'YYYYMMDD') end as chg_dt_1,
        case when chg_dt_2  is null or chg_dt_2  = '0' then null
             else try_to_date(chg_dt_2::string,  'YYYYMMDD') end as chg_dt_2,
        case when chg_dt_3  is null or chg_dt_3  = '0' then null
             else try_to_date(chg_dt_3::string,  'YYYYMMDD') end as chg_dt_3,
        case when chg_dt_4  is null or chg_dt_4  = '0' then null
             else try_to_date(chg_dt_4::string,  'YYYYMMDD') end as chg_dt_4,
        case when chg_dt_5  is null or chg_dt_5  = '0' then null
             else try_to_date(chg_dt_5::string,  'YYYYMMDD') end as chg_dt_5,
        case when chg_dt_6  is null or chg_dt_6  = '0' then null
             else try_to_date(chg_dt_6::string,  'YYYYMMDD') end as chg_dt_6,
        case when chg_dt_7  is null or chg_dt_7  = '0' then null
             else try_to_date(chg_dt_7::string,  'YYYYMMDD') end as chg_dt_7,
        case when chg_dt_8  is null or chg_dt_8  = '0' then null
             else try_to_date(chg_dt_8::string,  'YYYYMMDD') end as chg_dt_8,
        case when chg_dt_9  is null or chg_dt_9  = '0' then null
             else try_to_date(chg_dt_9::string,  'YYYYMMDD') end as chg_dt_9,
        case when chg_dt_10 is null or chg_dt_10 = '0' then null
             else try_to_date(chg_dt_10::string, 'YYYYMMDD') end as chg_dt_10,
        case when chg_dt_11 is null or chg_dt_11 = '0' then null
             else try_to_date(chg_dt_11::string, 'YYYYMMDD') end as chg_dt_11,
        chg_amt_1,  chg_amt_2,  chg_amt_3,
        chg_amt_4,  chg_amt_5,  chg_amt_6,
        chg_amt_7,  chg_amt_8,  chg_amt_9,
        chg_amt_10, chg_amt_11,
        loan_key,
        'LSM'                                           as sor_cd,
        'ETL-Insert'::varchar(50)                       as audit_created_by,
        convert_timezone('UTC', current_timestamp())
            ::timestamp_ntz                             as audit_created_datetime,
        'ETL-Update'::varchar(50)                       as audit_updated_by,
        1                                               as etl_batch_id,
        'Y'                                             as active_flag
    from CTE_LKP_LOAN_KEY
),
final as 
(      
		{% if var('trunc_flag', 'N') == 'Y' %}
				select
				unq_key_txt, brnd_nm, rec_type, loan_nbr, chg_sq,
				chg_type_flg_1,  chg_type_flg_2,  chg_type_flg_3,
				chg_type_flg_4,  chg_type_flg_5,  chg_type_flg_6,
				chg_type_flg_7,  chg_type_flg_8,  chg_type_flg_9,
				chg_type_flg_10, chg_type_flg_11,
				chg_dt_1,  chg_dt_2,  chg_dt_3,  chg_dt_4,  chg_dt_5,
				chg_dt_6,  chg_dt_7,  chg_dt_8,  chg_dt_9,  chg_dt_10, chg_dt_11,
				chg_amt_1,  chg_amt_2,  chg_amt_3,  chg_amt_4,  chg_amt_5,
				chg_amt_6,  chg_amt_7,  chg_amt_8,  chg_amt_9,  chg_amt_10, chg_amt_11,
				loan_key,
				'ETL-Delete ' as audit_created_by,
				audit_created_datetime,
				audit_updated_by,
				sor_cd,
				'N' as active_flag
				from {{this}} b
				where active_flag = 'Y'
				and not EXISTS(select 1 from CTE_UPSERT c where
				b.loan_key = c.loan_key and  b.rec_type = c.rec_type
				and b.chg_sq = c.chg_sq and b.sor_cd = c.sor_cd)
            UNION
			{%endif%}
			
				select
				unq_key_txt, brnd_nm, rec_type, loan_nbr, chg_sq,
				chg_type_flg_1,  chg_type_flg_2,  chg_type_flg_3,
				chg_type_flg_4,  chg_type_flg_5,  chg_type_flg_6,
				chg_type_flg_7,  chg_type_flg_8,  chg_type_flg_9,
				chg_type_flg_10, chg_type_flg_11,
				chg_dt_1,  chg_dt_2,  chg_dt_3,  chg_dt_4,  chg_dt_5,
				chg_dt_6,  chg_dt_7,  chg_dt_8,  chg_dt_9,  chg_dt_10, chg_dt_11,
				chg_amt_1,  chg_amt_2,  chg_amt_3,  chg_amt_4,  chg_amt_5,
				chg_amt_6,  chg_amt_7,  chg_amt_8,  chg_amt_9,  chg_amt_10, chg_amt_11,
				loan_key,
				audit_created_by,
				audit_created_datetime,
				audit_updated_by,
				sor_cd,
				active_flag
				from CTE_UPSERT

)
select * from final

{% endsnapshot %}