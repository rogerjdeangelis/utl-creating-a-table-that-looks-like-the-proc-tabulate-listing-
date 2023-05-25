%let pgm=utl-creating-a-table-that-looks-like-the-proc-tabulate-listing;

Creating a table that looks like the proc tabulate listing

github
https://tinyurl.com/3mwp5nr3
https://github.com/rogerjdeangelis/utl-creating-a-table-that-looks-like-the-proc-tabulate-listing-

Proc tabulate does not provide an 'ods output table=mytab' that has the layout of the listing.
You can either output to ods excel and then input or use the technique below.
Alos you can work with the non ods output dataset;

Technique first proposed by
   Bartosz Jablonski
   yabwon@gmail.com

The technique works with an procedure that puts aout a grid layout, ie proc report and pro freq.
Freq and report to not honor the listing layout.

Macro on end and at

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

related
https://tinyurl.com/436m3p4e
https://github.com/rogerjdeangelis?tab=repositories&q=tabulat&type=&language=&sort=

/*        _           _       _         _ _     _   _
| |_ __ _| |__  _   _| | __ _| |_ ___  | (_)___| |_(_)_ __   __ _
| __/ _` | `_ \| | | | |/ _` | __/ _ \ | | / __| __| | `_ \ / _` |
| || (_| | |_) | |_| | | (_| | ||  __/ | | \__ \ |_| | | | | (_| |
 \__\__,_|_.__/ \__,_|_|\__,_|\__\___| |_|_|___/\__|_|_| |_|\__, |
                                                            |___/
*/

/***************************************************************************************************************************/
/*                                                           |                                                             */
/*                                                           |  RULES                                                      */
/*  --------------------------------------------------       |                                                             */
/*  |                  |        TRT        |         |       |  Send output to file (proc printto)                         */
/*  |                  |-------------------|         |       |                                                             */
/*  |                  | Aspirin | Placebo |   All   |       |  Remove header records and substtute name row               */
/*  |                  |---------+---------+---------|       |                                                             */
/*  |                  |   |ColP-|   |ColP-|   |ColP-|       |  title "|Type|AspN|AspPct|PlaN|PlaPct|AllN|allPct|";        */
/*  |                  | N | ctN | N | ctN | N | ctN |       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |  Create intermediat dataset (useful for fine tune)          */
/*  |RACE              |   |     |   |     |   |     |       |                                                             */
/*  |------------------|   |     |   |     |   |     |       |  Here is the final file bebore PROC IMPORT DELIMITER |      */
/*  |Black             |  5| 29.4|  4| 26.7|  9| 28.1|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |  |Type|AspN|AspPct|PlaN|PlaPct|AllN|allPct|                 */
/*  |Multi-Race        |  3| 17.6|  .|    .|  3|  9.4|       |  RACE              |   |     |   |     |   |     |          */
/*  |------------------+---+-----+---+-----+---+-----|       |  Black             |  5| 29.4|  4| 26.7|  9| 28.1|          */
/*  |White             |  9| 52.9| 11| 73.3| 20| 62.5|       |  Multi-Race        |  3| 17.6|  .|    .|  3|  9.4|          */
/*  |------------------+---+-----+---+-----+---+-----|       |  White             |  9| 52.9| 11| 73.3| 20| 62.5|          */
/*  |GENDER            |   |     |   |     |   |     |       |  GENDER            |   |     |   |     |   |     |          */
/*  |------------------|   |     |   |     |   |     |       |  F                 | 13| 76.5|  8| 53.3| 21| 65.6|          */
/*  |F                 | 13| 76.5|  8| 53.3| 21| 65.6|       |  M                 |  4| 23.5|  7| 46.7| 11| 34.4|          */
/*  |------------------+---+-----+---+-----+---+-----|       |  ETHNICITY         |   |     |   |     |   |     |          */
/*  |M                 |  4| 23.5|  7| 46.7| 11| 34.4|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |  Run proc import                                            */
/*  |ETHNICITY         |   |     |   |     |   |     |       |                                                             */
/*  |------------------|   |     |   |     |   |     |       |                                                             */
/*  |Hispanic          |  5| 29.4| 12| 80.0| 17| 53.1|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |Non-Hispanic      | 12| 70.6|  3| 20.0| 15| 46.9|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |AGEGROUP          |   |     |   |     |   |     |       |                                                             */
/*  |------------------|   |     |   |     |   |     |       |                                                             */
/*  |18-39             |  9| 52.9|  5| 33.3| 14| 43.8|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |40-64             |  1|  5.9|  2| 13.3|  3|  9.4|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |40-65             |  2| 11.8|  1|  6.7|  3|  9.4|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |40-66             |  1|  5.9|  2| 13.3|  3|  9.4|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |65+               |  4| 23.5|  5| 33.3|  9| 28.1|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |FOLLOWUP_FLAG     |   |     |   |     |   |     |       |                                                             */
/*  |------------------|   |     |   |     |   |     |       |                                                             */
/*  |0                 | 13| 76.5|  5| 33.3| 18| 56.3|       |                                                             */
/*  |------------------+---+-----+---+-----+---+-----|       |                                                             */
/*  |1                 |  4| 23.5| 10| 66.7| 14| 43.8|       |                                                             */
/*  --------------------------------------------------       |                                                             */
/*                                                           |                                                             */
/***************************************************************************************************************************/


