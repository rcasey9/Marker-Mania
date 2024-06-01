This package only works on Windows.

Follow these steps for processing your MoCap data:

1) If this is your first time using this package on a computer, you will need to run the Setup.m script
 
2) Format your data so that all trials are grouped into folders that contain their respective markerset, Static, and FJC (if you use FJCs) 

*** your static trial must include "Static", "static", or "STATIC" somewhere in its name. No other trials should contain these substrings
     
3) Label your static trial(s), set the region of interest to just 2 total frames, and clear events outside of the region of interest. 
 Run the "static skeleton calibration" and "Set Autolabel Pose" pipelines on your static trial(s).
    
4) If your data quality necessitates Functional Joint Calibrations, label your FJC trial(s) and run the "Functional Joint Calibration" pipeline on them.
 
5) Input the path to your data at the top of the Main.m script and hit run. It can take ~24 hours to process an entire subject depending on the capacity of your computer.
  
6) Input the same path to your data at the top of the Cleanup.m script
 
7) Parse all of the trials in the /Working/ folder(s) and unlabel any drifiting or out of place markers. Some trials in the /Working/ folder may not have any issues present.
  
8) Run the Cleanup.m script. All of your processed data should now be in the /Finished/ folder.
