﻿// Процедура предназначена для заполнения общих реквизитов документов,
// вызывается в обработчиках событий "ПриОткрытии" в модулех форм всех документов.
//
// Параметры:
//  ДокументОбъект                 - объект редактируемого документа,
//  ТекПользователь                - ссылка на справочник, определяет текущего пользователя  
//  ВалютаРегламентированногоУчета - валюта регламентированного учета
//
Процедура ЗаполнитьШапкуДокумента(ДокументОбъект, ТекПользователь, ВалютаРегламентированногоУчета = Неопределено) Экспорт

	МетаданныеДокумента = ДокументОбъект.Метаданные();

	Если МетаданныеДокумента.Реквизиты.Найти("Ответственный") <> Неопределено Тогда
		ДокументОбъект.Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновнойОтветственный");
	КонецЕсли;
	
	// Флаги принадлежности к учету заполняем, только если оба не заполнены
	Если МетаданныеДокумента.Реквизиты.Найти("ОтражатьВУправленческомУчете") <> Неопределено
		И МетаданныеДокумента.Реквизиты.Найти("ОтражатьВБухгалтерскомУчете") <> Неопределено Тогда
		Если Не (ДокументОбъект.ОтражатьВУправленческомУчете 
			или ДокументОбъект.ОтражатьВБухгалтерскомУчете) Тогда
			
			ДокументОбъект.ОтражатьВУправленческомУчете = Ложь;
			ДокументОбъект.ОтражатьВБухгалтерскомУчете  = Истина;
			
			Если МетаданныеДокумента.Реквизиты.Найти("ОтражатьВНалоговомУчете") <> Неопределено Тогда
				ДокументОбъект.ОтражатьВНалоговомУчете = Истина;
			КонецЕсли;
			
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("Подразделение") <> Неопределено 
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.Подразделение)) Тогда
		ДокументОбъект.Подразделение = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновноеПодразделение");
	КонецЕсли;
	
	ПроверятьСоответствиеПодразделенияОрганизации = Ложь;
	Если МетаданныеДокумента.Реквизиты.Найти("Организация") <> Неопределено Тогда
		ЭтоУпрДокумент =  МетаданныеДокумента.Реквизиты.Найти("ОтражатьВУправленческомУчете") <> Неопределено И ДокументОбъект.ОтражатьВУправленческомУчете;
		Если Не ЭтоУпрДокумент Тогда
			ПроверятьСоответствиеПодразделенияОрганизации = Истина;
			Если (НЕ ЗначениеЗаполнено(ДокументОбъект.Организация)) Тогда
				ДокументОбъект.Организация = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновнаяОрганизация");
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("ВидОперации") <> Неопределено
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВидОперации)) Тогда
		ДокументОбъект.ВидОперации = Перечисления[ДокументОбъект.ВидОперации.Метаданные().Имя][0];
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("СчетОрганизации") <> Неопределено
		И (НЕ ЗначениеЗаполнено(ДокументОбъект.СчетОрганизации))
		И (ЗначениеЗаполнено(ДокументОбъект.Организация.ЮрФизЛицо)) Тогда
		СчетПоУмолчанию = ДокументОбъект.Организация.ОсновнойБанковскийСчет;
		ДокументОбъект.СчетОрганизации = СчетПоУмолчанию;
		Если МетаданныеДокумента.Реквизиты.Найти("ВалютаДокумента") <> Неопределено
			И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВалютаДокумента)) Тогда
			ДокументОбъект.ВалютаДокумента =  СчетПоУмолчанию.ВалютаДенежныхСредств;
		КонецЕсли;
	КонецЕсли;
	
	Если МетаданныеДокумента.Реквизиты.Найти("ПодразделениеОрганизации") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ПодразделениеОрганизации)) Тогда
	   ПодразделениеПоУмолчанию = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ТекПользователь, "ОсновноеПодразделениеОрганизации");;
	   Если ПроверятьСоответствиеПодразделенияОрганизации Тогда
		   Если ПодразделениеПоУмолчанию.Владелец = ДокументОбъект.Организация Тогда
			   ДокументОбъект.ПодразделениеОрганизации = ПодразделениеПоУмолчанию;
		   КонецЕсли;
	   Иначе 	
		   ДокументОбъект.ПодразделениеОрганизации = ПодразделениеПоУмолчанию;
	   КонецЕсли;
	КонецЕсли;
		
	Если МетаданныеДокумента.Реквизиты.Найти("ВалютаДокумента") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ВалютаДокумента)) Тогда
		ДокументОбъект.ВалютаДокумента = ВалютаРегламентированногоУчета;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("КурсДокумента") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.КурсДокумента)) Тогда
	    СтруктураКурсаДокумента      = МодульВалютногоУчета.ПолучитьКурсВалюты(ДокументОбъект.ВалютаДокумента, ДокументОбъект.Дата);
		ДокументОбъект.КурсДокумента = СтруктураКурсаДокумента.Курс;

		Если МетаданныеДокумента.Реквизиты.Найти("КратностьДокумента") <> Неопределено Тогда
			ДокументОбъект.КратностьДокумента = СтруктураКурсаДокумента.Кратность;
		КонецЕсли;
	КонецЕсли;

	Если МетаданныеДокумента.Реквизиты.Найти("ПериодРегистрации") <> Неопределено
	   И (НЕ ЗначениеЗаполнено(ДокументОбъект.ПериодРегистрации)) Тогда
		ДокументОбъект.ПериодРегистрации = НачалоМесяца(ОбщегоНазначения.ПолучитьРабочуюДату());
	КонецЕсли;
	
КонецПроцедуры // ЗаполнитьШапкуДокумента()

