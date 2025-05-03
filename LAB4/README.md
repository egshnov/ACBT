# Лабораторная работа 4: Работа с PCI шиной

## Задание
Написать программу для перебора шины PCI и вывода информации об устройствах:
- Без использования прерываний BIOS
- С прямым доступом через порты 0xCF8/0xCFC
- С расшифровкой VendorID и DeviceID в текстовые описания

## Формат вывода
```
Bus: XX Dev: XX Func: XX VendorID: XXXX DeviceID: XXXX [Vendor Name] [Device Name]
```

## Поддерживаемые устройства

### Vendors
- Intel (8086h)
- RedHat (1B36h)
- VirtIO (1AF4h)

### Intel Devices
- PCI Memory Controller (1237h)
- PIIX3 ISA Bridge (7000h)
- PIIX3 IDE Controller (7010h)
- PIIX4 ACPI Controller (7113h)
- 82540EM Ethernet (100Eh)
- ICH6/ICH9 Controllers (2668h, 2934h-2936h, 293Ah)

### RedHat/VirtIO Devices
- QXL Graphics (0100h)
- VirtIO Balloon (1002h)
- VirtIO Network (1003h)

## Пример работы программы
![Lab 4.2 Demo](/images/42.png)

## Сборка и запуск
```bash
tasm /m5 lab42.asm
tlink lab42.obj
```
