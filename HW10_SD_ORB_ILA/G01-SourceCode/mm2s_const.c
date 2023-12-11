
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"   //???文件下面包含很重要的IO??函?
#include "xil_printf.h"

#define DDR_BASE_ADDRESS    0x00110000	//0x00100000
#define DDR_SIZE            3600000	//<16MB

#include "sleep.h"
#include "xil_cache.h"
#include "ff.h"
#include "xdevcfg.h"
#include "xaxidma.h"

#include "xscugic.h"

static FATFS fatfs;
#define FILE_r "pixels.bin"
#define FILE_ur "rot_pixels.bin"
#define imageSize 345600	//720*480

u32 checkHalted(u32 baseAddress,u32 offset);
// Function prototype
static int SD_Init();
//u32 SD_Transfer_read(char *FileName, u32 DestinationAddress, UINT ByteLength);

// Define a global variable to keep track of the file read pointer position
UINT file_pointer = 0; // Keep track of the file pointer

// Function prototypes
u32 SD_Transfer_read(char *FileName, u32 DestinationAddress, UINT ByteLength);

char value[691200];//2*imageSize]; // Adjust the size to match the desired read length

// Reorganize the data as specified
static u32 *reorganized_value = (u32 *) value;
static u32 DMA_O_dest_str[imageSize]; // u32 : 2*u8, 2*u8
//u32 *reorganized_DMA_O_dest_str = (u32 *) DMA_O_dest_str;
 u32 RX_buf[720];	//volatile
statis u16 row = 0;
static u32 i = 0;
static u32 page = 0;

XScuGic IntcInstance;
static void imageProcISR(void *CallBackRef);
int main() {
    init_platform();
    SD_Init();

    u32 status;
    XAxiDma_Config* myDmaConfig;
    XAxiDma myDma;
    myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);

    status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
    if (status != XST_SUCCESS) {
        print("DMA initialization failed\n");
        return -1;
    }
    XAxiDma_Config* myDmaConfig2;
    XAxiDma myDma2;
    myDmaConfig2 = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_1_BASEADDR);
    status = XAxiDma_CfgInitialize(&myDma2, myDmaConfig2);
//    if (status != XST_SUCCESS) {
//        print("DMA initialization failed\n");
//        return -1;
//    }

	//Interrupt Controller Configuration
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	status =  XScuGic_CfgInitialize(&IntcInstance, IntcConfig, IntcConfig->CpuBaseAddress);


	if(status != XST_SUCCESS){
		xil_printf("Interrupt controller initialization failed..");
		return -1;
	}

	XScuGic_SetPriorityTriggerType(&IntcInstance,XPAR_FABRIC_AXI_ORB720_0_ORB_INTR_INTR,0xA0,3);
	status = XScuGic_Connect(&IntcInstance,XPAR_FABRIC_AXI_ORB720_0_ORB_INTR_INTR,(Xil_InterruptHandler)imageProcISR,(void *)&myDma);
	if(status != XST_SUCCESS){
		xil_printf("Interrupt connection failed");
		return -1;
	}
	XScuGic_Enable(&IntcInstance,XPAR_FABRIC_AXI_ORB720_0_ORB_INTR_INTR);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)&IntcInstance);
	Xil_ExceptionEnable();

	for (i = 0; i < 1440; i++) {
		RX_buf[i] = 0x0000;
	}
	Xil_DCacheFlushRange((u32)RX_buf[0], 2500);

	while (page < 3) {
		row = 0;
				// SD_Transfer_read("pixels.bin", (u32)value, imageSize);	//current
			if ((page & 1U) == 0U)//(page & 0x1 = 0)	//if lowest but of u32 page is 0
			{
			SD_Transfer_read("road720.bin", (u32)(value), imageSize);	//current
			}
			else
			{
			SD_Transfer_read("road720.bin", (u32)(value + imageSize), imageSize);	//current
			}

//			reorganized_DMA_O_dest_str = ((page & 1U) == 0U) ? value&(value +imageSize) : value;
				for (i = 0; i < 345600*4; i++) {
					DMA_O_dest_str[i] = (reorganized_value[i + imageSize / 4] & 0xFF) |
													((reorganized_value[i] & 0xFF) << 8) |
													((reorganized_value[i + imageSize / 4] & 0xFF00) << 8) |
													((reorganized_value[i] & 0xFF00) << 16);
					// DMA_O_dest_str[i] = 0xf00f;
				}

			 xil_printf("value %x\n\r", DMA_O_dest_str[0]);

//			// Update the file pointer
//			file_pointer += imageSize;
//
//			// Print the file_pointer value for each loop
//			xil_printf("File Pointer: %ld\r\n", file_pointer);

			 // Xil_DCacheFlushRange((u32)DMA_O_dest_str, 345600);				//720*240

			 // XAxiDma_SimpleTransfer(&myDma2, (u32)RX_buf[0], 2500, XAXIDMA_DEVICE_TO_DMA);
			XAxiDma_SimpleTransfer(&myDma, (u32)DMA_O_dest_str, 345600*4, XAXIDMA_DMA_TO_DEVICE);//typecasting in C/C++
			 XAxiDma_SimpleTransfer(&myDma2, (u32)DMA_O_dest_str, 2500, XAXIDMA_DEVICE_TO_DMA);
			
			// Xil_DCacheFlushRange((u32)RX_buf[0], 2500);

//			if (status != XST_SUCCESS)
//				xil_printf("DMA failed2\n\r", status);

//			 Xil_DCacheFlushRange((u32)RX_buf, 720);
//			 if (status != XST_SUCCESS)
//				 xil_printf("DMA failed\n\r", status);
			// for (int i = 0; i < 40; i++) {
				// xil_printf("rx [%x]value : %x\n\r", i, RX_buf[i]);
			// }
			row += 1;

			while (row < 480)	//undone
			{
	//  			usleep(1000);
			}

			// while(totalTransmittedBytes < 720 *5){// imageSize){
				// // transmittedBytes =  XUartPs_Send(&myUart,(u8*)&imageData[totalTransmittedBytes],1);
				// xil_printf("trans dta: %x\n\r", (u8*)&RX_buf[totalTransmittedBytes]);
				// totalTransmittedBytes += transmittedBytes;
				// usleep(10);
			// }

			page = page + 1;

	}
    cleanup_platform();
    return 0;
}

