﻿//////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьСписокВыбораПлановОбмена();
	
	ОбновитьСписокВыбораМакетаПравил();
	
	УстановитьВидимость();
	
КонецПроцедуры

//////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура ИмяПланаОбменаПриИзменении(Элемент)
	
	Запись.ИмяМакетаПравил = "";
	
	// вызов сервера
	ОбновитьСписокВыбораМакетаПравил();
	
КонецПроцедуры

&НаКлиенте
Процедура ИсточникПравилПриИзменении(Элемент)
	
	// вызов сервера
	УстановитьВидимость();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьПравила(Команда)
	
	Перем АдресВременногоХранилища;
	Перем ВыбранноеИмяФайла;
	
	Отказ = Ложь;
	
	ИмяФайлаПравил = "";
	
	Если Запись.ИсточникПравил = ПредопределенноеЗначение("Перечисление.ИсточникиПравилДляОбменаДанными.Файл") Тогда
		
		Если ПоместитьФайл(АдресВременногоХранилища, Запись.ИмяФайлаПравил, ВыбранноеИмяФайла, Истина, УникальныйИдентификатор) Тогда
			
			Файл = Новый Файл(ВыбранноеИмяФайла);
			
			ИмяФайлаПравил = Файл.Имя;
			
		Иначе
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	НСтрока = НСтр("ru = 'Выполняется загрузка правил в информационную базу...'");
	Состояние(НСтрока);
	
	// загрузка правил на сервере
	ЗагрузитьПравилаНаСервере(Отказ, АдресВременногоХранилища, ИмяФайлаПравил);
	
	// информация о статусе загрузки правил
	НСтрокаУспешно = НСтр("ru = 'Правила успешно загружены в информационную базу.'");
	НСтрокаОшибка  = НСтр("ru = 'В процессе загрузки правил были обнаружены ошибки! Загрузка не выполнена (см. журнал регистрации).'");
	
	СтрокаСообщения = ?(Отказ, НСтрокаОшибка, НСтрокаУспешно);
	
	Состояние(СтрокаСообщения);
	
	Предупреждение(СтрокаСообщения);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьПравила(Команда)
	
	Адрес = ПолучитьНавигационнуюСсылкуНаСервере();
	
	ИмяФайлаПравил = ?(ПустаяСтрока(Запись.ИмяФайлаПравил), "ПравилаДляОбменаДанными.xml", Запись.ИмяФайлаПравил);
	
	ПолучитьФайл(Адрес, ИмяФайлаПравил, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьИнформациюОПравилахИзФайла(Команда)
	
	ОбменДаннымиКлиент.ПолучитьИнформациюОПравилах(УникальныйИдентификатор);
	
КонецПроцедуры

//////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ОбновитьСписокВыбораПлановОбмена()
	
	СписокПлановОбмена = ОбменДаннымиПовтИсп.ПолучитьСписокПлановОбменаКонфигурацииВерсии30();
	
	ЗаполнитьСписок(СписокПлановОбмена, Элементы.ИмяПланаОбмена.СписокВыбора);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВыбораМакетаПравил()
	
	Если Запись.ВидПравил = Перечисления.ВидыПравилДляОбменаДанными.ПравилаКонвертацииОбъектов Тогда
		
		СписокМакетов = ОбменДаннымиПовтИсп.ПолучитьСписокТиповыхПравилОбмена(Запись.ИмяПланаОбмена);
		
	Иначе // ПравилаРегистрацииОбъектов
		
		СписокМакетов = ОбменДаннымиПовтИсп.ПолучитьСписокТиповыхПравилРегистрации(Запись.ИмяПланаОбмена);
		
	КонецЕсли;
	
	СписокВыбора = Элементы.ИмяМакетаПравил.СписокВыбора;
	СписокВыбора.Очистить();
	
	ЗаполнитьСписок(СписокМакетов, СписокВыбора);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписок(СписокИсточник, СписокПриемник)
	
	Для Каждого Элемент ИЗ СписокИсточник Цикл
		
		ЗаполнитьЗначенияСвойств(СписокПриемник.Добавить(), Элемент);
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимость()
	
	// если план обмена был ранее задан, то изменять его не даем
	Элементы.ГруппаПланаОбмена.Видимость = ПустаяСтрока(Запись.ИмяПланаОбмена);
	
	Элементы.ГруппаДополнительно.Видимость = (Запись.ВидПравил = Перечисления.ВидыПравилДляОбменаДанными.ПравилаКонвертацииОбъектов);
	
	ГруппаИсточникиПравил = Элементы.ГруппаИсточникиПравил;
	
	ГруппаИсточникиПравил.ТекущаяСтраница = ?(Запись.ИсточникПравил = Перечисления.ИсточникиПравилДляОбменаДанными.МакетКонфигурации,
	                                          ГруппаИсточникиПравил.ПодчиненныеЭлементы.Источник_МакетКонфигурации,
	                                          ГруппаИсточникиПравил.ПодчиненныеЭлементы.Источник_Файл);
	//
	
	// назначаем заголовок формы
	Заголовок = Строка(Запись.ВидПравил);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьПравилаНаСервере(Отказ, АдресВременногоХранилища, ИмяФайлаПравил)
	
	Объект = РеквизитФормыВЗначение("Запись");
	
	РегистрыСведений.ПравилаДляОбменаДанными.ЗагрузитьПравила(Отказ, Объект, АдресВременногоХранилища, ИмяФайлаПравил);
	
	Если Не Отказ Тогда
		
		Объект.Записать();
		
		Модифицированность = Ложь;
		
	КонецЕсли;
	
	ЗначениеВРеквизитФормы(Объект, "Запись");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьНавигационнуюСсылкуНаСервере()
	
	Отбор = Новый Структура;
	Отбор.Вставить("ИмяПланаОбмена", Запись.ИмяПланаОбмена);
	Отбор.Вставить("ВидПравил",      Запись.ВидПравил);
	
	КлючЗаписи = РегистрыСведений.ПравилаДляОбменаДанными.СоздатьКлючЗаписи(Отбор);
	
	Возврат ПолучитьНавигационнуюСсылку(КлючЗаписи, "ПравилаXML");
	
КонецФункции
