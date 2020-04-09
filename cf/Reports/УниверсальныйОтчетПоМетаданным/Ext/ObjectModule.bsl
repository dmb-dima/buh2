﻿Перем СохраненнаяНастройка Экспорт;
Перем Расшифровки Экспорт;

Перем ОписаниеХарактеристик;

#Если Клиент ИЛИ ВнешнееСоединение Тогда

Функция СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина) Экспорт
	
	Возврат ТиповыеОтчеты.СформироватьТиповойОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета);
	
КонецФункции

Процедура ДоработатьКомпоновщикПередВыводом() Экспорт
	
	
КонецПроцедуры

#КонецЕсли

#Если Клиент Тогда
	
// Для настройки отчета (расшифровка и др.)
Процедура Настроить(Отбор, КомпоновщикНастроекОсновногоОтчета = Неопределено) Экспорт
	
	ТиповыеОтчеты.НастроитьТиповойОтчет(ЭтотОбъект, Отбор, КомпоновщикНастроекОсновногоОтчета);
	
КонецПроцедуры

Процедура СохранитьНастройку() Экспорт
	
	СтруктураНастроек = ТиповыеОтчеты.ПолучитьСтруктуруПараметровТиповогоОтчета(ЭтотОбъект);
	СохранениеНастроек.СохранитьНастройкуОбъекта(СохраненнаяНастройка, СтруктураНастроек);
	
КонецПроцедуры

// Процедура заполняет параметры отчета по элементу справочника из переменной СохраненнаяНастройка.
Процедура ПрименитьНастройку() Экспорт
	
	Если СохраненнаяНастройка = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если СохраненнаяНастройка.Пустая() Тогда
		Возврат;
	КонецЕсли;
	 
	СтруктураПараметров = СохраненнаяНастройка.ХранилищеНастроек.Получить();
	ТиповыеОтчеты.ПрименитьСтруктуруПараметровОтчета(ЭтотОбъект, СтруктураПараметров);
	
КонецПроцедуры

Процедура ЗаполнитьСтруктуруПоУмолчанию()
	
	ЭлементСтруктуры = КомпоновщикНастроек.Настройки.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	ПолеГруппировки = ЭлементСтруктуры.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
	ЭлементПорядка = ЭлементСтруктуры.Порядок.Элементы.Добавить(Тип("АвтоЭлементПорядкаКомпоновкиДанных"));
	Если ТипДанных = "Справочники" Тогда
		ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных("Наименование");
	ИначеЕсли ТипДанных = "Документы" Тогда
		ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных("Ссылка");
	ИначеЕсли ЭлементСтруктуры.ПоляГруппировки.ДоступныеПоляПолейГруппировок.Элементы.Количество() > 0 
		И Метаданные[ТипДанных][ИмяОбъекта].Измерения.Количество() > 0 Тогда
		ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных(Метаданные[ТипДанных][ИмяОбъекта].Измерения[0].Имя);
	КонецЕсли;
	ТиповыеОтчеты.ДобавитьАвтоВыбранноеПоле(ЭлементСтруктуры);
	
КонецПроцедуры

