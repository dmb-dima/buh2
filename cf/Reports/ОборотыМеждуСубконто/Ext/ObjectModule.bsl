﻿Перем СохраненнаяНастройка Экспорт;
Перем Расшифровки Экспорт;
Перем РежимРасшифровки Экспорт;
Перем СохранятьНастройкуОтчета Экспорт;

#Если Клиент Тогда
	
Функция ПолучитьПараметрыВыбораЗначенияОтбора() Экспорт
	
	СписокПараметров = Новый Структура;
	СписокПараметров.Вставить("Дата"              , КонецПериода);
	СписокПараметров.Вставить("СчетУчета"         , Неопределено);
	СписокПараметров.Вставить("Номенклатура"      , Неопределено);
	СписокПараметров.Вставить("Склад"             , Неопределено);
	СписокПараметров.Вставить("Организация"       , Организация);
	СписокПараметров.Вставить("Контрагент"        , Неопределено);
	СписокПараметров.Вставить("ДоговорКонтрагента", Неопределено);
	СписокПараметров.Вставить("ЭтоНовыйДокумент"  , Ложь);
	
	Возврат СписокПараметров;
	
КонецФункции

Процедура ОбработкаИзмененияСоставаСубконто(ПолнаяОбработка = Истина) Экспорт
	
	МассивСубконто    = Новый Массив;
	МассивКорСубконто = Новый Массив;
	
	ИмяПоляПрефикс    = "Субконто";
	ИмяПоляПрефиксКор = "КорСубконто";
	
	// Изменение представления и наложения ограничения типа значения
	Индекс = 1;
	Для Каждого ВидСубконто Из СписокВидовСубконто Цикл
		Если ЗначениеЗаполнено(ВидСубконто.Значение) Тогда
			МассивСубконто.Добавить(ВидСубконто.Значение);
			Поле = СхемаКомпоновкиДанных.НаборыДанных[0].Поля.Найти(ИмяПоляПрефикс + Индекс);
			Если Поле <> Неопределено Тогда
				Поле.ТипЗначения = ВидСубконто.Значение.ТипЗначения;
				Поле.Заголовок   = Строка(ВидСубконто.Значение);
			КонецЕсли;
			Индекс = Индекс + 1;
		КонецЕсли;
	КонецЦикла;
	
	// Изменение представления и наложения ограничения типа значения
	Индекс = 1;
	Для Каждого ВидСубконто Из СписокВидовКорСубконто Цикл
		Если ЗначениеЗаполнено(ВидСубконто.Значение) Тогда
			МассивКорСубконто.Добавить(ВидСубконто.Значение);
			Поле = СхемаКомпоновкиДанных.НаборыДанных[0].Поля.Найти(ИмяПоляПрефиксКор + Индекс);
			Если Поле <> Неопределено Тогда
				Поле.ТипЗначения = ВидСубконто.Значение.ТипЗначения;
				Поле.Заголовок   = "Кор. " + Строка(ВидСубконто.Значение);
			КонецЕсли;
			Индекс = Индекс + 1;
		КонецЕсли;
	КонецЦикла;

	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	
	
	Если ПолнаяОбработка Тогда
			ДанныеОтчета.ПоказателиОтчета.БУ.Использование            = Истина;
			ДанныеОтчета.ПоказателиОтчета.БУ.Значение                 = Истина;
			ДанныеОтчета.ПоказателиОтчета.НУ.Использование            = Истина;
			ДанныеОтчета.ПоказателиОтчета.НУ.Значение                 = Ложь;
			ДанныеОтчета.ПоказателиОтчета.ПР.Использование            = Истина;
			ДанныеОтчета.ПоказателиОтчета.ПР.Значение                 = Ложь;
			ДанныеОтчета.ПоказателиОтчета.ВР.Использование            = Истина;
			ДанныеОтчета.ПоказателиОтчета.ВР.Значение                 = Ложь;
			ДанныеОтчета.ПоказателиОтчета.ВалютнаяСумма.Использование = Истина;
			ДанныеОтчета.ПоказателиОтчета.ВалютнаяСумма.Значение      = Ложь;  
			ДанныеОтчета.ПоказателиОтчета.Количество.Использование    = Истина;
			ДанныеОтчета.ПоказателиОтчета.Количество.Значение         = Ложь;

			КоличествоСубконто = МассивСубконто.Количество();
		
		
		// Добавление группировок с соответствии с выбранным счетом	
		ДанныеОтчета.Группировка.Очистить();
		
		Для Индекс = 1 По КоличествоСубконто Цикл
			НоваяСтрока = ДанныеОтчета.Группировка.Добавить();
			Поле = КомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ИмяПоляПрефикс + Индекс));
			НоваяСтрока.Поле           = Поле.Поле;
			НоваяСтрока.Использование  = Истина;
			НоваяСтрока.Представление  = Поле.Заголовок;
			НоваяСтрока.ТипГруппировки = СтандартныеОтчеты.ПолучитьТипДетализацииПоУмолчанию(Поле.ТипЗначения);
		КонецЦикла;
		
		Если Не РежимРасшифровки Тогда
			// Добавление неактивных отборов по субконто в соответствии с выбранным счетом
			ОтборыДляУдаления = Новый Массив;
			Для Каждого ЭлементОтбора Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
				Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
					Если Найти(Строка(ЭлементОтбора.ЛевоеЗначение), "Субконто") = 1 ИЛИ Строка(ЭлементОтбора.ЛевоеЗначение) = "Валюта" Тогда
						ОтборыДляУдаления.Добавить(ЭлементОтбора);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			
			ТипыУдаляемыхЭлементовОтбора = Новый Массив;
			Для Каждого ЭлементОтбора Из ОтборыДляУдаления Цикл
				КомпоновщикНастроек.Настройки.Отбор.Элементы.Удалить(ЭлементОтбора);
				ТипыУдаляемыхЭлементовОтбора.Добавить(ТипЗнч(ЭлементОтбора.ПравоеЗначение));
			КонецЦикла;
			
			Для Индекс = 1 По МассивСубконто.Количество() Цикл
				Поле = КомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ИмяПоляПрефикс + Индекс));
				НовыйЭлементОтбора = ТиповыеОтчеты.ДобавитьОтбор(КомпоновщикНастроек,
					ИмяПоляПрефикс + Индекс, МассивСубконто[Индекс - 1].ТипЗначения.ПривестиЗначение(Неопределено), , Ложь);
				ТипСубконтоКДобавлению    = ТипЗнч(МассивСубконто[Индекс - 1].ТипЗначения.ПривестиЗначение(Неопределено));
				ИндексОдинаковогоСубконто = ТипыУдаляемыхЭлементовОтбора.Найти(ТипСубконтоКДобавлению);
				Если ИндексОдинаковогоСубконто <> Неопределено Тогда
					НовыйЭлементОтбора.ПравоеЗначение = ОтборыДляУдаления[ИндексОдинаковогоСубконто].ПравоеЗначение;
					НовыйЭлементОтбора.ВидСравнения   = ОтборыДляУдаления[ИндексОдинаковогоСубконто].ВидСравнения;
					НовыйЭлементОтбора.Использование  = ЗначениеЗаполнено(ОтборыДляУдаления[ИндексОдинаковогоСубконто].ПравоеЗначение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		КоличествоКорСубконто = МассивКорСубконто.Количество();
						
		Для Индекс = 1 По КоличествоКорСубконто Цикл
			НоваяСтрока = ДанныеОтчета.Группировка.Добавить();
			Поле = КомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ИмяПоляПрефиксКор + Индекс));
			НоваяСтрока.Поле           = Поле.Поле;
			НоваяСтрока.Использование  = Истина;
			НоваяСтрока.Представление  = Поле.Заголовок;
			НоваяСтрока.ТипГруппировки = СтандартныеОтчеты.ПолучитьТипДетализацииПоУмолчанию(Поле.ТипЗначения);
		КонецЦикла;
		
		Если Не РежимРасшифровки Тогда
			// Добавление неактивных отборов по субконто в соответствии с выбранным счетом
			ОтборыДляУдаления = Новый Массив;
			Для Каждого ЭлементОтбора Из КомпоновщикНастроек.Настройки.Отбор.Элементы Цикл
				Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") Тогда 
					Если Найти(Строка(ЭлементОтбора.ЛевоеЗначение), "КорСубконто") = 1 ИЛИ Строка(ЭлементОтбора.ЛевоеЗначение) = "КорВалюта" Тогда
						ОтборыДляУдаления.Добавить(ЭлементОтбора);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			
			ТипыУдаляемыхЭлементовОтбора = Новый Массив;
			Для Каждого ЭлементОтбора Из ОтборыДляУдаления Цикл
				КомпоновщикНастроек.Настройки.Отбор.Элементы.Удалить(ЭлементОтбора);
				ТипыУдаляемыхЭлементовОтбора.Добавить(ТипЗнч(ЭлементОтбора.ПравоеЗначение));
			КонецЦикла;
			
			Для Индекс = 1 По МассивКорСубконто.Количество() Цикл
				Поле = КомпоновщикНастроек.Настройки.ДоступныеПоляОтбора.НайтиПоле(Новый ПолеКомпоновкиДанных(ИмяПоляПрефиксКор + Индекс));
				НовыйЭлементОтбора = ТиповыеОтчеты.ДобавитьОтбор(КомпоновщикНастроек,
					ИмяПоляПрефиксКор + Индекс, МассивКорСубконто[Индекс - 1].ТипЗначения.ПривестиЗначение(Неопределено), , Ложь);
				ТипСубконтоКДобавлению    = ТипЗнч(МассивКорСубконто[Индекс - 1].ТипЗначения.ПривестиЗначение(Неопределено));
				ИндексОдинаковогоСубконто = ТипыУдаляемыхЭлементовОтбора.Найти(ТипСубконтоКДобавлению);
				Если ИндексОдинаковогоСубконто <> Неопределено Тогда
					НовыйЭлементОтбора.ПравоеЗначение = ОтборыДляУдаления[ИндексОдинаковогоСубконто].ПравоеЗначение;
					НовыйЭлементОтбора.ВидСравнения   = ОтборыДляУдаления[ИндексОдинаковогоСубконто].ВидСравнения;
					НовыйЭлементОтбора.Использование  = ЗначениеЗаполнено(ОтборыДляУдаления[ИндексОдинаковогоСубконто].ПравоеЗначение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		// Обработка дополнительных полей
		СтандартныеОтчеты.ЗаполнитьДополнительныеПоляПоУмолчанию(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	СтандартныеОтчеты.ЗаполнитьДанныеОтчета(ЭтотОбъект);
	
КонецПроцедуры

Процедура СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина, ВнешниеНаборыДанных = Неопределено, ВыводитьПолностью = Истина) Экспорт
	
	Результат.Очистить();
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ВыводЗаголовкаОтчета(ЭтотОбъект, Результат);
	Если ВыводитьПолностью Тогда
		ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных);
		КомпоновщикНастроек.Восстановить();
		НастройкаКомпоновкиДанных = КомпоновщикНастроек.ПолучитьНастройки();
		КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
		СтандартныеОтчеты.ВывестиОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета, ВнешниеНаборыДанных, Истина, НастройкаКомпоновкиДанных);
	КонецЕсли; 
	ВыводПодписейОтчета(ЭтотОбъект, Результат);
	
	Если ВыводитьПолностью Тогда
		// Выполним дополнительную обработку Результата отчета
		ОбработкаРезультатаОтчета(Результат);
		
		// Сохраним настройки для Истории
		СтандартныеОтчеты.СохранитьНастройкуДляИстории(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередВыводомОтчета(МакетКомпоновки) Экспорт
	
	ПоказателиОтчета = ДанныеОтчета.ПоказателиОтчета;	
	//
	МакетШапкиОтчета = СтандартныеОтчеты.ПолучитьМакетШапки(МакетКомпоновки);
	
	КоличествоПоказателей = 0;
	Для Каждого Показатель Из ПоказателиОтчета Цикл
		Если Показатель.Значение.Значение Тогда
			КоличествоПоказателей = КоличествоПоказателей + 1;
		КонецЕсли;
	КонецЦикла;
	
	КоличествоГруппировок = 1;
	Для Каждого Группировка Из ДанныеОтчета.Группировка Цикл
		Если Группировка.Использование Тогда
			КоличествоГруппировок = КоличествоГруппировок + 1;
		КонецЕсли;
	КонецЦикла;
	
	КоличествоСтрокШапки = Макс(КоличествоГруппировок, 1);
	ДанныеОтчета.Вставить("ВысотаШапки", КоличествоСтрокШапки);
	
	МассивДляУдаления = Новый Массив;
	Для Индекс = КоличествоСтрокШапки По МакетШапкиОтчета.Макет.Количество() - 1 Цикл
		МассивДляУдаления.Добавить(МакетШапкиОтчета.Макет[Индекс]);
	КонецЦикла;
	
	КоличествоСтрок = МакетШапкиОтчета.Макет.Количество();
	Для ИндексСтроки = 1 По КоличествоСтрок - 1 Цикл
		СтрокаМакета = МакетШапкиОтчета.Макет[ИндексСтроки];
		
		КоличествоКолонок = СтрокаМакета.Ячейки.Количество();
		
		Для ИндексКолонки = КоличествоКолонок - 5 По КоличествоКолонок - 1 Цикл
			Ячейка = СтрокаМакета.Ячейки[ИндексКолонки];
			ТиповыеОтчеты.УстановитьПараметр(Ячейка.Оформление.Элементы, "ОбъединятьПоВертикали", Истина);
			Если ИндексКолонки = КоличествоКолонок - 1 ИЛИ ИндексКолонки = КоличествоКолонок - 3 Тогда
				ТиповыеОтчеты.УстановитьПараметр(Ячейка.Оформление.Элементы, "ОбъединятьПоГоризонтали", Истина);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;	
	
	Для Каждого Элемент Из МассивДляУдаления Цикл
		МакетШапкиОтчета.Макет.Удалить(Элемент);
	КонецЦикла;
	
	МакетДетали = СтандартныеОтчеты.ПолучитьМакетГруппировкиПоПолюГруппировки(МакетКомпоновки, "Детали", Истина);
	Если МакетДетали.Количество() = 1 Тогда
		Для Каждого СтрокаМакета Из МакетДетали[0].Макет Цикл
			Для Каждого Ячейка Из СтрокаМакета.Ячейки Цикл
				ЗначениеПараметра = ТиповыеОтчеты.ПолучитьПараметр(Ячейка.Оформление.Элементы, "Расшифровка");
				
				ПараметрРасшифровки = МакетДетали[0].Параметры.Найти(ЗначениеПараметра.Значение);
				Если ТипЗнч(ПараметрРасшифровки) = Тип("ПараметрОбластиРасшифровкаКомпоновкиДанных") Тогда 
					Если ПараметрРасшифровки.ВыраженияПолей.Найти("Счет") = Неопределено Тогда 
						ПараметрСчет = ПараметрРасшифровки.ВыраженияПолей.Добавить();
						ПараметрСчет.Поле      = "Счет";
						ПараметрСчет.Выражение = "ОсновнойНабор.Счет";
					КонецЕсли;
					Если ПараметрРасшифровки.ВыраженияПолей.Найти("КорСчет") = Неопределено Тогда
						ПараметрКорСчет = ПараметрРасшифровки.ВыраженияПолей.Добавить();
						ПараметрКорСчет.Поле      = "КорСчет";
						ПараметрКорСчет.Выражение = "ОсновнойНабор.КорСчет";
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
	//
	Для Каждого Макет Из МакетКомпоновки.Макеты Цикл 
		Если МакетДетали.Найти(Макет) = Неопределено И Макет <> МакетШапкиОтчета Тогда
			Если ПоказателиОтчета.ВалютнаяСумма.Значение Тогда 
				Макет.Макет.Удалить(Макет.Макет[КоличествоПоказателей - 1]);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
		
КонецПроцедуры

Процедура ПередВыводомЭлементаРезультата(МакетКомпоновки, ДанныеРасшифровки, ЭлементРезультата, Отказ = Ложь) Экспорт

	
КонецПроцедуры

// В процедуре можно доработать компоновщик перед выводом в отчет
// Изменения сохранены не будут
Процедура ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных) Экспорт
	
	КомпоновщикНастроек.Настройки.Структура.Очистить();
	КомпоновщикНастроек.Настройки.Выбор.Элементы.Очистить();
	//
	Если ЗначениеЗаполнено(НачалоПериода) Тогда
		ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "НачалоПериода", НачалоДня(НачалоПериода));
	КонецЕсли;
	Если ЗначениеЗаполнено(КонецПериода) Тогда
		ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "КонецПериода", КонецДня(КонецПериода));
	КонецЕсли;
	Если ЗначениеЗаполнено(Подразделение) Тогда
		ТиповыеОтчеты.ДобавитьОтбор(КомпоновщикНастроек, "Подразделение", Подразделение, ВидСравненияКомпоновкиДанных.ВИерархии);
	КонецЕсли;
	//
	МассивВидовСубконто = Новый Массив;
	Для Каждого ЭлементСписка Из СписокВидовСубконто Цикл
		Если ЗначениеЗаполнено(ЭлементСписка.Значение) Тогда 
			МассивВидовСубконто.Добавить(ЭлементСписка.Значение);
		КонецЕсли;
	КонецЦикла;
	
	МассивВидовКорСубконто = Новый Массив;
	Для Каждого ЭлементСписка Из СписокВидовКорСубконто Цикл
		Если ЗначениеЗаполнено(ЭлементСписка.Значение) Тогда 
			МассивВидовКорСубконто.Добавить(ЭлементСписка.Значение);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивВидовСубконто.Количество() > 0 Тогда
		ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "СписокВидовСубконто", МассивВидовСубконто);
	КонецЕсли;
	Если МассивВидовКорСубконто.Количество() > 0 Тогда
		ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "СписокВидовКорСубконто", МассивВидовКорСубконто);
	КонецЕсли;
	
	ПоказателиОтчета = ДанныеОтчета.ПоказателиОтчета;
	//
	КоличествоПоказателей = 0;
	КоличествоВидовУчета = 0;
	Для Каждого Показатель Из ПоказателиОтчета Цикл
		Если Показатель.Ключ <> "Развернутое сальдо" Тогда
			КоличествоПоказателей = КоличествоПоказателей + Показатель.Значение.Значение;
			Если Найти(Показатель.Ключ, "Данные") > 0 Тогда
				КоличествоВидовУчета = КоличествоВидовУчета + 1;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
		
	МассивПоказателей = Новый Массив;
	МассивПоказателей.Добавить("БУ");
	МассивПоказателей.Добавить("НУ");
	МассивПоказателей.Добавить("ПР");
	МассивПоказателей.Добавить("ВР");
	МассивПоказателей.Добавить("ВалютнаяСумма");
	МассивПоказателей.Добавить("Количество");
		
	ПоказателиОтчета = ДанныеОтчета.ПоказателиОтчета;
	
	КоличествоПоказателей = СтандартныеОтчеты.КоличествоПоказателей(ЭтотОбъект);
	
	// Колонка "показатели"
	ГруппаПоказатели = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаПоказатели.Заголовок     = "Показатели";
	ГруппаПоказатели.Использование = Истина;
	ГруппаПоказатели.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	Для Каждого ЭлементМассива Из МассивПоказателей Цикл
		Если ПоказателиОтчета[ЭлементМассива].Значение И ЭлементМассива <> "ВалютнаяСумма" Тогда 
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаПоказатели, "Показатели." + ЭлементМассива);
		КонецЕсли;
	КонецЦикла;	
	
	ГруппаДт = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаДт.Заголовок     = "Дебет";
	ГруппаДт.Использование = Истина;
	ГруппаДт.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	ГруппаКт = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаКт.Заголовок     = "Кредит";
	ГруппаКт.Использование = Истина;
	ГруппаКт.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	Для Каждого ЭлементМассива Из МассивПоказателей Цикл
		Если ПоказателиОтчета[ЭлементМассива].Значение И ЭлементМассива <> "ВалютнаяСумма" Тогда
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаДт, "ОборотыЗаПериод." + ЭлементМассива + "ОборотДт");
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаКт, "ОборотыЗаПериод." + ЭлементМассива + "ОборотКт");
		КонецЕсли;
	КонецЦикла;

	// Дополнительные данные
	СтандартныеОтчеты.ДобавитьДополнительныеПоля(ЭтотОбъект);
	
	УсловноеОформлениеАвтоотступа = Неопределено;
	Для каждого ЭлементОформления Из КомпоновщикНастроек.Настройки.УсловноеОформление.Элементы Цикл
		Если ЭлементОформления.Представление = "Уменьшенный автоотступ" Тогда
			УсловноеОформлениеАвтоотступа = ЭлементОформления;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если УсловноеОформлениеАвтоотступа = Неопределено Тогда
		УсловноеОформлениеАвтоотступа = КомпоновщикНастроек.Настройки.УсловноеОформление.Элементы.Добавить();
		УсловноеОформлениеАвтоотступа.Представление = "Уменьшенный автоотступ";
		УсловноеОформлениеАвтоотступа.Оформление.УстановитьЗначениеПараметра("Автоотступ", 1);
		УсловноеОформлениеАвтоотступа.Использование = Ложь;
		УсловноеОформлениеАвтоотступа.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ;
	Иначе
		УсловноеОформлениеАвтоотступа.Поля.Элементы.Очистить();
	КонецЕсли;
	
	//
	Структура = КомпоновщикНастроек.Настройки.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	Структура.Имя = "ШапкаОтчета";
	Первый = Истина;
	Для Каждого ПолеВыбраннойГруппировки Из ДанныеОтчета.Группировка Цикл 
		Если ПолеВыбраннойГруппировки.Использование Тогда
			Если Не Первый Тогда 
				Структура = Структура.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
			КонецЕсли;
			Первый = Ложь;
			ПолеГруппировки = Структура.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
			ПолеГруппировки.Использование  = Истина;
			ПолеГруппировки.Поле           = Новый ПолеКомпоновкиДанных(ПолеВыбраннойГруппировки.Поле);
			
			Если ПолеВыбраннойГруппировки.ТипГруппировки = Перечисления.ТипДетализацииСтандартныхОтчетов.Иерархия Тогда
				ПолеГруппировки.ТипГруппировки = ТипГруппировкиКомпоновкиДанных.Иерархия;
			ИначеЕсли ПолеВыбраннойГруппировки.ТипГруппировки = Перечисления.ТипДетализацииСтандартныхОтчетов.ТолькоИерархия Тогда
				ПолеГруппировки.ТипГруппировки = ТипГруппировкиКомпоновкиДанных.ТолькоИерархия;
			Иначе
				ПолеГруппировки.ТипГруппировки = ТипГруппировкиКомпоновкиДанных.Элементы;
			КонецЕсли;
			Структура.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
			Структура.Порядок.Элементы.Добавить(Тип("АвтоЭлементПорядкаКомпоновкиДанных"));
			
			ПолеОформления = УсловноеОформлениеАвтоотступа.Поля.Элементы.Добавить();
			ПолеОформления.Поле = ПолеГруппировки.Поле;
		КонецЕсли;
	КонецЦикла;
	Структура = Структура.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	Структура.Имя = "Детали";
	ТиповыеОтчеты.ДобавитьВыбранноеПоле(Структура.Выбор,  "Счет");
	ТиповыеОтчеты.ДобавитьВыбранноеПоле(Структура.Выбор,  "КорСчет");
	
	ГруппаПоказатели = Структура.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаПоказатели.Заголовок     = "Показатели";
	ГруппаПоказатели.Использование = Истина;
	ГруппаПоказатели.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	// Колонка "показатели"
	Если КоличествоПоказателей > 1 Тогда
		ГруппаПоказатели = Структура.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ГруппаПоказатели.Заголовок     = "Показатели";
		ГруппаПоказатели.Использование = Истина;
		ГруппаПоказатели.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
		
		Для Каждого ЭлементМассива Из МассивПоказателей Цикл
			Если ПоказателиОтчета[ЭлементМассива].Значение Тогда 
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаПоказатели, "Показатели." + ЭлементМассива);
			КонецЕсли;
		КонецЦикла;	
	КонецЕсли;
	
	ГруппаДт = Структура.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаДт.Заголовок     = "Дебет";
	ГруппаДт.Использование = Истина;
	ГруппаДт.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	ГруппаКт = Структура.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
	ГруппаКт.Заголовок     = "Кредит";
	ГруппаКт.Использование = Истина;
	ГруппаКт.Расположение  = РасположениеПоляКомпоновкиДанных.Вертикально;
	
	Для Каждого ЭлементМассива Из МассивПоказателей Цикл
		Если ПоказателиОтчета[ЭлементМассива].Значение Тогда
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаДт, "ОборотыЗаПериод." + ЭлементМассива + "ОборотДт");
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ГруппаКт, "ОборотыЗаПериод." + ЭлементМассива + "ОборотКт");
		КонецЕсли;
	КонецЦикла;
	
	Структура.Порядок.Элементы.Добавить(Тип("АвтоЭлементПорядкаКомпоновкиДанных"));  
	
	СтандартныеОтчеты.ДобавитьОтборПоОрганизации(ЭтотОбъект);
	
	
	УсловноеОформление = КомпоновщикНастроек.Настройки.УсловноеОформление.Элементы.Добавить();	
	Поле = УсловноеОформление.Поля.Элементы.Добавить();
	Поле.Поле = Новый ПолеКомпоновкиДанных("ОборотыЗаПериод.НУОборотДт");
	Поле = УсловноеОформление.Поля.Элементы.Добавить();
	Поле.Поле = Новый ПолеКомпоновкиДанных("ОборотыЗаПериод.ПРОборотДт");
	Поле = УсловноеОформление.Поля.Элементы.Добавить();
	Поле.Поле = Новый ПолеКомпоновкиДанных("ОборотыЗаПериод.ВРОборотДт");
	
	ТиповыеОтчеты.ДобавитьОтбор(УсловноеОформление.Отбор, "ЕстьНалоговыйУчет", 0);
	ТиповыеОтчеты.УстановитьПараметр(УсловноеОформление.Оформление, "МаксимальнаяВысота", 1);
	
	УсловноеОформление = КомпоновщикНастроек.Настройки.УсловноеОформление.Элементы.Добавить();	
	Поле = УсловноеОформление.Поля.Элементы.Добавить();
	Поле.Поле = Новый ПолеКомпоновкиДанных("ОборотыЗаПериод.КоличествоОборотДт");
	
	ТиповыеОтчеты.ДобавитьОтбор(УсловноеОформление.Отбор, "ЕстьКоличество", 0);
	ТиповыеОтчеты.УстановитьПараметр(УсловноеОформление.Оформление, "МаксимальнаяВысота", 1);
	
	УсловноеОформление = КомпоновщикНастроек.Настройки.УсловноеОформление.Элементы.Добавить();	
	Поле = УсловноеОформление.Поля.Элементы.Добавить();
	Поле.Поле = Новый ПолеКомпоновкиДанных("ОборотыЗаПериод.ВалютнаяСуммаОборотДт");
	
	ТиповыеОтчеты.ДобавитьОтбор(УсловноеОформление.Отбор, "ЕстьВалюта", 0);
	ТиповыеОтчеты.УстановитьПараметр(УсловноеОформление.Оформление, "МаксимальнаяВысота", 1);
	
	Если УсловноеОформлениеАвтоотступа.Поля.Элементы.Количество() = 0 Тогда
		УсловноеОформлениеАвтоотступа.Использование = Ложь;
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыводЗаголовкаОтчета(ОтчетОбъект, Результат)
	
	 СтандартныеОтчеты.ВыводЗаголовкаОтчета(ОтчетОбъект, Результат);
			