static void imageProcISR(void *CallBackRef){
	static int j = 1;
	int status;
	// xil_printf("v: %x\n\r", row);

	XScuGic_Disable(&IntcInstance,XPAR_FABRIC_AXI_ORB720_0_ORB_INTR_INTR);
//	status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
//	while(status == 0)
//		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);

	if(j<480){															//j*720
		status = XAxiDma_SimpleTransfer((XAxiDma *)CallBackRef,(u32)&DMA_O_dest_str[j*720],2500,XAXIDMA_DEVICE_TO_DMA);
		j++;
	}
	else
		j = 1;

	XScuGic_Enable(&IntcInstance,XPAR_FABRIC_AXI_ORB720_0_ORB_INTR_INTR);
}

u32 SD_Transfer_read(char *FileName, u32 DestinationAddress, UINT ByteLength) {
    FIL fil;
    FRESULT rc;
    UINT br;

    f_open(&fil, FileName, FA_READ);

    // Move the file pointer
    f_lseek(&fil, file_pointer);

    // Read data from the file
    f_read(&fil, (void *) DestinationAddress, ByteLength, &br);

    // Close the file
    f_close(&fil);

    return rc;
}

u32 checkHalted(u32 baseAddress,u32 offset){
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_HALTED_MASK;
	return status;
}

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
//
//int SD_Transfer_read(char *FileName,u32 DestinationAddress,u32 ByteLength)
//{
//    FIL fil;
//    FRESULT rc;
//    UINT br;
//    u32 file_size = 0;
//    rc = f_open(&fil,FileName,FA_READ);
//    if(rc)
//    {
//        xil_printf("ERROR : f_open returned %d\r\n",rc);
//        return XST_FAILURE;
//    }
//
//	file_size = f_size(&fil);
//	printf("%lx\n", file_size);
//
//    rc = f_lseek(&fil, 0);
//    if(rc)
//    {
//        xil_printf("ERROR : f_lseek returned %d\r\n",rc);
//        return XST_FAILURE;
//    }
//    rc = f_read(&fil, (void*)DestinationAddress,ByteLength,&br);
//    if(rc)
//    {
//        xil_printf("ERROR : f_read returned %d\r\n",rc);
//        return XST_FAILURE;
//    }
//    rc = f_close(&fil);
//    if(rc)
//    {
//        xil_printf(" ERROR : f_close returned %d\r\n", rc);
//        return XST_FAILURE;
//    }
//    return XST_SUCCESS, file_size;
//}

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
