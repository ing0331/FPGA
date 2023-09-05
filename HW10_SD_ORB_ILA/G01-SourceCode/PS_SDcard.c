#include "ff.h"
#include "xil_printf.h"
#include <xstatus.h>
#include "xil_cache.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

FATFS fatfs;
static int SD_Init();
static int SD_Eject();
static int ReadFile(char *FileName, u32 DestinationAddress, UINT* br); // Changed UNIT to UINT

#define DataAddr 0x00200000

int main()
{
    int Status;
    UINT ReadByteCount; // Corrected data type

    Status = SD_Init(&fatfs);

    if(Status != XST_SUCCESS)
    {
        printf("fail");
        return XST_FAILURE;
    }

    Status = ReadFile("input_data.txt", (u32)DataAddr, &ReadByteCount);
    if (Status != XST_SUCCESS)
    {
        printf("file");
        return XST_FAILURE;
    }

    // Assuming the file contains integers separated by commas
    // Convert the data in memory to integers and display unique contents
    int *data = (int *)DataAddr;
    int size = ReadByteCount / sizeof(int);

    printf("Unique contents in the file:\n");

    for (int i = 0; i < size; i++)
    {
        int current_value = data[i];

        // Check if the value is unique by comparing with previous values
        int is_unique = 1;
        for (int j = 0; j < i; j++)
        {
            if (data[j] == current_value)
            {
                is_unique = 0;
                break;
            }
        }

        if (is_unique)
        {
            printf("%d\n\n", current_value);

        }
    }

    Status = SD_Eject(&fatfs);
    printf("done\n");
    return 0;
}


static int SD_Init()
{
	// Same as before
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_mount(&fatfs,Path,0);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

static int SD_Eject()
{
	// Same as before
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_mount(0,Path,0);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

static int ReadFile(char *FileName, u32 DestinationAddress, UINT* br)
{
	FIL fil;
	FRESULT rc;
	u32 file_size;

	rc = f_open(&fil, FileName, FA_READ);
	if(rc)
	{
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}

	file_size = f_size(&fil);
	printf(file_size);

	rc = f_lseek(&fil, 0); // Changed fil to &fil
	if (rc)
	{
		xil_printf(" ERROR : f_lseek returned %d\r\n", rc);
		return XST_FAILURE;
	}

	rc = f_read(&fil, (void*)DestinationAddress, file_size, br); // Changed br to &br
	if (rc)
	{
		xil_printf(" ERROR : f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}

	rc = f_close(&fil);
	if (rc)
	{
		xil_printf(" ERROR : f_close returned %d\r\n", rc);
		return XST_FAILURE;
	}

	Xil_DCacheFlush();
	return XST_SUCCESS;
}