/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*                        Aspirin     Placebo     total                                                                   */
/*    TYPE                (N= 17 )    (N= 15 )    (N= 32 )                                                                */
/*    RACE                                                                                                                */
/*      Black               5(29.4%)    4(26.7%)    9(28.1%)                                                              */
/*      Multi-Race          3(17.6%)         (%)     3(9.4%)                                                              */
/*      White               9(52.9%)   11(73.3%)   20(62.5%)                                                              */
/*    GENDER                                                                                                              */
/*      F                  13(76.5%)    8(53.3%)   21(65.6%)                                                              */
/*      M                   4(23.5%)    7(46.7%)   11(34.4%)                                                              */
/*    ETHNICITY                                                                                                           */
/*      Hispanic            5(29.4%)   12(80.0%)   17(53.1%)                                                              */
/*      Non-Hispanic       12(70.6%)    3(20.0%)   15(46.9%)                                                              */
/*    AGEGROUP                                                                                                            */
/*      18-39               9(52.9%)    5(33.3%)   14(43.8%)                                                              */
/*      40-64                1(5.9%)    2(13.3%)     3(9.4%)                                                              */
/*      40-65               2(11.8%)     1(6.7%)     3(9.4%)                                                              */
/*      40-66                1(5.9%)    2(13.3%)     3(9.4%)                                                              */
/*      65+                 4(23.5%)    5(33.3%)    9(28.1%)                                                              */
/*    FOLLOWUP_FLAG                                                                                                       */
/*      0                  13(76.5%)    5(33.3%)   18(56.3%)                                                              */
/*      1                   4(23.5%)   10(66.7%)   14(43.8%)                                                              */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

data have;
   retain trt;
   informat Race Gender Ethnicity AgeGroup $24.;
   input patient_ID Race Gender Ethnicity AgeGroup Followup_Flag Vaccine_Flag;
   if Vaccine_Flag=0 then trt='Aspirin';else trt='Placebo';
   drop vaccine_flag;
