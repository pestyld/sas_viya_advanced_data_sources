/*******************************************************************************/
/*  CREATE DEMONSTRATION DATA                                                  */
/*******************************************************************************/
/* REQUIREMENTS: SAS VIYA MUST BE ENABLED TO DOWNLOAD DATA FROM THE INTERNET   */
/*******************************************************************************/
/*  Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved. */
/*  SPDX-License-Identifier: Apache-2.0                                        */
/*******************************************************************************/


/******************************************/
/* FIND PATH FOR THE PROJECT FOLDER       */
/******************************************/
/* REQUIRED: Specify the location in your explorer where you want to create the data */
/* Dynamically finds the current directory path based on where the program is saved and stores it in 
   the path macro variable. Valid in SAS Studio.  */
%let fileName =  /%scan(&_sasprogramfile,-1,'/');  
%let datapath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));

/* Confirm the path is as expected */
%put &=datapath;

/* Create library */
libname mydata "&datapath";


%include "&datapath./01_create_flat_data.sas";

