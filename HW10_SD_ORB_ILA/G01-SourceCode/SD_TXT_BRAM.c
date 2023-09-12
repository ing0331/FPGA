#include <string.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"   //这个头文件下面包含很重要的IO读写函数

#include "xil_printf.h"
#include "ff.h"
#include "xdevcfg.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

static FATFS fatfs;
#define pixel_cnt 14342400

int SD_Init()
{
    FRESULT rc;

    rc = f_mount(&fatfs,"",0);
    if(rc)
    {
        xil_printf("ERROR : f_mount returned %d\r\n",rc);
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

int SD_Transfer_read(char *FileName,u32 DestinationAddress,u32 ByteLength)
{
    FIL fil;
    FRESULT rc;
    UINT br;
    u32 file_size = 0;
    rc = f_open(&fil,FileName,FA_READ);
    if(rc)
    {
        xil_printf("ERROR : f_open returned %d\r\n",rc);
        return XST_FAILURE;
    }

	file_size = f_size(&fil);
	printf("%d\n", file_size);

    rc = f_lseek(&fil, 0);
    if(rc)
    {
        xil_printf("ERROR : f_lseek returned %d\r\n",rc);
        return XST_FAILURE;
    }
    rc = f_read(&fil, (void*)DestinationAddress,ByteLength,&br);
    if(rc)
    {
        xil_printf("ERROR : f_read returned %d\r\n",rc);
        return XST_FAILURE;
    }
    rc = f_close(&fil);
    if(rc)
    {
        xil_printf(" ERROR : f_close returned %d\r\n", rc);
        return XST_FAILURE;
    }
    return XST_SUCCESS, file_size;
}

int SD_Transfer_write(char *FileName,u32 SourceAddress,u32 ByteLength)
{
    FIL fil;
    FRESULT rc;
    UINT bw;

    rc = f_open(&fil,FileName,FA_CREATE_ALWAYS | FA_WRITE);
    if(rc)
    {
        xil_printf("ERROR : f_open returned %d\r\n",rc);
        return XST_FAILURE;
    }
    rc = f_lseek(&fil, 0);
    if(rc)
    {
        xil_printf("ERROR : f_lseek returned %d\r\n",rc);
        return XST_FAILURE;
    }
    rc = f_write(&fil,(void*) SourceAddress,ByteLength,&bw);
    if(rc)
    {
        xil_printf("ERROR : f_write returned %d\r\n", rc);
        return XST_FAILURE;
    }
    rc = f_close(&fil);
    if(rc){
        xil_printf("ERROR : f_close returned %d\r\n",rc);
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

#define FILE_r "rotData.txt"
#define FILE_ur "unData.txt"

int main()
{
    init_platform();

    u32 shift = 0;
	u8 f_chose = 0;
//    const char src_str[] = "Data from Zedboard";
//    u32 len = strlen(src_str);
    // SD_Init();
    // SD_Transfer_write(FILE_w,(u32)src_str,(len+1000));

    u32 len = 57396019;
	int value = 0;
	// Calculate the integer array
	int units = 0;
	int tens = 0;
	int hundreds = 0;

	int rev = 0;

   for(f_chose = 0; f_chose<2; f_chose++)
   {
        char dest_str[len];

        SD_Init();
		if(f_chose)
		{
			SD_Transfer_read(FILE_ur, (u32)dest_str, (len + 1));
		}
		else
		{
			SD_Transfer_read(FILE_r, (u32)dest_str, (len + 1));
		}

				
        // Tokenize the string using strtok to split it by commas
        char* token = strtok(dest_str, ",");

    	while (token != NULL)
    	{
    		// Convert the token to an integer
    		value = atoi(token);

            printf("Original: %d\n", value);
			Xil_Out8(XPAR_BRAM_0_BASEADDR + shift, (u8)value);

    		shift = shift + 1;
    		// Get the next token
    		token = strtok(NULL, ",");
 		//	xil_printf("%s \r\n",dest_str);
   	}

		for(int i = 0; i<shift ; i++)
		{
		
			if(f_chose)
			{
			rev = Xil_In32(XPAR_BRAM_0_BASEADDR + shift *4);
			xil_printf( "The data at Address: %x is %x \n\r",XPAR_BRAM_0_BASEADDR + shift*4,rev);
			}
			else
			{
			rev = Xil_In32(XPAR_BRAM_1_BASEADDR + shift *4);
			xil_printf( "The data at Address: %x is %x \n\r",XPAR_BRAM_1_BASEADDR + shift*4,rev);
			}
	    }
    	shift = 0;

   }
    printf("SD write and read over!\r\n");

    cleanup_platform();
    return 0;
}