cards4;
1 White F Hispanic 18-39 1 1
2 White M Non-Hispanic 18-39 0 0
3 Black F Hispanic 40-64 0 0
4 White M Hispanic 65+ 1 1
5 Multi-Race F Non-Hispanic 18-39 0 0
6 White M Hispanic 18-39 1 1
7 White F Non-Hispanic 40-65 0 1
8 White F Hispanic 65+ 1 1
9 Black M Non-Hispanic 18-39 0 1
10 White F Hispanic 18-39 1 0
11 White M Hispanic 40-66 1 0
12 Black F Non-Hispanic 65+ 0 1
13 Black F Hispanic 40-64 0 1
14 White F Hispanic 65+ 1 1
15 Multi-Race F Non-Hispanic 18-39 0 0
16 White M Hispanic 18-39 1 1
17 White F Non-Hispanic 40-65 0 0
18 White F Non-Hispanic 65+ 1 0
19 Black M Non-Hispanic 18-39 0 0
20 White F Hispanic 18-39 0 0
21 White M Hispanic 40-66 1 1
22 Black F Non-Hispanic 65+ 0 0
23 Black F Hispanic 40-64 0 1
24 White F Hispanic 65+ 1 1
25 Multi-Race F Non-Hispanic 18-39 0 0
26 White M Hispanic 18-39 1 1
27 White F Non-Hispanic 40-65 0 0
28 White F Non-Hispanic 65+ 1 0
29 Black M Non-Hispanic 18-39 0 0
30 White F Hispanic 18-39 0 0
31 White M Hispanic 40-66 1 1
32 Black F Non-Hispanic 65+ 0 0
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  Up to 40 obs from HAVE total obs=32 25MAY2023:11:39:35                                                                */
/*                                                                        PATIENT_    FOLLOWUP_                           */
/*  Obs      TRT      RACE          GENDER    ETHNICITY       AGEGROUP       ID          FLAG                             */
/*                                                                                                                        */
/*    1    Placebo    White           F       Hispanic         18-39          1           1                               */
/*    2    Aspirin    White           M       Non-Hispanic     18-39          2           0                               */
/*    3    Aspirin    Black           F       Hispanic         40-64          3           0                               */
/*    4    Placebo    White           M       Hispanic         65+            4           1                               */
/*    5    Aspirin    Multi-Race      F       Non-Hispanic     18-39          5           0                               */
/*    6    Placebo    White           M       Hispanic         18-39          6           1                               */
/*    7    Placebo    White           F       Non-Hispanic     40-65          7           0                               */
/*    8    Placebo    White           F       Hispanic         65+            8           1                               */
/*    9    Placebo    Black           M       Non-Hispanic     18-39          9           0                               */
/*   10    Aspirin    White           F       Hispanic         18-39         10           1                               */
/*   11    Aspirin    White           M       Hispanic         40-66         11           1                               */
/*   12    Placebo    Black           F       Non-Hispanic     65+           12           0                               */
/*   13    Placebo    Black           F       Hispanic         40-64         13           0                               */
/*   14    Placebo    White           F       Hispanic         65+           14           1                               */
/*   15    Aspirin    Multi-Race      F       Non-Hispanic     18-39         15           0                               */
/*   16    Placebo    White           M       Hispanic         18-39         16           1                               */
/*   17    Aspirin    White           F       Non-Hispanic     40-65         17           0                               */
/*   18    Aspirin    White           F       Non-Hispanic     65+           18           1                               */
/*   19    Aspirin    Black           M       Non-Hispanic     18-39         19           0                               */
/*   20    Aspirin    White           F       Hispanic         18-39         20           0                               */
/*   21    Placebo    White           M       Hispanic         40-66         21           1                               */
/*   22    Aspirin    Black           F       Non-Hispanic     65+           22           0                               */
/*   23    Placebo    Black           F       Hispanic         40-64         23           0                               */
/*   24    Placebo    White           F       Hispanic         65+           24           1                               */
/*   25    Aspirin    Multi-Race      F       Non-Hispanic     18-39         25           0                               */
/*   26    Placebo    White           M       Hispanic         18-39         26           1                               */
/*   27    Aspirin    White           F       Non-Hispanic     40-65         27           0                               */
/*   28    Aspirin    White           F       Non-Hispanic     65+           28           1                               */
/*   29    Aspirin    Black           M       Non-Hispanic     18-39         29           0                               */
/*   30    Aspirin    White           F       Hispanic         18-39         30           0                               */
/*   31    Placebo    White           M       Hispanic         40-66         31           1                               */
/*   32    Aspirin    Black           F       Non-Hispanic     65+           32           0                               */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

/*--- probably bo needed the macro already does most of these ---*/
proc datasets lib=work nodetails nolist;
 delete _temp want_odsrpt want;
run;quit;

%symdel aspirin placebo total /nowarn;

%utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);
%utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

options ls=255;
%utl_odstbx(setup);
proc tabulate data=have;
   /*---  cols has to equal the number of bars ---*/
   title "|Type|AspN|AspPct|PlaN|PlaPct|AllN|allPct|";
   class TRT Race Gender Ethnicity AgeGroup Followup_Flag;
   table
      Race Gender Ethnicity AgeGroup Followup_Flag
      ,
      trt*(N*f=3. COLPCTN*f=f5.1) All*(N*f=3. COLPCTN*f=5.1)/rts=20 ;
   ;