Процедура ДобавитьПоказатели()
	
	Если ИмяТаблицы = "ОстаткиИОбороты" Тогда
		ВыбранныеПоляНачальныйОстаток = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляНачальныйОстаток.Заголовок = "Нач. остаток";
		ВыбранныеПоляНачальныйОстаток.Расположение = РасположениеПоляКомпоновкиДанных.Вертикально;
		ВыбранныеПоляПриход = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляПриход.Заголовок = "Приход";
		ВыбранныеПоляПриход.Расположение = РасположениеПоляКомпоновкиДанных.Вертикально;
		ВыбранныеПоляРасход = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляРасход.Заголовок = "Расход";
		ВыбранныеПоляРасход.Расположение = РасположениеПоляКомпоновкиДанных.Вертикально;
		ВыбранныеПоляКонечныйОстаток = КомпоновщикНастроек.Настройки.Выбор.Элементы.Добавить(Тип("ГруппаВыбранныхПолейКомпоновкиДанных"));
		ВыбранныеПоляКонечныйОстаток.Заголовок = "Кон. остаток";
		ВыбранныеПоляКонечныйОстаток.Расположение = РасположениеПоляКомпоновкиДанных.Вертикально;
	КонецЕсли;
	
	Если ТипДанных = "РегистрыНакопления" Тогда
		Для каждого Ресурс Из Метаданные[ТипДанных][ИмяОбъекта].Ресурсы Цикл
			ВыбранныеПоля = КомпоновщикНастроек.Настройки.Выбор;
			Если ИмяТаблицы = "Обороты" Тогда
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоля, Ресурс.Имя + "Оборот");
			ИначеЕсли ИмяТаблицы = "ОстаткиИОбороты" Тогда
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоляНачальныйОстаток, Ресурс.Имя + "." + Ресурс.Имя + "НачальныйОстаток", Ресурс.Синоним);
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоляПриход, Ресурс.Имя + "." + Ресурс.Имя + "Приход", Ресурс.Синоним);
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоляРасход, Ресурс.Имя + "." + Ресурс.Имя + "Расход", Ресурс.Синоним);
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоляКонечныйОстаток, Ресурс.Имя + "." + Ресурс.Имя + "КонечныйОстаток", Ресурс.Синоним);
				//ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоля, Ресурс.Имя + "." + Ресурс.Имя + "Оборот", Ресурс.Синоним);
			ИначеЕсли ИмяТаблицы = "" Тогда
				ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоля, Ресурс.Имя);
			КонецЕсли;
		КонецЦикла;
	ИначеЕсли ТипДанных = "РегистрыСведений" Тогда
		Для каждого Ресурс Из Метаданные[ТипДанных][ИмяОбъекта].Ресурсы Цикл
			ВыбранныеПоля = КомпоновщикНастроек.Настройки.Выбор;
			ТиповыеОтчеты.ДобавитьВыбранноеПоле(ВыбранныеПоля, Ресурс.Имя);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьПоляНабораДанных()
		
	Если ТипДанных = "РегистрыНакопления" ИЛИ ТипДанных = "РегистрыСведений" Тогда
		
		// Добавляем измерения
		Для каждого Измерение Из Метаданные[ТипДанных][ИмяОбъекта].Измерения Цикл
			ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Измерение.Имя, Измерение.Синоним);
		КонецЦикла;
		
		// Добавляем реквизиты
		Если ПустаяСтрока(ИмяТаблицы) Тогда
			Для каждого Реквизит Из Метаданные[ТипДанных][ИмяОбъекта].Реквизиты Цикл
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Реквизит.Имя, Реквизит.Синоним);
			КонецЦикла;
		КонецЕсли;
		
		// Добавляем поля периода
		Если ИмяТаблицы = "ОстаткиИОбороты" ИЛИ ИмяТаблицы = "Обороты" Тогда
			ТиповыеОтчеты.ДобавитьПоляПериодаВНаборДанных(СхемаКомпоновкиДанных.НаборыДанных[0]);
		КонецЕсли;
		
		// Добавляем ресурсы
		Для каждого Ресурс Из Метаданные[ТипДанных][ИмяОбъекта].Ресурсы Цикл
			Если ИмяТаблицы = "Обороты" Тогда
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Оборот", Ресурс.Синоним);
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "Оборот");

			ИначеЕсли ИмяТаблицы = "ОстаткиИОбороты" Тогда
				
				ПапкаПолейНабораДанных = СхемаКомпоновкиДанных.НаборыДанных[0].Поля.Добавить(Тип("ПапкаПолейНабораДанныхСхемыКомпоновкиДанных"));
				ПапкаПолейНабораДанных.Заголовок   = Ресурс.Синоним;
				ПапкаПолейНабораДанных.ПутьКДанным = Ресурс.Имя;
	                                                                                         
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "НачальныйОстаток", Ресурс.Синоним + " нач. остаток", Ресурс.Имя + "." + Ресурс.Имя + "НачальныйОстаток");
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "." + Ресурс.Имя + "НачальныйОстаток");
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Приход", Ресурс.Синоним + " приход", Ресурс.Имя + "." + Ресурс.Имя + "Приход");
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "." + Ресурс.Имя + "Приход");
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Расход", Ресурс.Синоним + " расход", Ресурс.Имя + "." + Ресурс.Имя + "Расход");
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "." + Ресурс.Имя + "Расход");
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Оборот", Ресурс.Синоним + " оборот", Ресурс.Имя + "." + Ресурс.Имя + "Оборот");
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "." + Ресурс.Имя + "Оборот");
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "КонечныйОстаток", Ресурс.Синоним + " кон. остаток", Ресурс.Имя + "." + Ресурс.Имя + "КонечныйОстаток");
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "." + Ресурс.Имя + "КонечныйОстаток");
				
				//ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "НачальныйОстаток", Ресурс.Синоним + " нач. остаток");
				//ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "НачальныйОстаток");
				//
				//ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Приход", Ресурс.Синоним + " приход");
				//ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "Приход");
				//
				//ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Расход", Ресурс.Синоним + " расход");
				//ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "Расход");
				//
				//ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "Оборот", Ресурс.Синоним + " оборот");
				//ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "Оборот");
				//
				//ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя + "КонечныйОстаток", Ресурс.Синоним + " кон. остаток");
				//ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя + "КонечныйОстаток");
				
			ИначеЕсли ТипДанных = "РегистрыСведений" Тогда
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя, Ресурс.Синоним);
				
				Типы = Ресурс.Тип.Типы();
				Если Типы.Количество() = 1 И Типы[0] = Тип("Число") Тогда
					ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя);
				КонецЕсли;
				
			ИначеЕсли ИмяТаблицы = "" Тогда
				
				ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Ресурс.Имя, Ресурс.Синоним);
				ТиповыеОтчеты.ДобавитьПолеИтога(СхемаКомпоновкиДанных, Ресурс.Имя);
				
			КонецЕсли;	
		КонецЦикла;
		
	ИначеЕсли ТипДанных = "Документы" ИЛИ ТипДанных = "Справочники" Тогда
		
		Если ПустаяСтрока(ИмяТаблицы) Тогда
			ОбъектМетаданных = Метаданные[ТипДанных][ИмяОбъекта];
		Иначе
			ОбъектМетаданных = Метаданные[ТипДанных][ИмяОбъекта].ТабличныеЧасти[ИмяТаблицы];
		КонецЕсли;
		
		// Добавляем реквизиты
		Для каждого Реквизит Из ОбъектМетаданных.Реквизиты Цикл
			ТиповыеОтчеты.ДобавитьПолеНабораДанных(СхемаКомпоновкиДанных.НаборыДанных[0], Реквизит.Имя, Реквизит.Синоним);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьЗапросПоМетаданным()
	
	ТекстЗапроса = " ВЫБРАТЬ РАЗРЕШЕННЫЕ " + Символы.ПС;
	
	Если ТипДанных = "РегистрыСведений" Тогда
		ИмяТипаДанных = "РегистрСведений";
	ИначеЕсли ТипДанных = "РегистрыНакопления" Тогда
		ИмяТипаДанных = "РегистрНакопления";
	ИначеЕсли ТипДанных = "Справочники" Тогда
		ИмяТипаДанных = "Справочник";
	ИначеЕсли ТипДанных = "Документы" Тогда
		ИмяТипаДанных = "Документ";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса +
	" * ИЗ " + ИмяТипаДанных + "." + ИмяОбъекта;
	
	Если Не ПустаяСтрока(ИмяТаблицы) Тогда
		ТекстЗапроса = ТекстЗапроса + "." + ИмяТаблицы;
	КонецЕсли;
	
	Если ТипДанных = "РегистрыНакопления"
		И (ИмяТаблицы = "ОстаткиИОбороты" ИЛИ ИмяТаблицы = "Обороты") Тогда
		ТекстЗапроса = ТекстЗапроса + "( , ,Авто)";
	КонецЕсли;
	
	ТекстЗапроса = ТекстЗапроса + " КАК ИсточникДанных";
	
	ТекстЗапроса = ТекстЗапроса + Символы.ПС + ОписаниеХарактеристик;
	
	Возврат ТекстЗапроса;
	
