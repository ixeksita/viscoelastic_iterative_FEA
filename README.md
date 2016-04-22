# viscoelastic_iterative_FEA
MATLAB, ABAQUS, Python and C++ codes used to perfom the automated iterative FEA on a determined sample 
Note that is is intended to use with previously cleaned data, meaning that the input data for this method
is the representative indentation curve and not the sets of the raw indentation data.

If you need to perform the data cleaning on the set of raw indentation data you should use the files contained 
in the repository called Pre-processing (indentation).

The file named as PDMS2.dat is the file containing the indentation data.
In order to run the automated process you just need to call main.m from MATLAB and it will call the rest of the codes. 

Brief guide to the codes and files:
1. PDMS2.dat (indentation data)
2. main. m (code in MATLAB to run the whole iterative process)
3. creepoptimization.m (fit to the analytical solution which provides the intiial guess for the material parameters)
4. objective creep.f (function used by 3)
5. Optim_loop2.m (compares the FE data vs the real data and fits them to optimize the parameters)
6. obj_Loop.f (function used by 5)
7. Plotting (plots FE vs real data)
8. ***.inp (ABAQUS input file)
9. umat.exe (executable in C that replaces the material parameters)
10. lista.bat (executable to run the ABAQUS analysis)
11. getdata.py (Python script to retrieve FE results)

