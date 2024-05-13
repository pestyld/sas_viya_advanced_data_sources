%macro showImage(image);
/* 
    The macro renders images in the SAS notebook or SAS results.

    Parameter:
        image - specify the full path and file name within quotes.
*/

    data _null_;
        declare odsout obj();
        obj.image(file:&image);
    run;

%mend;