КонецПроцедуры

Процедура ВыводПодписейОтчета(ОтчетОбъект, Результат)
	
	СтандартныеОтчеты.ВыводПодписейОтчета(ОтчетОбъект, Результат);
			
КонецПроцедуры

Функция ПолучитьТекстЗаголовка(ОрганизацияВНачале = Истина) Экспорт 
	
	ТекстСубконто = "";
	Для Каждого ВидСубконто Из СписокВидовСубконто Цикл
		ТекстСубконто = ТекстСубконто + ВидСубконто + ", ";	
	КонецЦикла;
	Если Не ПустаяСтрока(ТекстСубконто) Тогда
		ТекстСубконто = Лев(ТекстСубконто, СтрДлина(ТекстСубконто) - 2);
	КонецЕсли;
	
	ТекстКорСубконто = "";
	Для Каждого ВидСубконто Из СписокВидовКорСубконто Цикл
		ТекстКорСубконто = ТекстКорСубконто + ВидСубконто + ", ";	
	КонецЦикла;
	Если Не ПустаяСтрока(ТекстКорСубконто) Тогда
		ТекстКорСубконто = Лев(ТекстКорСубконто, СтрДлина(ТекстКорСубконто) - 2);
	КонецЕсли;
	Если ПустаяСтрока(ТекстСубконто) Тогда
		ОбщийТекстСубконто = "...";
	Иначе
		ОбщийТекстСубконто = ТекстСубконто;
	КонецЕсли;
	Если ПустаяСтрока(ТекстКорСубконто) Тогда
		ОбщийТекстСубконто = ОбщийТекстСубконто + " и ...";
	Иначе
		ОбщийТекстСубконто = ОбщийТекстСубконто + " и " + ТекстКорСубконто;
	КонецЕсли;
	ЗаголовокОтчета = "Обороты между субконто " + ОбщийТекстСубконто + СтандартныеОтчеты.ПолучитьПредставлениеПериода(ЭтотОбъект);

	Возврат ?(ОрганизацияВНачале, ЗаголовокОтчета, ЗаголовокОтчета + " " + СтандартныеОтчеты.ПолучитьТекстОрганизация(ЭтотОбъект));
	
