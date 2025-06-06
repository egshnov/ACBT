# Лабораторная работа 2: Работа с прерываниями и отладкой

## Задание 1: Трассировка программы
Написать программу, которая загружает другую COM-программу, устанавливает режим трассировки (используя флаг TF и прерывание INT 1) и выводит сообщение при выполнении каждой инструкции трассируемой программы.

Решение находится в файле `lab21.asm`. В качестве трассируемой программы используется `hello.asm`.

### Описание решения
Программа `lab21.asm` загружает `HELLO.COM` в память, устанавливает флаг трассировки (TF) в регистре флагов перед передачей управления `HELLO.COM`. Обработчик INT 1 перехватывается для вывода сообщения "some instruction" и ожидания нажатия клавиши перед продолжением выполнения следующей инструкции `HELLO.COM`.

## Скриншот вывода
![Скриншот вывода](/images/21.png)


## Задание 2: Установка Breakpoint
Написать программу, которая устанавливает breakpoint (INT 3) в другом COM-файле, перехватывает INT 3, выводит сообщение, восстанавливает исходный байт в COM-файле (как в памяти, так и на диске) и продолжает выполнение COM-файла.

Решение находится в файле `lab23.asm`. В качестве целевой программы используется `hello.asm`.

### Описание решения
Программа `lab23.asm` открывает `HELLO.COM`, читает байт по указанному смещению (`patch_offset`), записывает на его место байт `0xCC` (INT 3) как на диске, так и при загрузке в память. Устанавливается обработчик INT 3. При срабатывании breakpoint, обработчик выводит сообщение, восстанавливает исходный байт в памяти `HELLO.COM` и на диске, восстанавливает исходный обработчик INT 3 и корректирует IP на стеке, чтобы `HELLO.COM` выполнил исходную инструкцию.

## Скриншот вывода
![Скриншот вывода](/images/23.png)