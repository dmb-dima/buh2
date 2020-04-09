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

// Хранит имя выбранной формы отчета
Перем мВыбраннаяФорма Экспорт;

// Хранит признак скопированной формы.
Перем мСкопированаФорма Экспорт;

// Хранит ссылку на документ, хранящий данные отчета
Перем мСохраненныйДок Экспорт;

Перем мВерсияФормы Экспорт;

Перем мСчетчикСтраниц Экспорт; // флажок на форме выбора страниц, если Истина, то пересчет автоматический убрать

Перем мАвтоВыборКодов Экспорт; // для флажка "отключить выбор значений из списка"

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

Форма20040301 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152021", '19990525', "564",		"ФормаОтчета2005Кв1");
ОпределитьФорматВДеревеФормИФорматов(Форма20040301, "2.01");

Форма20060101 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152021", '20051231', "858",		"ФормаОтчета2006Кв1");

Форма20060101_2 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152021", '20051231', "858",		"ФормаОтчета2006Кв2");
ОпределитьФорматВДеревеФормИФорматов(Форма20060101_2, "3.00");

Форма20060101_3 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152021", '20051231', "858",		"ФормаОтчета2006Кв3");
ОпределитьФорматВДеревеФормИФорматов(Форма20060101_3, "3.02");

Форма20091201 = ОпределитьФормуВДеревеФормИФорматов(мФормыИФорматы, "1152021", '20100126', "26",		"ФормаОтчета2009Кв4");
ОпределитьФорматВДеревеФормИФорматов(Форма20091201, "3.02", , , ,'20100831');

ОпределитьФорматВДеревеФормИФорматов(Форма20091201, "3.05", , , '20100901', '20110228');

ОпределитьФорматВДеревеФормИФорматов(Форма20091201, "4.01", , , '20110301');

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ 

ОписаниеТиповСтрока50  = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(50);
ОписаниеТиповСтрока15  = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(15);

мТаблицаСоставПоказателей    = Новый ТаблицаЗначений;
мТаблицаСоставПоказателей.Колонки.Добавить("ИмяПоляТаблДокумента",    ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоСоставу",  ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоФорме",    ОписаниеТиповСтрока50);
мТаблицаСоставПоказателей.Колонки.Добавить("ПризнМногострочности",    ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("ТипДанныхПоказателя",     ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("ДопОписание",		      ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("Обязательность",    	  ОписаниеТиповСтрока15);
мТаблицаСоставПоказателей.Колонки.Добавить("КодПоказателяПоСтруктуре",     ОписаниеТиповСтрока50);

мСтруктураВариантыЗаполнения = Новый Структура;

ОписаниеТиповСтрока = ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(0);

МассивТипов = Новый Массив;
МассивТипов.Добавить(Тип("Дата"));
ОписаниеТиповДата = Новый ОписаниеТипов(МассивТипов, , Новый КвалификаторыДаты(ЧастиДаты.Дата));

МассивБулево = Новый Массив;
МассивБулево.Добавить(Тип("Булево"));
ОписаниеТиповБулево    = Новый ОписаниеТипов(МассивБулево);

мТаблицаФормОтчета = Новый ТаблицаЗначений;
мТаблицаФормОтчета.Колонки.Добавить("ФормаОтчета",        ОписаниеТиповСтрока);
мТаблицаФормОтчета.Колонки.Добавить("ОписаниеОтчета",     ОписаниеТиповСтрока, "Утверждена",  20);
мТаблицаФормОтчета.Колонки.Добавить("ДатаНачалоДействия", ОписаниеТиповДата,   "Действует с", 5);
мТаблицаФормОтчета.Колонки.Добавить("ДатаКонецДействия",  ОписаниеТиповДата,   "         по", 5);
мТаблицаФормОтчета.Колонки.Добавить("НарастающийИтог",    ОписаниеТиповБулево);

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2005Кв1";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о декларировании производства и оборота этилового спирта, алкогольной и спиртосодержащей продукции (утверждено Постановлением Правительства РФ от 25.05.1999 г. №564)";
НоваяФорма.ДатаНачалоДействия = '20030101';
НоваяФорма.ДатаКонецДействия  = '20051231';
НоваяФорма.НарастающийИтог    = Истина;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2006Кв1";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено Постановлением Правительства РФ от 31.12.2005  № 858)";
НоваяФорма.ДатаНачалоДействия = '20060101';
НоваяФорма.ДатаКонецДействия  = '20060331';
НоваяФорма.НарастающийИтог    = Ложь;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2006Кв2";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено Постановлением Правительства РФ от 31.12.2005 № 858)";
НоваяФорма.ДатаНачалоДействия = '20060101';
НоваяФорма.ДатаКонецДействия  = '20060630';
НоваяФорма.НарастающийИтог    = Ложь;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2006Кв3";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено ПП РФ от 31.12.2005 № 858) (выгрузка в формате 3.02)";
НоваяФорма.ДатаНачалоДействия = '20060101';
НоваяФорма.ДатаКонецДействия  = '20091130';
НоваяФорма.НарастающийИтог    = Ложь;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2009Кв4";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено ПП РФ от 31.12.2005 № 858 (в ред. ПП РФ от 26.01.2010 N 26)) (выгрузка в формате 3.02)";
НоваяФорма.ДатаНачалоДействия = '20091201';
НоваяФорма.ДатаКонецДействия  = '20100831';
НоваяФорма.НарастающийИтог    = Ложь;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2009Кв4";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено ПП РФ от 31.12.2005 № 858 (в ред. ПП РФ от 26.01.2010 N 26)) (выгрузка в формате 3.05)";
НоваяФорма.ДатаНачалоДействия = '20100901';
НоваяФорма.ДатаКонецДействия  = '20110228';
НоваяФорма.НарастающийИтог    = Ложь;

НоваяФорма = мТаблицаФормОтчета.Добавить();
НоваяФорма.ФормаОтчета        = "ФормаОтчета2009Кв4";
НоваяФорма.ОписаниеОтчета     = "Приложение 3 к Положению о представлении декларации об объёмах производства, оборота и использования этилового спирта, алкогольной и спиртосодержащей продукции (Утверждено ПП РФ от 31.12.2005 № 858 (в ред. ПП РФ от 26.01.2010 N 26)) (выгрузка в формате 4.01)";
НоваяФорма.ДатаНачалоДействия = '20110301';
НоваяФорма.ДатаКонецДействия  = ОбщегоНазначения.ПустоеЗначениеТипа(Тип("Дата"));
НоваяФорма.НарастающийИтог    = Ложь;
