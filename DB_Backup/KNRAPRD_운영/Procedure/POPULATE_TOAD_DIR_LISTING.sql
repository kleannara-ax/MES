--------------------------------------------------------
--  DDL for Procedure POPULATE_TOAD_DIR_LISTING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."POPULATE_TOAD_DIR_LISTING" 
( p_directory in varchar2 )
  as language java
  name 'ToadDirList.getList( java.lang.String )';

/
