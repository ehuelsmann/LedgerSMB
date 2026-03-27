
/* renaming input parameter */
drop function if exists inventory_adjust__create(date);
drop function if exists inventory_adjust__save_info(date, text);

alter table inventory_report
  rename column transdate to report_date;
