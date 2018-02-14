# Crystals-Love
### Description
Здесь храняться смарт-контракты для проекта [**Crystals-Love**](https://crystals.love/).
### Содержание
* [Token](#Token)
* [General](#General)
* [CrowdSale](#CrowdSale)
* [Business-smart-contract](#Business-smart-contract)
# Token
### Особенности нашего смарт-контракта Токена.
Реализован по стандарту ERC20.
1. Интерфейс стандарта можно посмотреть по ссылке [IERC20](https://github.com/liderako/Crystals-Love/blob/master/Crystals-Love/Token/IERC20.sol)
2. Реализацию можно посмотреть по ссылке [ERC20](https://github.com/liderako/Crystals-Love/blob/master/Crystals-Love/Token/ERC20.sol)

Токен использует [SafeMathToken](https://github.com/liderako/Crystals-Love/blob/master/Crystals-Love/Token/SafeMathToken.sol) для безопаноcних вычеслений.

Токен вы можете изучить пройдя по ссылке [Token](https://github.com/liderako/Crystals-Love/blob/master/Crystals-Love/Token/Token.sol)
Из дополнительного функционала есть
1. Сжигание токенов
```
1.  Доступно только для адресов которым Админ позволил сжигать токены. (Это будут адреса смарт-контрактов)

2.  Админ вручную устанавливает которым адресам можно сжигать токены.
```
2. Заморозка токена
```
Условия функции
1.  Функционал доступен только для адреса Admin.

2.  Admin не может заморозить больше токенов чем у него есть.

3.  Admin не может заморозить токены повторно если в замороженом состоянии уже есть некоторое количество токенов.

4.  Admin не может заморозить токенов на количество равное 0.

Входные параметры
@param amount - Количество токенов которые буду заморожены.
Функция замораживает целые токены.
Для удобства Админа не нужно высчитивать считать, сколько в одном токене дробных частей.
```
3. Разморозка токенов.
```
1.  Функционал доступен только для адреса Admin

2.  Функционал разморозки доступен только после истечения периода времени.
    Период времени устанавливается при создании контракта)

3.  Входных параметров нету
```
# General
# CrowdSale
# Business-smart-contract
> Soon. Wait