КонецФункции

Процедура ИнициализацияОтчета() Экспорт
	
	Если ПустаяСтрока(ТипДанных) ИЛИ ПустаяСтрока(ИмяОбъекта) Тогда
		Возврат;
	КонецЕсли;
	
	СхемаКомпоновкиДанных = Новый СхемаКомпоновкиДанных;
	
	ИсточникДанных = ТиповыеОтчеты.ДобавитьЛокальныйИсточникДанных(СхемаКомпоновкиДанных);
	
	НаборДанных = ТиповыеОтчеты.ДобавитьНаборДанныхЗапрос(СхемаКомпоновкиДанных.НаборыДанных, ИсточникДанных);
	
	НаборДанных.Запрос = СформироватьЗапросПоМетаданным();
	ДобавитьПоляНабораДанных();
	
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	КомпоновщикНастроек.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	
	ЗаполнитьСтруктуруПоУмолчанию();
	ДобавитьПоказатели();
	
	ТиповыеОтчеты.УстановитьПараметрВывода(КомпоновщикНастроек, "Title", Метаданные[ТипДанных][ИмяОбъекта].Синоним);
	ТиповыеОтчеты.УстановитьПараметрВывода(КомпоновщикНастроек, "TitleOutput", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
	ТиповыеОтчеты.УстановитьПараметрВывода(КомпоновщикНастроек, "FilterOutput", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
	ТиповыеОтчеты.УстановитьПараметрВывода(КомпоновщикНастроек, "DataParametersOutput", ТипВыводаТекстаКомпоновкиДанных.НеВыводить);
	
	ТиповыеОтчеты.ИнициализацияТиповогоОтчета(ЭтотОбъект);
	
КонецПроцедуры

Расшифровки = Новый СписокЗначений;

НастройкаПериода = Новый НастройкаПериода;

ОписаниеХарактеристик = ПолучитьМакет("ОписаниеХарактеристик").ПолучитьТекст();

#КонецЕсли