run;quit;
%utl_odstbx(outdsn=want_odsrpt,intermediate=_temp);

proc sql;
  create
      table want as
  select
     case
       when (aspn ne "") then cats("  ",type)
       else Type
     end as type length=18
    ,case when (aspn ne "") then right(put(cats(aspn,'(',asppct,'%)'),$10.)) end as Aspirin
    ,case when (aspn ne "") then right(put(cats(plan,'(',plapct,'%)'),$10.)) end as Placebo
    ,case when (aspn ne "") then right(put(cats(alln,'(',allpct,'%)'),$10.)) end as Total
  from
     want_odsrpt
;quit;

proc sql;
    select resolve(catx(" ",'%Let',trt,'=',trt,'#(N=',Put(Count(*),2.),');')) from have  Group by trt;
    select resolve(catx(" ",'%Let total=total','#(N=',Put(Count(*),2.),');')) from have;
;quit;

%put &=aspirin; /*---- ASPIRIN=Aspirin #(N= 17 ) ----*/
%put &=placebo; /*---- PLACEBO=Placebo #(N= 15 ) ----*/
%put &=total;   /*---- TOTAL=Total #(N= 32 ) ----*/

title1;
proc report data=want missing split='#';
define  aspirin  / "&aspirin" ;
define  placebo  / "&placebo" ;
define  total    / "&total"   ;
run;quit;

/*
 _ __ ___   __ _  ___ _ __ ___
| `_ ` _ \ / _` |/ __| `__/ _ \
| | | | | | (_| | (__| | | (_) |
|_| |_| |_|\__,_|\___|_|  \___/

*/

/*---- Thid dsve the macro in your autocall library ----*/
filename ft15f001 "c:/oto/utl_odsTbx.sas";
parmcards4;
%macro utl_odsTbx(outdsn,intermediate=_temp);

   %utl_close;

   proc datasets lib=work nolist;  *just in case;
    delete &outdsn;
   run;quit;

   %if %qupcase(&outdsn)=SETUP %then %do;

        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);

        OPTIONS ls=max ps=32756  FORMCHAR='|'  nodate nocenter;

        proc printto print="%sysfunc(pathname(work))/_tmp1_.txt" new;
        run;quit;

   %end;
   %else %do;

        proc printto;
        run;quit;

        PROC SQL noprint;
          select
             text
            ,countc(Text,'|')
          into
             :_ttl TRIMMED
            ,:_col
          from
              Dictionary.Titles
          where
              Type="T" & Number=1;
          quit;

        %put &_ttl;
        %put &_col;

        /*---- just for checking ----*/
        data _null_;
          infile "%sysfunc(pathname(work))/_tmp1_.txt";
          input;
          putlog _infile_;
        run;quit;

        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

        data _null_;

          infile "%sysfunc(pathname(work))/_tmp1_.txt" length=l;
          file "%sysfunc(pathname(work))/_tmp2_.txt" ;

          input lyn $varying32756. l;

          if _n_=1 then do;
             put lyn;
             putlog lyn;
          end;
          else do;
            if countc(lyn,'|')=&_col then do;
               put lyn;
               putlog lyn;
            end;
          end;

        run;quit;

        proc import
           datafile="%sysfunc(pathname(work))/_tmp2_.txt"
           dbms=dlm
           out=&intermediate(drop=var:)
           replace;
           delimiter='|';
           getnames=yes;
        run;quit;

        /*---- clean up intermediate dataset ----*/
        data &outdsn;
           set &intermediate;
           array chr _character_;
           if substr(chr[1],1,5)='     ' or substr(chr[1],1,5)='-----' then delete;
         run;quit;

        * turn off for production;
        %utlfkil(%sysfunc(pathname(work))/_tmp1_.txt);
        %utlfkil(%sysfunc(pathname(work))/_tmp2_.txt);

        proc datasets lib = work nodetails nolist;
          modify &outdsn ;
            attrib _all_ label = "" ;
            format _all_;
            informat _all_;
          run ;
        quit ;
   %end;
   options formchar='|----|+|---+=|-/\<>*';
   %utl_close;
%mend utl_odstbx;
;;;;
run;quit;

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
