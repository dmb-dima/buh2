﻿////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

// Хранит таблицу значений - состав показателей отчета.
Перем мТаблицаСоставПоказателей Экспорт;

// Хранит структуру - состав показателей отчета,
// значение которых автоматически заполняется по учетным данным.
Перем мСтруктураВариантыЗаполнения Экспорт;

// Хранит дерево значений - структуру листов отчета.
Перем мДеревоСтраницОтчета Экспорт;

// Хранит признак выбора печатных листов
Перем мЕстьВыбранные Экспорт;

// Хранит версию формы отчета
Перем мВерсияФормы Экспорт;

// Хранит имя выбранной формы отчета
Перем мВыбраннаяФорма Экспорт;

// Хранит признак скопированной формы.
Перем мСкопированаФорма Экспорт;

// Хранит ссылку на документ, хранящий данные отчета
Перем мСохраненныйДок Экспорт;

Перем мСчетчикСтраниц Экспорт; // флажок на форме выбора страниц, если Истина, то пересчет автоматический убрать
Перем мАвтоВыборКодов Экспорт; // для флажка "отключить выбор значений из списка"
Перем мПроверятьСоотношенияПриПечатиИВыгрузки Экспорт; // Флаг, для запуска КС

// Следующие переменные хранят границы периода построения отчета
// и периодичность
Перем мДатаНачалаПериодаОтчета Экспорт;
Перем мДатаКонцаПериодаОтчета  Экспорт;
Перем мПериодичность Экспорт;

Перем мПолноеИмяФайлаВнешнейОбработки Экспорт;

Перем мЗаписьЗапрещена Экспорт;

Перем мИнтервалАвтосохранения Экспорт;

Перем мРезультатПоиска Экспорт;// таблица с результатами поиска
Перем мСчетчикиСтраницПриПоиске Экспорт;// таблица со счетчиками номеров листов при поиске

Перем мТаблицаФормОтчета Экспорт;

Перем мЗаписываетсяНовыйДокумент Экспорт;
Перем мВариант Экспорт;

Перем мФормыИФорматы Экспорт;
Перем мВерсияОтчета Экспорт;

Перем мПечатьБезШтрихкодаРазрешена Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ ОПРЕДЕЛЕНИЯ ДЕРЕВА ФОРМ И ФОРМАТОВ

Функция СоздатьДеревоФормИФорматов()
	
	мФормыИФорматы = Новый ДеревоЗначений;
	мФормыИФорматы.Колонки.Добавить("Код");
	мФормыИФорматы.Колонки.Добавить("ДатаПриказа");
	мФормыИФорматы.Колонки.Добавить("НомерПриказа");
	мФормыИФорматы.Колонки.Добавить("ДатаНачалаДействия");
	мФормыИФорматы.Колонки.Добавить("ДатаОкончанияДействия");
	мФормыИФорматы.Колонки.Добавить("ИмяОбъекта");
	мФормыИФорматы.Колонки.Добавить("Описание");
	Возврат мФормыИФорматы;
	
КонецФункции

Функция ОпределитьФормуВДеревеФормИФорматов(ДеревоФормИФорматов, Код, ДатаПриказа = '00010101', НомерПриказа = "", ИмяОбъекта = "",
			ДатаНачалаДействия = '00010101', ДатаОкончанияДействия = '00010101', Описание = "")
	
	НовСтр = ДеревоФормИФорматов.Строки.Добавить();
	НовСтр.Код = СокрЛП(Код);
	НовСтр.ДатаПриказа = ДатаПриказа;
	НовСтр.НомерПриказа = СокрЛП(НомерПриказа);
	НовСтр.ДатаНачалаДействия = ДатаНачалаДействия;
	НовСтр.ДатаОкончанияДействия = ДатаОкончанияДействия;
	НовСтр.ИмяОбъекта = СокрЛП(ИмяОбъекта);
	НовСтр.Описание = СокрЛП(Описание);
	Возврат НовСтр;
	
КонецФункции

Функция ОпределитьФорматВДеревеФормИФорматов(Форма, Версия, ДатаПриказа = '00010101', НомерПриказа = "",
			ДатаНачалаДействия = Неопределено, ДатаОкончанияДействия = Неопределено, ИмяОбъекта = "", Описание = "")
	
	НовСтр = Форма.Строки.Добавить();
	НовСтр.Код = СокрЛП(Версия);
	НовСтр.ДатаПриказа = ДатаПриказа;
	НовСтр.НомерПриказа = СокрЛП(НомерПриказа);
	НовСтр.ДатаНачалаДействия = ?(ДатаНачалаДействия = Неопределено, Форма.ДатаНачалаДействия, ДатаНачалаДействия);
	НовСтр.ДатаОкончанияДействия = ?(ДатаОкончанияДействия = Неопределено, Форма.ДатаОкончанияДействия, ДатаОкончанияДействия);
	НовСтр.ИмяОбъекта = СокрЛП(ИмяОбъекта);
	НовСтр.Описание = СокрЛП(Описание);
	Возврат НовСтр;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ОПРЕДЕЛЕНИЕ ДЕРЕВА ФОРМ И ФОРМАТОВ ОТЧЕТА

