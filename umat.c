//This code is used to UPDATE the material parameters from the UMAT after each iteration in the optimization procedure
// Copyright (C) 22016, Tania Sanchez 
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
#define _CRT_SECURE_NO_DEPRECATE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


 int main(void)
   {
    int temp=1;
	int lKE=42,i;
	char c;
	char l;
	char k[]={"KE"};
	char g[]={"GE"};
	char m[]={"GV"};
	char z[]= {"KMe"};
	char u[]={"GMe"};
	int count =1;
	char p;
	char alpha[20]={"KE = "};
	char beta[20]={"GE = "};
	char gamma[20]={"KMe = "};
	char delta[20]={"GMe = "};
	char eta[20]={"GV = "};
	char *value[8];
	char *bulk[8];
	char *val2[8];
	char *cortante[8];
	char *visc[10];

		 	
	FILE* fp,*fp2, *umat;

	//load data from UMAT and copy into variables
	umat=fopen("UMAT.txt", "r");
	if (umat == NULL)
    {
        printf("Error loading file \n");
		getchar();
    }
	 else
	 {
		 printf("DATA OBTAINED FROM MATLAB (INITIAL FIT):\n\n\n");
		 rewind (umat);
		while(fscanf(umat, "%c", &p)!=EOF)
		{
			if (p=='\n')
			{
				count++;
			}
			
			if (count==2){
				fscanf(umat,"%s",value);
				strcat(alpha,value);
				puts(alpha);
				count=3;
				}
			if (count==3){
				fscanf(umat,"%s",bulk);
				strcat(beta,bulk);
				puts (beta);
			    count==4;
			}				
			if (count==4){
				fscanf(umat,"%s",val2);
				strcat(gamma,val2);
				puts (gamma);
				count=5;
				}
			if (count==5){
				fscanf(umat,"%s",cortante);
				strcat(delta,cortante);
				puts (delta);
				count=6;
				}
			if (count==6){
				fscanf(umat,"%s",visc);
				strcat(eta,visc);
				puts (eta);
			}
  		 }
	//printf("Los coeficientes a usar son: %s\n %s\n %s\n %s\n %s\n", alpha, beta, gamma, delta, eta);
	fclose(umat);
	//getchar();
	}

	//OPEN THE SUBROUTINE UMAT FILE
   fp= fopen("sls.for", "r");
	     if (fp == NULL)
    {
        printf("Error loading file \n");
		getchar();
		exit(1);
    }
	 else
	 {
		 printf("File loaded now\n");
	 }
	
	//open in read mode and print the contents of file
	c= getc(fp);
	while (c!= EOF)
	{
		printf("%c", c);
		c= getc(fp);
	}
	
	//open in writing mode (WILL BE THE UPDATED FILE)
	fp2= fopen("slsbis.for", "w");
	rewind (fp);
	c= getc(fp);
	while (c!= EOF)
	{
		if (c=='\n')
		{
			temp++;
		}
		if (temp != lKE && temp!=lKE+2 && temp!=lKE+4 && temp!=lKE+6 && temp!=lKE+8)
		{
			putc(c,fp2);
		}
		//Replace KE
		if (temp==lKE+1)
		{
			printf("\n \n \n Values replaced: %s",alpha);
			
		if (c=fgets(k, 2,fp))
			{
				for(i=0 ; i<6; i++)
				{
					putc('\040',fp2);
				}
			fputs(alpha,fp2);
			//putc('\n',fp2);
			}
		temp++;
		}
//Replace GE
		if (temp==lKE+3)
		{
			printf("\n \n \n Values replaced: %s", beta);
		
		if (c=fgets(g, 2,fp))
			{
				for(i=0 ; i<6; i++)
				{
					putc('\040',fp2);
				}
			fputs(beta,fp2);
			//putc('\n',fp2);
			}
		temp++;
		}
//Replace KMe
		if (temp==lKE+5)
		{
			printf("\n \n \n Values replaced: %s", gamma);
				
		if (c=fgets(z, 2,fp))
			{
				for(i=0 ; i<6; i++)
				{
					putc('\040',fp2);
				}
			fputs(gamma,fp2);
			//putc('\n',fp2);
			}
		temp++;
		}
//Replace GMe
		if (temp==lKE+7)
		{
			printf("\n \n \n Values replaced: %s", delta);
		
		if (c=fgets(u, 2,fp))
			{
				for(i=0 ; i<6; i++)
				{
					putc('\040',fp2);
				}
			fputs(delta,fp2);
			//putc('\n',fp2);
			}
		temp++;
		}
//Replace GV
		if (temp==lKE+9)
		{
			printf("\n \n \n Values replaced: %s", eta);
		
		if (c=fgets(m, 2,fp))
			{
				for(i=0 ; i<6; i++)
				{
					putc('\040',fp2);
				}
			fputs(eta,fp2);
			//putc('\n',fp2);
			}
		temp++;
		}

		c=getc(fp);
	}
		
	 fclose(fp);
	 fclose(fp2);
	 printf("\n \n \n *******File saved as slsbis.for ******");
	 
}
