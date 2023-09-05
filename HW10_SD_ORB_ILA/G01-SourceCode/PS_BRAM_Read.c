#include <stdio.h>

#include "xil_io.h"   //这个头文件下面包含很重要的IO读写函数

#include "xparameters.h"  //这个头文件里把硬件的地址映射等参数都写成了宏定义方便使用

//void print(char *str);

int main()

{
       int num;
       int rev;

    xil_printf("------The test is start...------\n\r");

    //XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR是axi_bram_ctrl_0的地址，Xil_Out32通过控制axi_bram_ctrl_0，向blk_mem_gen_0写数据

    for( num=0; num<320; num++ )

    {
       // Xil_Out32(XPAR_BRAM_0_BASEADDR + num*4, 0x10000000+num);     //
													//current_value
       Xil_Out8(XPAR_BRAM_0_BASEADDR +  0  + num*4 , 0x00);
       Xil_Out8(XPAR_BRAM_0_BASEADDR +  1  + num*4 , 0x10);     //
       Xil_Out8(XPAR_BRAM_0_BASEADDR +  2  + num*4 , 0xFF);     //
       Xil_Out8(XPAR_BRAM_0_BASEADDR +  3  + num*4 , 0x10);     //
    }

   for( num=0; num<320; num++ )	   	   //160 pairs

       {	//keypoint pos
            rev = Xil_In32(XPAR_BRAM_0_BASEADDR + num*4);

            xil_printf( "The data at Address: %x is %x \n\r",XPAR_BRAM_0_BASEADDR + num*4,rev);
       }

    xil_printf("------The test is end!------\n\r");

    return 0;

}