мФормыИФорматы = СоздатьДеревоФормИФорматов();

Форма20041001 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20041101', "96н",	"ФормаОтчета2004Кв4", , '20041231');
ОпределитьФорматВДеревеФормИФорматов(Форма20041001, "3.00002");

Форма20050101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20050217', "23н",	"ФормаОтчета2004Кв4", '20050101', );
ОпределитьФорматВДеревеФормИФорматов(Форма20050101, "3.00003");

Форма20060101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20060117', "8н",	"ФормаОтчета2006Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20060101, "3.00004");

Форма20070101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20061219', "177н",	"ФормаОтчета2007Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20070101, "3.00005");

Форма20080101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20070920', "83н",	"ФормаОтчета2008Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20080101, "3.00005");

Форма20090101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20081208', "137н",	"ФормаОтчета2009Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20090101, "5.01");

Форма20100101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152016", '20091119', "119н",	"ФормаОтчета2010Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20100101, "5.02");


////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ 

ОписаниеТиповСтрока15  = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(15);
ОписаниеТиповСтрока50  = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(50);

мТаблицаСоставПоказателей    = Новый ТаблицаЗначений;
мТаблицаСоставПоказателей.Колонки.Добавить("ИмяПоляТаблДокумента",    ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоСоставу",  ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоФорме",    ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("ПризнМногострочности",    ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("ТипДанныхПоказателя",     ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоСтруктуре",     ОписаниеТиповСтрока50);

мСтруктураВариантыЗаполнения = Новый Структура;

ОписаниеТиповСтрока = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(0);

МассивТипов = Новый Массив;
МассивТипов.Добавить(Тип("Дата"));
ОписаниеТиповДата = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыДаты(ЧастиДаты.Дата));

мТаблицаФормОтчета = Новый ТаблицаЗначений;
мТаблицаФормОтчета.Колонки.Добавить("ФормаОтчета",        ОписаниеТиповСтрока);
мТаблицаФормОтчета.Колонки.Добавить("ОписаниеОтчета",     ОписаниеТиповСтрока, "Утверждена",  20);
мТаблицаФормОтчета.Колонки.Добавить("ДатаНачалоДействия", ОписаниеТиповДата,   "Действует с", 5);
мТаблицаФормОтчета.Колонки.Добавить("ДатаКонецДействия",  ОписаниеТиповДата,   "         по", 5);

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2006Кв1";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 17.01.2006 г. № 8н";
НоваяФорма.ДатаНачалоДействия = '20060101';
НоваяФорма.ДатаКонецДействия  = '20061231';

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2004Кв4";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 01.11.2004 г. № 96н";
НоваяФорма.ДатаНачалоДействия = '20041101';
НоваяФорма.ДатаКонецДействия  = '20061231'; // Действует до конца 2006 г. одновременно с новой формой

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2007Кв1";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 17.01.2006 г. № 8н (в редакции приказа Минфина РФ от 19.12.2006 г. № 177н)";
НоваяФорма.ДатаНачалоДействия = '20070101';
НоваяФорма.ДатаКонецДействия  = '20071231';

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2008Кв1";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 17.01.2006 г. № 8н (в редакции приказа Минфина РФ от 19.12.2006 г. № 177н, от 20.09.2007 г. № 83н)";
НоваяФорма.ДатаНачалоДействия = '20080101';
НоваяФорма.ДатаКонецДействия  = '20081231';

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2009Кв1";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 08.12.2008 г. № 137н";
НоваяФорма.ДатаНачалоДействия = '20090101';
НоваяФорма.ДатаКонецДействия  = '20091231';

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2010Кв1";
НоваяФорма.ОписаниеОтчета     = "Форма утверждена приказом Минфина РФ от 08.12.2008 г. № 137н (в редакции приказа Минфина России от 19.11.2009 № 119н)";
НоваяФорма.ДатаНачалоДействия = '20100101';
НоваяФорма.ДатаКонецДействия  = ОбщегоНазначения.ПустоеЗначениеТипа(Тип("Дата"));
