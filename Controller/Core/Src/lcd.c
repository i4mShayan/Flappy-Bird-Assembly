#include "lcd.h"

void initLCD()
{

  __LCD_Data(0x00);
  __LCD_RS(0);
  __LCD_E(0);

  __LCD_Data(0x00);
  Delay(30);
  Delay(1);
  LCD_ICommand(0x03);
  Delay(5);
  LCD_ICommand(0x03);
  Delay(1);
  LCD_ICommand(0x03);
  LCD_ICommand(0x02);
  LCD_ICommand(0x02);
  LCD_ICommand(0x08);
  LCD_ICommand(0x00);
  LCD_ICommand(0x0C);
  LCD_ICommand(0x00);
  LCD_ICommand(0x06);
}

void LCD_SendEnable()
{
	__LCD_E(1);
	Delay(LCD_Delay);
	__LCD_E(0);
	Delay(LCD_Delay);
}

void LCD_Command(uint8_t cmd)
{
	uint8_t high = cmd >> 4;
	uint8_t low = cmd;
	
	__LCD_RS(0);
	
	__LCD_Data(high);
	LCD_SendEnable();
	
	__LCD_Data(low);
	LCD_SendEnable();
}

void LCD_Char(char c)
{
	uint8_t high = c >> 4;
	uint8_t low = c;
	
	__LCD_RS(1);
	
	__LCD_Data(high);
	LCD_SendEnable();
	
	__LCD_Data(low);
	LCD_SendEnable();
}

void LCD_String(char* str)
{
	char c;
	while ((c = *(str++)))
	{
		LCD_Char(c);
	}
}


void __LCD_Data(uint8_t data)
{
	if (data & 0x01)
		D4_GPIO_Port->BSRR = (uint32_t) D4_Pin;
	else
		D4_GPIO_Port->BSRR = (uint32_t) D4_Pin << 16;

	if (data & 0x02)
		D5_GPIO_Port->BSRR = (uint32_t) D5_Pin;
	else
		D5_GPIO_Port->BSRR = (uint32_t) D5_Pin << 16;

	if (data & 0x04)
		D6_GPIO_Port->BSRR = (uint32_t) D6_Pin;
	else
		D6_GPIO_Port->BSRR = (uint32_t) D6_Pin << 16;
	
	if (data & 0x08)
		D7_GPIO_Port->BSRR = (uint32_t) D7_Pin;
	else
		D7_GPIO_Port->BSRR = (uint32_t) D7_Pin << 16;
}

void __LCD_RS(uint8_t data)
{
	if (data)
		RS_GPIO_Port->BSRR = (uint32_t) RS_Pin;
	else
		RS_GPIO_Port->BSRR = (uint32_t) RS_Pin << 16;
}

void __LCD_E(uint8_t data)
{
	if (data)
		EN_GPIO_Port->BSRR = (uint32_t) EN_Pin;
	else
		EN_GPIO_Port->BSRR = (uint32_t) EN_Pin << 16;
}

void Delay(uint32_t d)
{
	/*
	unsigned int t;
	while(d--)
	{
		t = Delay_C;
		while(t--);
	}*/
	
	HAL_Delay(d);
		
}

void LCD_ICommand(unsigned char CMD)
{

  __LCD_RS(0);

  __LCD_Data(CMD);

  __LCD_E(1);
  Delay(LCD_Delay);
  __LCD_E(0);
}

void LCD_ClearDisplay()
{
  LCD_Command(0x01);
  Delay(2);
}

void LCD_GoToLine(uint8_t line)
{
  if (line == 1)
  {
	LCD_Command(0x80);
  }
  else
  {
	LCD_Command(0xC0);
  }
}


