/* 
 * Ping - an example application for the nRF24L01 using nRF24L01_SDK
 * 
 * Load the code on to two nRF24L01 chips.  The chips 'ping' each other and output a pulse
 * on pin P0.0 when they receive the ping.
 */


#include "reg24le1.h"
#include "gpio.h"
#include "rf.h"

void main(){
	unsigned char datavar; //register to data sent and received
	unsigned int count; //counter for for loop

	//Set up output on pin P0.0
	gpio_pin_configure(GPIO_PIN_ID_P0_0,
			   GPIO_PIN_CONFIG_OPTION_DIR_OUTPUT |
			   GPIO_PIN_CONFIG_OPTION_OUTPUT_VAL_CLEAR |
			   GPIO_PIN_CONFIG_OPTION_PIN_MODE_OUTPUT_BUFFER_NORMAL_DRIVE_STRENGTH);

	gpio_pin_val_sbit_clear(P0_SB_D0);
	
	//Set up RF
	rf_configure_debug_lite(false, 1); //initialize the rf to the debug configuration as TX, 1 data bytes, and auto-ack disabled
	delay_us(130); //wait for remote unit to come from standby to RX
	

	//main program loop
	datavar = 0;
	while(1) {
		datavar++;

		rf_write_tx_payload(&datavar, 1, true); //transmit received char over RF

		//wait until the packet has been sent or the maximum number of retries has been reached
		while(!(rf_irq_pin_active() && rf_irq_tx_ds_active()));

		rf_irq_clear_all(); //clear all interrupts in the 24L01
		rf_set_as_rx(true); //change the device to an RX to get the character back from the other 24L01

		//wait a while to see if we get the data back (change the loop maximum and the lower if
		//  argument (should be loop maximum - 1) to lengthen or shorten this time frame
		for(count = 0; count < 25000; count++) {
			//check to see if the data has been received.  if so, get the data and exit the loop.
			//  if the loop is at its last count, assume the packet has been lost
			//  If neither of these is true, keep looping.
			if((rf_irq_pin_active() && rf_irq_rx_dr_active())) {
				rf_read_rx_payload(&datavar, 1); //get the payload into data
				gpio_pin_val_sbit_complement(P0_SB_D0); //toggle the output pin as an indication that the loop has completed

				break;
			}

			//if loop is on its last iteration, assume packet has been lost.
			if(count == 24999)
				gpio_pin_val_sbit_clear(P0_SB_D0);
		}

		rf_irq_clear_all(); //clear interrupts again

		rf_set_as_tx(); //resume normal operation as a TX
		delay_us(130); //wait for remote unit to come from standby to RX

	}
}

