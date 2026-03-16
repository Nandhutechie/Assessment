{% macro mark_inactive_record(trunc_flag) %}

    {% set query1 %}
        UPDATE {{ this }}
        SET active_flag = 'N'
        WHERE dbt_valid_to::date != '9999-12-31'
        and active_flag = 'Y'
    {% endset %}

    {% if execute %}
        {% do run_query(query1) %}
    {% endif %}

    {% if trunc_flag == "Y" %}

        {% set query2 %}
                UPDATE {{ this }} t1
                SET audit_updated_by = 'ETL-Delete'
                WHERE audit_updated_by = 'ETL-Update'
                AND EXISTS (
                SELECT 1
                FROM {{ this }} t2
                WHERE t2.unq_key_txt = t1.unq_key_txt
                AND t2.audit_updated_by = 'ETL-Delete'
                )
        {% endset %}

        {% if execute %}
            {% do run_query(query2) %}
        {% endif %}

        {% set query3 %}
            DELETE FROM {{ this }}
            WHERE dbt_valid_to::date = '9999-12-31'
              AND audit_updated_by = 'ETL-Delete'
        {% endset %}

        {% if execute %}
            {% do run_query(query3) %}
        {% endif %}

    {% endif %}

{% endmacro %}