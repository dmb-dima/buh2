﻿

///////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

// Функция формирует очередной табельный номер сотрудника
// уникальность в пределах организации и вида договора
// Возвращаемое значение:
//   Строка   – табельный номер
//
Функция ПолучитьОчереднойТабельныйНомер() Экспорт

	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("парамОрганизация",Организация);
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	МАКСИМУМ(СотрудникиОрганизаций.Код) КАК Код
	|ИЗ
	|	Справочник.СотрудникиОрганизаций КАК СотрудникиОрганизаций
	|ГДЕ
	|	СотрудникиОрганизаций.Организация = &парамОрганизация
	|	И СотрудникиОрганизаций.Ссылка <> &Ссылка";
	
	Запрос.Текст = ТекстЗапроса;
	РезультатаЗапроса = Запрос.Выполнить();
	Если РезультатаЗапроса.Пустой() Тогда
		Возврат "0000000001";
	Иначе
		СтрокаРезультата = РезультатаЗапроса.Выгрузить()[0];
		Если НЕ ЗначениеЗаполнено(СтрокаРезультата.Код) Тогда
			Возврат "0000000001";
		Иначе
			Возврат ПроцедурыУправленияПерсоналом.ПолучитьСледующийНомер(СокрП(СтрокаРезультата.Код));
		КонецЕсли;
	КонецЕсли;

КонецФункции // ПолучитьОчереднойТабельныйНомер()


///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "Копирование" объекта
Процедура ПриКопировании(ОбъектКопирования)
	
	Если Не ЭтоГруппа Тогда
		Физлицо = Справочники.ФизическиеЛица.ПустаяСсылка();
		Наименование = "";
	КонецЕсли;
	
	
КонецПроцедуры

// Процедура - обработчик события "Заполнение" объекта
Процедура ОбработкаЗаполнения(Основание)

	ТипОснования = ТипЗнч(Основание);
	
	Если ТипОснования = Тип("СправочникСсылка.ФизическиеЛица") 
		И НЕ Основание.ЭтоГруппа Тогда
		Физлицо = Основание;
	КонецЕсли;
	
КонецПроцедуры

// Процедура - обработчик события "ПередЗаписью" объекта
//
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоГруппа И Физлицо.Пустая() Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Для сотрудника не задано физическое лицо!");
		Отказ = Истина;
	КонецЕсли;
		
КонецПроцедуры // ПередЗаписью()

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ

#Если Клиент Тогда

// Функция подбирает из справочника организаций первую разрешенную
//
// Параметры
//  ТолькоГоловныеОрганизации  – Булево – подбор только среди головных организаций
//
// Возвращаемое значение:
//   <Справочники.Организации>   – Ссылка на организацию, или пустая ссылка
//
Функция ПодобратьОрганизацию (ТолькоГоловныеОрганизации = Ложь) Экспорт

	ТекстЗапроса =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	Организации.Ссылка КАК Организация,
	|	Организации.ПометкаУдаления
	|ИЗ
	|	Справочник.Организации КАК Организации";
	Если ТолькоГоловныеОрганизации Тогда
		ТекстЗапроса = ТекстЗапроса + "
		|ГДЕ
		|	Организации.ГоловнаяОрганизация = ЗНАЧЕНИЕ(Справочник.Организации.ПустаяСсылка)";
	КонецЕсли;
	ТекстЗапроса = ТекстЗапроса + "
	|УПОРЯДОЧИТЬ ПО
	|	Организации.Код";
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Организация;
	Иначе
		Возврат Справочники.Организации.ПустаяСсылка();
	КонецЕсли;

КонецФункции // ПодобратьОрганизацию ()

Процедура мПостфиксНаименованияНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка,ФизлицоОбъект) Экспорт
	
	СписокВозможныхЗначений = Новый СписокЗначений;
	НаименованиеБезПостфикса = ФизлицоОбъект.Наименование;
	СписокВозможныхЗначений.Добавить(НаименованиеБезПостфикса);
	
	Если ВидЗанятости = Перечисления.ВидыЗанятостиВОрганизации.ВнутреннееСовместительство Тогда
		СписокВозможныхЗначений.Добавить(НаименованиеБезПостфикса + " (вн. совм.)");
	ИначеЕсли ВидЗанятости = Перечисления.ВидыЗанятостиВОрганизации.ОсновноеМестоРаботы Тогда	
		СписокВозможныхЗначений.Добавить(НаименованиеБезПостфикса + " (осн.)");
	Иначе
		СписокВозможныхЗначений.Добавить(НаименованиеБезПостфикса + " (совм.)");			
	КонецЕсли; 
	
	Если Не ПустаяСтрока(ПостфиксНаименования) и СписокВозможныхЗначений.НайтиПоЗначению(Наименование) = Неопределено Тогда
		СписокВозможныхЗначений.Добавить(Наименование);	
	КонецЕсли;	
	
	СписокВозможныхЗначений.Добавить("Произвольное","задать произвольное дополнение наименования (не более 15-и символов)");
	
	Элемент.СписокВыбора = СписокВозможныхЗначений;
	
КонецПроцедуры

Процедура мПостфиксНаименованияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка,ФизлицоОбъект) Экспорт
	
	СтандартнаяОбработка = Ложь;
	Если ВыбранноеЗначение = "Произвольное" Тогда
		Текст = ПостфиксНаименования;
		ВвестиСтроку(Текст, "Введите дополнение наименования", 15);
		ПостфиксНаименования = Текст;
		Наименование = ФизлицоОбъект.Наименование + " " + ПостфиксНаименования;
	Иначе
		Наименование = ВыбранноеЗначение;
		НаименованиеБезПостфикса = ФизлицоОбъект.Наименование;
		ПостфиксНаименования = СокрЛП(СтрЗаменить(ВыбранноеЗначение, НаименованиеБезПостфикса, ""));	
	КонецЕсли; 

КонецПроцедуры

#КонецЕсли