КонецФункции

Процедура ПолучитьСтруктуруПоказателейОтчета() Экспорт
	
	ПоказателиОтчета = СтандартныеОтчеты.ПолучитьСтруктуруПоказателейОтчета(,,,, Ложь, Истина, Истина, Ложь);
	ДанныеОтчета.Вставить("ПоказателиОтчета", ПоказателиОтчета);

КонецПроцедуры

Процедура ОбработкаРезультатаОтчета(Результат)
	
	СтандартныеОтчеты.ОбработкаРезультатаОтчета(ЭтотОбъект, Результат);
	
	Индекс = Результат.ВысотаТаблицы;
	Пока Индекс > 0 Цикл
		ИндексСтроки = "R" + Формат(Индекс,"ЧГ=0");
		Если Результат.Область(ИндексСтроки).ВысотаСтроки = 1 Тогда
			Результат.УдалитьОбласть(Результат.Область(ИндексСтроки), ТипСмещенияТабличногоДокумента.ПоВертикали);
		КонецЕсли;
		Индекс = Индекс - 1;
	КонецЦикла;
	
	// Зафиксируем заголовок отчета
	ВысотаЗаголовка = Результат.Области.Заголовок.Низ;
	Результат.ФиксацияСверху = ВысотаЗаголовка + ДанныеОтчета.ВысотаШапки;
	
