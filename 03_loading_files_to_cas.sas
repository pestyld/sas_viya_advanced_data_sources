/*************************************************************************************************
 LOADING DIFFERENT FILE TYPES TO CAS
*****************************************************************************
 REQUIREMENTS: 
	- Must run the workshop/utility/utility_macros.sas program prior
*****************************************************************************
 Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
 SPDX-License-Identifier: Apache-2.0                                       
*****************************************************************************/


/******************************************
 1. PATH FOR THE WORKSHOP FOLDER      
******************************************/
%getcwd(path)
%put &=path;


/**********************************************************
 2. CONNECT TO CAS AND LOAD PDF FILES INTO A CAS TABLE     
***********************************************************/
/* loadTable action (has the import option info - https://go.documentation.sas.com/doc/en/pgmsascdc/default/caspg/cas-table-loadtable.htm */
/* PROC CASUTIL - https://go.documentation.sas.com/doc/en/pgmsascdc/default/casref/n03spmi9ixzq5pn11lneipfwyu8b.htm#n1nj5zckmttquen1siwyi8gfsf0q */

proc casutil;
	list files incaslib='my_pdfs'; 
quit;