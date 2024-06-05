#include "main.h"

#define RS_Pin GPIO_PIN_9
#define RS_GPIO_Port GPIOA
#define EN_Pin GPIO_PIN_7
#define EN_GPIO_Port GPIOC
#define D4_Pin GPIO_PIN_5
#define D4_GPIO_Port GPIOB
#define D5_Pin GPIO_PIN_4
#define D5_GPIO_Port GPIOB
#define D6_Pin GPIO_PIN_10
#define D6_GPIO_Port GPIOB
#define D7_Pin GPIO_PIN_8
#define D7_GPIO_Port GPIOA


#define LCD_Delay			1UL
#define LCD_SR				0xC1
#define LCD_Clear			0x01

void __LCD_Data(uint8_t);
void __LCD_RS(uint8_t);
void __LCD_E(uint8_t);
void LCD_SendEnable(void);
void LCD_Command(uint8_t);
void LCD_Char(char);
void LCD_String(char*);
void LCD_ICommand(unsigned char);
void initLCD(void);
void Delay(uint32_t);
void LCD_ClearDisplay();
void LCD_GoToLine(uint8_t line);