КонецПроцедуры

// Для настройки отчета (расшифровка и др.)
Процедура Настроить() Экспорт
	
	ЗаполнитьНачальныеНастройки();
	ОбработкаИзмененияСоставаСубконто(РежимРасшифровки);
	
КонецПроцедуры

Процедура СохранитьНастройку() Экспорт
	
	Если СохранятьНастройкуОтчета Тогда	
		СтандартныеОтчеты.СохранитьНастройку(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

// Процедура заполняет параметры отчета по элементу справочника из переменной СохраненнаяНастройка.
Процедура ПрименитьНастройку() Экспорт
	
	Если СохраненнаяНастройка.Пустая() Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураПараметров = СохраненнаяНастройка.ХранилищеНастроек.Получить();
	Если РежимРасшифровки Тогда
		НастройкиФормы = СтруктураПараметров.НастройкиФормы;
	Иначе
		ТиповыеОтчеты.ПрименитьСтруктуруПараметровОтчета(ЭтотОбъект, СтруктураПараметров);
	КонецЕсли;
	
КонецПроцедуры

Процедура ИнициализацияОтчета() Экспорт
	
	СтандартныеОтчеты.ИнициализацияОтчета(ЭтотОбъект);
	
КонецПроцедуры

Расшифровки = Новый СписокЗначений;

НастройкаПериода = Новый НастройкаПериода;

РежимРасшифровки = Ложь;

#КонецЕсли